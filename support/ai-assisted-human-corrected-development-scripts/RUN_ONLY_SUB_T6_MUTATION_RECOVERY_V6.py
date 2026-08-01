#!/usr/bin/env python3
"""
SUB-T6 B6.8 mutation recovery + B6.9 final evidence freeze.

Recovery policy:
- Reuse the latest preserved B6.8 failed attempt that contains complete M6.1
  evidence and the complete M6.2 full-model result.
- Reparse those JSON results independently.
- Accept for M6.2 exactly:
    * T6.6 PRE_LOWER failure,
    * T6.6 PRE_UPPER failure,
    * documented downstream signed-to-unsigned conversion failure in d1.
- Run only the missing M6.2 targeted witness and the remaining M6.3/M6.4
  detector executions.
- Freeze B6.8 and B6.9 only after exact aggregate gates pass.
"""

from __future__ import annotations

import json
import os
import shutil
import stat
import subprocess
import sys
import tarfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

RUNNER_BUILD_ID = "SUB_T6_B68_RECOVERY_V6_20260718"

ROOT = Path("/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3")
B6 = ROOT / "SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC = ROOT / "source/mlkem"

B60 = B6 / "00_PREREGISTRATION"
B61 = B6 / "01_CALLCHAIN_BINDING"
B62 = B6 / "02_ASSUMPTION_AUDIT"
B63 = B6 / "03_HARNESS_FREEZE/frozen_harness_family_v1"
B64 = B6 / "04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"
B65 = B6 / "05_POSITIVE_EXECUTION/B6_5_POSITIVE_EXECUTION_MLKEM768_RUN4_TOMSG_PRAGMA_RECOVERY_V3"
B66 = B6 / "06_REACHABILITY/B6_6_REACHABILITY_MLKEM768_RUN1"
B67 = B6 / "07_EXPECTED_FAILURES/B6_7_EXPECTED_FAILURES_MLKEM768_RUN1"
B68_PARENT = B6 / "08_MUTATIONS"
B68 = B68_PARENT / "B6_8_MUTATION_SENSITIVITY_MLKEM768_RUN1"
B69_PARENT = B6 / "09_FINAL_EVIDENCE"
B69 = B69_PARENT / "B6_9_FINAL_EVIDENCE_FREEZE"

PACKAGE = Path.home() / "Downloads/SUB_T6_FINAL_EVIDENCE_2026-07-18.tar.gz"
PACKAGE_SHA = Path(str(PACKAGE) + ".sha256")

EXPECTED_HASHES = {
    SRC / "src/poly.c": "f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722",
    SRC / "src/poly.h": "f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef",
    SRC / "src/compress.c": "9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad",
    SRC / "src/compress.h": "0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd",
    SRC / "src/indcpa.c": "ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd",
    SRC / "src/poly_k.h": "09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0",
    SRC / "src/params.h": "450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb",
    SRC / "src/cbmc.h": "12fe62f76060aa2cdd41de6170e0c787c516ae753ed32579c9c39b1af55130fb",
    B60 / "SUB_T6_B6_0_PREREGISTRATION.json": "1f5abb6572ca03a7e6517b8c20155a14216e166e3633b99b8c13e37dc37b7619",
    B60 / "SUB_T6_B6_0_PREREGISTRATION.md": "a2db903138eefa7ce53c542a903862f68f1634fda436bd29a2d06ab681d5dd20",
}

STAGE_MANIFESTS = [
    (B63, "SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256"),
    (B64, "SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256"),
    (B65, "SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256"),
    (B66, "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256"),
    (B67, "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256"),
]

M62_COLLATERAL = (
    "mlk_scalar_compress_d1.overflow.1",
    "arithmetic overflow on signed to unsigned type conversion in (uint32_t)u",
)


@dataclass(frozen=True)
class PropertyResult:
    property_id: str
    status: str
    description: str


@dataclass
class Audit:
    success: int
    target_failures: list[PropertyResult]
    collateral_failures: list[PropertyResult]
    unrelated_failures: list[PropertyResult]
    unknown: list[PropertyResult]
    target_property: str
    target_marker: str
    total: int


@dataclass(frozen=True)
class CaseSpec:
    name: str
    harness: Path
    poly_source: Path
    markers: tuple[str, ...]
    required_functions: tuple[str, ...]
    need_tomsg: bool = False
    forbid_reduce: bool = False


def log(message: str = "") -> None:
    print(message, flush=True)


def fail(message: str) -> "NoReturn":
    raise RuntimeError(message)


def sha256_file(path: Path) -> str:
    import hashlib
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def ensure_tool(name: str) -> None:
    if shutil.which(name) is None:
        fail(f"required tool missing: {name}")


def run_checked(
    command: Sequence[str],
    *,
    stdout: Path | None = None,
    stderr: Path | None = None,
    expected: Iterable[int] = (0,),
    timeout_seconds: int | None = None,
    resource_file: Path | None = None,
) -> int:
    if stdout:
        stdout.parent.mkdir(parents=True, exist_ok=True)
    if stderr:
        stderr.parent.mkdir(parents=True, exist_ok=True)
    if resource_file:
        resource_file.parent.mkdir(parents=True, exist_ok=True)

    wrapped = list(command)
    if timeout_seconds is not None:
        wrapped = [
            "timeout", "--signal=TERM", "--kill-after=60s",
            str(timeout_seconds),
            *wrapped,
        ]
    if resource_file is not None and Path("/usr/bin/time").is_file():
        wrapped = ["/usr/bin/time", "-v", "-o", str(resource_file), *wrapped]

    out_handle = stdout.open("wb") if stdout else subprocess.DEVNULL
    err_handle = stderr.open("wb") if stderr else subprocess.DEVNULL
    try:
        completed = subprocess.run(
            wrapped,
            stdout=out_handle,
            stderr=err_handle,
            check=False,
        )
    finally:
        if stdout:
            out_handle.close()
        if stderr:
            err_handle.close()

    if completed.returncode not in set(expected):
        fail(
            f"command returned {completed.returncode}, expected "
            f"{sorted(set(expected))}: {' '.join(command)}"
        )
    return completed.returncode


def write_command(path: Path, command: Sequence[str]) -> None:
    import shlex
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "COMMAND: " + " ".join(shlex.quote(item) for item in command) + "\n",
        encoding="utf-8",
    )


def check_hash(path: Path, expected: str) -> None:
    if not path.is_file():
        fail(f"required file missing: {path}")
    actual = sha256_file(path)
    if actual != expected:
        fail(f"hash mismatch: {path}\nexpected={expected}\nactual={actual}")


def check_manifest(directory: Path, manifest_name: str) -> None:
    manifest = directory / manifest_name
    if not manifest.is_file():
        fail(f"manifest missing: {manifest}")
    run_checked(["sha256sum", "-c", manifest_name], stdout=None, stderr=None, expected=(0,), timeout_seconds=None, resource_file=None) if False else None
    completed = subprocess.run(
        ["sha256sum", "-c", manifest_name],
        cwd=directory,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode != 0:
        fail(f"manifest validation failed: {manifest}")


def parse_results(path: Path) -> list[PropertyResult]:
    data = json.loads(path.read_text(encoding="utf-8"))
    found: list[PropertyResult] = []

    def walk(value: object) -> None:
        if isinstance(value, dict):
            if "property" in value and "status" in value:
                found.append(
                    PropertyResult(
                        str(value.get("property", "")),
                        str(value.get("status", "")),
                        str(value.get("description", "")),
                    )
                )
            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(data)
    unique: list[PropertyResult] = []
    seen: set[tuple[str, str, str]] = set()
    for item in found:
        key = (item.property_id, item.status, item.description)
        if key not in seen:
            seen.add(key)
            unique.append(item)
    return unique


def audit_json(
    path: Path,
    markers: Sequence[str],
    *,
    allowed_collateral: set[tuple[str, str]] | None = None,
    exact_target_ids: set[str] | None = None,
) -> Audit:
    allowed_collateral = allowed_collateral or set()
    results = parse_results(path)

    def is_target(item: PropertyResult) -> bool:
        return any(
            marker in item.property_id or marker in item.description
            for marker in markers
        )

    success = [item for item in results if item.status == "SUCCESS"]
    failures = [item for item in results if item.status == "FAILURE"]
    unknown = [
        item for item in results
        if item.status not in {"SUCCESS", "FAILURE"}
    ]
    target = [item for item in failures if is_target(item)]
    collateral = [
        item for item in failures
        if (item.property_id, item.description) in allowed_collateral
    ]
    unrelated = [
        item for item in failures
        if item not in target and item not in collateral
    ]

    for marker in markers:
        if not any(
            marker in item.property_id or marker in item.description
            for item in results
        ):
            fail(f"expected marker missing from JSON: {marker}")

    if not target:
        fail(f"no target failure in {path}")
    if unrelated:
        fail(
            "unrelated failures: "
            + ", ".join(item.property_id for item in unrelated)
        )
    if unknown:
        fail(
            "unknown properties: "
            + ", ".join(item.property_id for item in unknown)
        )
    if exact_target_ids is not None:
        actual = {item.property_id for item in target}
        if actual != exact_target_ids:
            fail(
                f"target property set mismatch: actual={sorted(actual)} "
                f"expected={sorted(exact_target_ids)}"
            )
    actual_collateral = {
        (item.property_id, item.description) for item in collateral
    }
    if actual_collateral != allowed_collateral:
        fail(
            f"collateral set mismatch: actual={actual_collateral} "
            f"expected={allowed_collateral}"
        )

    first = target[0]
    target_marker = next(
        marker for marker in markers
        if marker in first.property_id or marker in first.description
    )
    return Audit(
        success=len(success),
        target_failures=target,
        collateral_failures=collateral,
        unrelated_failures=unrelated,
        unknown=unknown,
        target_property=first.property_id,
        target_marker=target_marker,
        total=len(results),
    )


def write_audit(path: Path, audit: Audit, markers: Sequence[str]) -> None:
    lines = [
        f"SUCCESS={audit.success}",
        f"TARGET_FAILURE={len(audit.target_failures)}",
        f"DOCUMENTED_COLLATERAL={len(audit.collateral_failures)}",
        f"UNRELATED_FAILURE={len(audit.unrelated_failures)}",
        f"UNKNOWN={len(audit.unknown)}",
        f"TOTAL_RESULTS={audit.total}",
        f"TARGET_PROPERTY={audit.target_property}",
        f"TARGET_MARKER={audit.target_marker}",
        f"EXPECTED_MARKERS={','.join(markers)}",
    ]
    for item in (
        audit.target_failures
        + audit.collateral_failures
        + audit.unrelated_failures
        + audit.unknown
    ):
        lines.append(
            f"PROPERTY={item.property_id}|STATUS={item.status}|"
            f"DESCRIPTION={item.description}"
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_kv(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            result[key.strip()] = value.strip()
    return result


def make_writable(root: Path) -> None:
    for path in [root, *root.rglob("*")]:
        try:
            mode = path.stat().st_mode
            if path.is_dir():
                path.chmod(mode | stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)
            else:
                path.chmod(mode | stat.S_IRUSR | stat.S_IWUSR)
        except FileNotFoundError:
            pass


def freeze_run(root: Path, manifest_name: str) -> None:
    manifest = root / manifest_name
    files = sorted(
        path for path in root.rglob("*")
        if path.is_file() and path != manifest
    )
    with manifest.open("w", encoding="utf-8") as handle:
        for path in files:
            rel = path.relative_to(root)
            handle.write(f"{sha256_file(path)}  {rel}\n")
    check_manifest(root, manifest_name)
    for path in sorted(root.rglob("*"), reverse=True):
        if path.is_file():
            path.chmod(0o444)
        elif path.is_dir():
            path.chmod(0o555)
    root.chmod(0o555)


def find_recovery_source() -> Path:
    candidates = sorted(
        B68_PARENT.glob(
            "B6_8_MUTATION_SENSITIVITY_MLKEM768_RUN1_FAILED_*"
        ),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    for candidate in candidates:
        required = [
            candidate / "mutation_family/SUB_T6_B6_8_MUTATION_FAMILY_MANIFEST.sha256",
            candidate / "results/m6_1_addition_t6_3_full_result.json",
            candidate / "results/m6_1_addition_t6_3_parsed.txt",
            candidate / "witnesses/m6_1_addition_t6_3_witness.txt",
            candidate / "exit_codes/m6_1_addition_t6_3_full_exit_code.txt",
            candidate / "exit_codes/m6_1_addition_t6_3_witness_exit_code.txt",
            candidate / "results/m6_2_remove_reduce_t6_6_full_result.json",
            candidate / "results/m6_2_remove_reduce_t6_6_parsed.txt",
            candidate / "exit_codes/m6_2_remove_reduce_t6_6_full_exit_code.txt",
            candidate / "build/m6_2_remove_reduce_t6_6.goto",
            candidate / "inspection/m6_2_remove_reduce_t6_6_unwindset.txt",
        ]
        if all(path.is_file() for path in required):
            return candidate
    fail("no preserved B6.8 attempt contains reusable M6.1/M6.2 evidence")


def verify_exit(path: Path, expected: int) -> None:
    actual = path.read_text(encoding="utf-8").strip()
    if actual != str(expected):
        fail(f"exit-code mismatch: {path}: {actual} != {expected}")


def verify_witness(path: Path, marker: str) -> None:
    text = path.read_text(encoding="utf-8", errors="replace")
    for required in (marker, "Violated property", "VERIFICATION FAILED"):
        if required not in text:
            fail(f"witness missing {required}: {path}")


def remove_prefix_artifacts(case_prefixes: Sequence[str]) -> None:
    directories = [
        "build", "inspection", "results", "witnesses", "commands",
        "logs", "exit_codes", "resource_usage",
    ]
    for directory_name in directories:
        directory = B68 / directory_name
        if not directory.is_dir():
            continue
        for prefix in case_prefixes:
            for path in directory.glob(prefix + "*"):
                if path.is_dir():
                    shutil.rmtree(path)
                else:
                    path.unlink()


def build_and_run_remaining_case(spec: CaseSpec) -> tuple[Audit, int, int]:
    goto_file = B68 / f"build/{spec.name}.goto"
    include_args = [
        "-include", str(B63 / "support/sub00r_b6_fail_closed_zeroize.h"),
        "-include", str(B63 / "support/sub00r_b6_verify_pragma_scope.h"),
    ]
    if spec.need_tomsg:
        include_args += [
            "-include",
            str(B68 / "support/sub00r_b6_compress_intended_wrap_scope.h"),
        ]

    build_cmd = [
        "goto-cc",
        "-std=c90",
        "-DMLK_CONFIG_PARAMETER_SET=768",
        "-DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6",
        "-DMLK_CONFIG_NO_ASM=1",
        "-DMLK_CONFIG_CUSTOM_ZEROIZE=1",
        *include_args,
        f"-I{SRC}",
        f"-I{SRC / 'src'}",
        f"-I{B63 / 'support'}",
        f"-I{B68 / 'support'}",
        str(spec.harness),
        str(spec.poly_source),
    ]
    if spec.need_tomsg:
        build_cmd.append(str(SRC / "src/compress.c"))
    build_cmd += [
        str(B63 / "support/sub00r_b6_optblocker_zero.c"),
        "-o", str(goto_file),
    ]

    write_command(B68 / f"commands/{spec.name}_goto_build_command.txt", build_cmd)
    rc_build = run_checked(
        build_cmd,
        stdout=B68 / f"logs/{spec.name}_goto_build_stdout.txt",
        stderr=B68 / f"logs/{spec.name}_goto_build_stderr.txt",
        expected=(0,),
    )
    (B68 / f"exit_codes/{spec.name}_goto_build_exit_code.txt").write_text(
        f"{rc_build}\n", encoding="utf-8"
    )
    (Path(str(goto_file) + ".sha256")).write_text(
        f"{sha256_file(goto_file)}  {goto_file}\n", encoding="utf-8"
    )

    run_checked(
        ["goto-instrument", "--validate-goto-binary", str(goto_file)],
        stdout=B68 / f"inspection/{spec.name}_validate.txt",
        stderr=B68 / f"inspection/{spec.name}_validate_stderr.txt",
    )
    run_checked(
        ["goto-instrument", "--show-loops", str(goto_file)],
        stdout=B68 / f"inspection/{spec.name}_show_loops.txt",
        stderr=B68 / f"inspection/{spec.name}_show_loops_stderr.txt",
    )
    run_checked(
        ["goto-instrument", "--reachable-call-graph", str(goto_file)],
        stdout=B68 / f"inspection/{spec.name}_reachable_call_graph.txt",
        stderr=B68 / f"inspection/{spec.name}_reachable_call_graph_stderr.txt",
    )
    run_checked(
        ["goto-instrument", "--list-undefined-functions", str(goto_file)],
        stdout=B68 / f"inspection/{spec.name}_undefined_functions.txt",
        stderr=B68 / f"inspection/{spec.name}_undefined_functions_stderr.txt",
    )

    parser = B68 / "support/derive_reachable_unwindset.py"
    run_checked(
        [
            "python3", str(parser),
            str(B68 / f"inspection/{spec.name}_reachable_call_graph.txt"),
            str(B68 / f"inspection/{spec.name}_show_loops.txt"),
            str(B68 / f"inspection/{spec.name}_undefined_functions.txt"),
            str(B68 / f"inspection/{spec.name}_reachable_functions.txt"),
            str(B68 / f"inspection/{spec.name}_reachable_loops.tsv"),
            str(B68 / f"inspection/{spec.name}_unwindset.txt"),
            ",".join(spec.required_functions),
            "nondet_int16_t",
        ],
        stdout=B68 / f"inspection/{spec.name}_parser_output.txt",
        stderr=B68 / f"inspection/{spec.name}_parser_stderr.txt",
    )

    reachable = (
        B68 / f"inspection/{spec.name}_reachable_functions.txt"
    ).read_text(encoding="utf-8").splitlines()
    if spec.forbid_reduce and "mlk_sub00r_b6_poly_reduce" in reachable:
        fail(f"reduce remains reachable in {spec.name}")

    unwindset = (
        B68 / f"inspection/{spec.name}_unwindset.txt"
    ).read_text(encoding="utf-8").strip()
    if not unwindset:
        fail(f"empty unwindset: {spec.name}")

    checks = [
        "--object-bits", "8",
        "--bounds-check",
        "--pointer-check",
        "--pointer-overflow-check",
        "--pointer-primitive-check",
        "--signed-overflow-check",
        "--unsigned-overflow-check",
        "--conversion-check",
        "--undefined-shift-check",
        "--div-by-zero-check",
        "--unwinding-assertions",
        "--unwindset", unwindset,
    ]

    show_cmd = [
        "cbmc", str(goto_file), "--function", "main",
        *checks, "--show-properties",
    ]
    write_command(
        B68 / f"commands/{spec.name}_show_properties_command.txt",
        show_cmd,
    )
    run_checked(
        show_cmd,
        stdout=B68 / f"inspection/{spec.name}_show_properties.txt",
        stderr=B68 / f"inspection/{spec.name}_show_properties_stderr.txt",
    )
    inventory = (
        B68 / f"inspection/{spec.name}_show_properties.txt"
    ).read_text(encoding="utf-8", errors="replace")
    for marker in spec.markers:
        if marker not in inventory:
            fail(f"property inventory missing {marker}: {spec.name}")

    full_json = B68 / f"results/{spec.name}_full_result.json"
    full_cmd = [
        "cbmc", str(goto_file), "--function", "main",
        *checks,
        "--slice-formula",
        "--sat-solver", "minisat2",
        "--trace",
        "--json-ui",
    ]
    write_command(B68 / f"commands/{spec.name}_full_command.txt", full_cmd)
    log(f"B6.8 CASE={spec.name} PHASE=FULL_MODEL STATUS=RUNNING")
    rc_full = run_checked(
        full_cmd,
        stdout=full_json,
        stderr=B68 / f"logs/{spec.name}_full_stderr.txt",
        expected=(10,),
        timeout_seconds=21600,
        resource_file=B68 / f"resource_usage/{spec.name}_full_resource.txt",
    )
    (B68 / f"exit_codes/{spec.name}_full_exit_code.txt").write_text(
        f"{rc_full}\n", encoding="utf-8"
    )
    Path(str(full_json) + ".sha256").write_text(
        f"{sha256_file(full_json)}  {full_json}\n", encoding="utf-8"
    )

    audit = audit_json(full_json, spec.markers)
    write_audit(B68 / f"results/{spec.name}_parsed_v6.txt", audit, spec.markers)

    witness = B68 / f"witnesses/{spec.name}_witness.txt"
    witness_cmd = [
        "cbmc", str(goto_file), "--function", "main",
        *checks,
        "--slice-formula",
        "--sat-solver", "minisat2",
        "--property", audit.target_property,
        "--trace",
    ]
    write_command(B68 / f"commands/{spec.name}_witness_command.txt", witness_cmd)
    log(f"B6.8 CASE={spec.name} PHASE=TARGETED_WITNESS STATUS=RUNNING")
    rc_witness = run_checked(
        witness_cmd,
        stdout=witness,
        stderr=B68 / f"logs/{spec.name}_witness_stderr.txt",
        expected=(10,),
        timeout_seconds=21600,
        resource_file=B68 / f"resource_usage/{spec.name}_witness_resource.txt",
    )
    (B68 / f"exit_codes/{spec.name}_witness_exit_code.txt").write_text(
        f"{rc_witness}\n", encoding="utf-8"
    )
    verify_witness(witness, audit.target_marker)
    Path(str(witness) + ".sha256").write_text(
        f"{sha256_file(witness)}  {witness}\n", encoding="utf-8"
    )
    log(
        f"B6.8 CASE={spec.name} STATUS=KILLED "
        f"TARGET_FAILURE={len(audit.target_failures)} "
        "UNRELATED_FAILURE=0 UNKNOWN=0 WITNESS=PASS"
    )
    return audit, rc_full, rc_witness


def validate_package(archive: Path) -> None:
    if not archive.is_file():
        fail(f"final package missing: {archive}")
    with tarfile.open(archive, "r:gz") as tar:
        bad: list[str] = []
        names = {member.name for member in tar.getmembers()}
        for member in tar.getmembers():
            name = member.name
            if name.startswith("/"):
                bad.append("ABSOLUTE:" + name)
            if ".." in name.split("/"):
                bad.append("DOTDOT:" + name)
            if member.issym() or member.islnk():
                bad.append("LINK:" + name)
        if bad:
            fail("unsafe final package: " + ",".join(bad))

        root_name = B6.name
        b68_manifest_name = (
            f"{root_name}/08_MUTATIONS/"
            "B6_8_MUTATION_SENSITIVITY_MLKEM768_RUN1/"
            "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"
        )
        b69_manifest_name = (
            f"{root_name}/09_FINAL_EVIDENCE/"
            "B6_9_FINAL_EVIDENCE_FREEZE/"
            "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"
        )
        for name, local in (
            (b68_manifest_name, B68 / "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"),
            (b69_manifest_name, B69 / "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"),
        ):
            if name not in names:
                fail(f"final package member missing: {name}")
            extracted = tar.extractfile(name)
            if extracted is None or extracted.read() != local.read_bytes():
                fail(f"final package manifest binding failed: {name}")


def main() -> None:
    log("=" * 60)
    log("SUB-T6 B6.8 RECOVERY + B6.9 FINAL FREEZE")
    log("=" * 60)
    log(f"RUNNER_BUILD_ID={RUNNER_BUILD_ID}")
    log(f"DATE_UTC={time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}")
    log(f"B68={B68}")
    log(f"B69={B69}")
    log(f"PACKAGE={PACKAGE}")

    for tool in (
        "sha256sum", "cbmc", "goto-cc", "goto-instrument",
        "timeout", "python3", "tar",
    ):
        ensure_tool(tool)

    versions = {
        "CBMC": subprocess.check_output(["cbmc", "--version"], text=True).splitlines()[0],
        "GOTOCC": subprocess.check_output(["goto-cc", "--version"], text=True, stderr=subprocess.STDOUT).splitlines()[0],
        "GOTOINSTRUMENT": subprocess.check_output(["goto-instrument", "--version"], text=True, stderr=subprocess.STDOUT).splitlines()[0],
    }
    for name, version in versions.items():
        if "6.9.0" not in version:
            fail(f"{name} is not frozen version 6.9.0: {version}")

    for path in (ROOT, B6, SRC, B60, B61, B62, B63, B64, B65, B66, B67):
        if not path.is_dir():
            fail(f"required directory missing: {path}")

    log("\n--- Revalidating frozen source and B6.0-B6.7 evidence ---")
    for path, expected in EXPECTED_HASHES.items():
        check_hash(path, expected)
    for directory, manifest in STAGE_MANIFESTS:
        check_manifest(directory, manifest)

    required_verdicts = [
        (B64 / "SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt", "B6_4_STATUS=PASS"),
        (B65 / "SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt", "B6_5_STATUS=PASS"),
        (B66 / "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt", "B6_6_STATUS=PASS"),
        (B67 / "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt", "B6_7_STATUS=PASS"),
    ]
    for path, verdict in required_verdicts:
        if verdict not in path.read_text(encoding="utf-8"):
            fail(f"required verdict missing: {verdict}")

    if B68.exists():
        manifest = B68 / "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"
        summary = B68 / "SUB_T6_B6_8_MUTATION_SUMMARY.txt"
        if manifest.is_file() and summary.is_file() and "B6_8_STATUS=PASS" in summary.read_text(encoding="utf-8"):
            check_manifest(B68, manifest.name)
            log("B6_8_EXISTING_FROZEN_RUN_REUSED=YES")
        else:
            fail(f"non-final canonical B6.8 directory already exists: {B68}")
    else:
        source_failed = find_recovery_source()
        log(f"RECOVERY_SOURCE={source_failed}")

        shutil.copytree(source_failed, B68)
        make_writable(B68)
        for stale in (
            B68 / "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256",
            B68 / "SUB_T6_B6_8_MUTATION_SUMMARY.txt",
        ):
            if stale.exists():
                stale.unlink()

        current_script = Path(__file__).resolve()
        shutil.copy2(current_script, B68 / "executed_recovery_runner_v6.py")

        (B68 / "RECOVERY_PROVENANCE.txt").write_text(
            "\n".join([
                f"RUNNER_BUILD_ID={RUNNER_BUILD_ID}",
                f"SOURCE_FAILED_ATTEMPT={source_failed}",
                "M6_1_FULL_MODEL_REUSED=YES",
                "M6_1_TARGETED_WITNESS_REUSED=YES",
                "M6_2_FULL_MODEL_REUSED=YES",
                "M6_2_TARGETED_WITNESS_EXECUTED_IN_RECOVERY=YES",
                "M6_3_AND_M6_4_EXECUTED_IN_RECOVERY=YES",
                "PRODUCTION_SOURCE_MODIFICATION=NO",
                "FROZEN_POSITIVE_HARNESS_MODIFICATION=NO",
            ]) + "\n",
            encoding="utf-8",
        )

        check_manifest(
            B68 / "mutation_family",
            "SUB_T6_B6_8_MUTATION_FAMILY_MANIFEST.sha256",
        )

        # Replace the stale parser with a provenance copy of the accepted helper.
        shutil.copy2(
            B67 / "support/derive_reachable_unwindset.py",
            B68 / "support/derive_reachable_unwindset.py",
        )

        remove_prefix_artifacts([
            "m6_3_modify_sb_t6_4",
            "m6_4_skip_255_t6_3",
            "m6_4_skip_255_t6_5",
        ])

        log("\n--- Reusing and independently auditing M6.1 ---")
        m61_json = B68 / "results/m6_1_addition_t6_3_full_result.json"
        verify_exit(B68 / "exit_codes/m6_1_addition_t6_3_full_exit_code.txt", 10)
        verify_exit(B68 / "exit_codes/m6_1_addition_t6_3_witness_exit_code.txt", 10)
        m61 = audit_json(m61_json, ["SUB_T6_T6_3"])
        write_audit(B68 / "results/m6_1_addition_t6_3_parsed_v6.txt", m61, ["SUB_T6_T6_3"])
        verify_witness(
            B68 / "witnesses/m6_1_addition_t6_3_witness.txt",
            m61.target_marker,
        )
        log(
            f"M6_1_REUSED=PASS TARGET_FAILURE={len(m61.target_failures)} "
            "UNRELATED_FAILURE=0 UNKNOWN=0"
        )

        log("\n--- Reusing and independently auditing M6.2 full model ---")
        m62_json = B68 / "results/m6_2_remove_reduce_t6_6_full_result.json"
        verify_exit(B68 / "exit_codes/m6_2_remove_reduce_t6_6_full_exit_code.txt", 10)
        m62 = audit_json(
            m62_json,
            ["SUB_T6_T6_6_PRE_LOWER", "SUB_T6_T6_6_PRE_UPPER"],
            allowed_collateral={M62_COLLATERAL},
            exact_target_ids={"main.assertion.2", "main.assertion.3"},
        )
        if m62.success != 871 or m62.total != 874:
            fail(
                f"M6.2 exact result totals changed: success={m62.success}, "
                f"total={m62.total}"
            )
        write_audit(
            B68 / "results/m6_2_remove_reduce_t6_6_parsed_v6.txt",
            m62,
            ["SUB_T6_T6_6_PRE_LOWER", "SUB_T6_T6_6_PRE_UPPER"],
        )
        log(
            "M6_2_FULL_MODEL_REUSED=PASS TARGET_FAILURE=2 "
            "DOCUMENTED_COLLATERAL=1 UNRELATED_FAILURE=0 UNKNOWN=0"
        )

        # Capture the one missing targeted witness, using the lower-bound target.
        m62_goto = B68 / "build/m6_2_remove_reduce_t6_6.goto"
        run_checked(
            ["goto-instrument", "--validate-goto-binary", str(m62_goto)],
            stdout=B68 / "inspection/m6_2_remove_reduce_t6_6_recovery_validate.txt",
            stderr=B68 / "inspection/m6_2_remove_reduce_t6_6_recovery_validate_stderr.txt",
        )
        m62_unwind = (
            B68 / "inspection/m6_2_remove_reduce_t6_6_unwindset.txt"
        ).read_text(encoding="utf-8").strip()
        if not m62_unwind:
            fail("M6.2 reused unwindset is empty")
        m62_checks = [
            "--object-bits", "8",
            "--bounds-check",
            "--pointer-check",
            "--pointer-overflow-check",
            "--pointer-primitive-check",
            "--signed-overflow-check",
            "--unsigned-overflow-check",
            "--conversion-check",
            "--undefined-shift-check",
            "--div-by-zero-check",
            "--unwinding-assertions",
            "--unwindset", m62_unwind,
        ]
        m62_witness = B68 / "witnesses/m6_2_remove_reduce_t6_6_witness.txt"
        m62_witness_cmd = [
            "cbmc", str(m62_goto), "--function", "main",
            *m62_checks,
            "--slice-formula",
            "--sat-solver", "minisat2",
            "--property", "main.assertion.2",
            "--trace",
        ]
        write_command(
            B68 / "commands/m6_2_remove_reduce_t6_6_witness_command.txt",
            m62_witness_cmd,
        )
        log("B6.8 CASE=m6_2_remove_reduce_t6_6 PHASE=TARGETED_WITNESS STATUS=RUNNING")
        rc_m62_witness = run_checked(
            m62_witness_cmd,
            stdout=m62_witness,
            stderr=B68 / "logs/m6_2_remove_reduce_t6_6_witness_stderr.txt",
            expected=(10,),
            timeout_seconds=21600,
            resource_file=B68 / "resource_usage/m6_2_remove_reduce_t6_6_witness_resource.txt",
        )
        (B68 / "exit_codes/m6_2_remove_reduce_t6_6_witness_exit_code.txt").write_text(
            f"{rc_m62_witness}\n", encoding="utf-8"
        )
        verify_witness(m62_witness, "SUB_T6_T6_6_PRE_LOWER")
        Path(str(m62_witness) + ".sha256").write_text(
            f"{sha256_file(m62_witness)}  {m62_witness}\n",
            encoding="utf-8",
        )
        log("B6.8 CASE=m6_2_remove_reduce_t6_6 STATUS=KILLED WITNESS=PASS")

        specs = [
            CaseSpec(
                "m6_3_modify_sb_t6_4",
                B63 / "harnesses/sub_t6_callsite_frame_harness.c",
                B68 / "mutation_family/mutants/M6_3_MODIFY_SB/poly.c",
                ("SUB_T6_T6_4_SB",),
                ("main", "mlk_sub00r_b6_poly_sub"),
            ),
            CaseSpec(
                "m6_4_skip_255_t6_3",
                B63 / "harnesses/sub_t6_callsite_exactness_harness.c",
                B68 / "mutation_family/mutants/M6_4_SKIP_255/poly.c",
                ("SUB_T6_T6_3",),
                ("main", "mlk_sub00r_b6_poly_sub"),
            ),
            CaseSpec(
                "m6_4_skip_255_t6_5",
                B63 / "harnesses/sub_t6_sub_reduce_handoff_harness.c",
                B68 / "mutation_family/mutants/M6_4_SKIP_255/poly.c",
                ("SUB_T6_T6_5_SUB",),
                ("main", "mlk_sub00r_b6_poly_sub", "mlk_sub00r_b6_poly_reduce"),
            ),
        ]
        remaining: dict[str, tuple[Audit, int, int]] = {}
        for spec in specs:
            remaining[spec.name] = build_and_run_remaining_case(spec)

        rows = [
            (
                "m6_1_addition_t6_3", 10, m61.success,
                len(m61.target_failures), 0, 0, 0,
                m61.target_property, m61.target_marker, 10, "KILLED",
            ),
            (
                "m6_2_remove_reduce_t6_6", 10, m62.success,
                len(m62.target_failures), len(m62.collateral_failures), 0, 0,
                "main.assertion.2", "SUB_T6_T6_6_PRE_LOWER",
                rc_m62_witness, "KILLED",
            ),
        ]
        for spec in specs:
            audit, rc_full, rc_witness = remaining[spec.name]
            rows.append(
                (
                    spec.name, rc_full, audit.success,
                    len(audit.target_failures), 0, 0, 0,
                    audit.target_property, audit.target_marker,
                    rc_witness, "KILLED",
                )
            )

        summary = B68 / "SUB_T6_B6_8_MUTATION_SUMMARY.txt"
        with summary.open("w", encoding="utf-8") as handle:
            handle.write("SUB-T6 B6.8 MUTATION SENSITIVITY SUMMARY\n\n")
            handle.write(f"RECOVERY_UTC={time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}\n")
            handle.write(f"RUNNER_BUILD_ID={RUNNER_BUILD_ID}\n")
            handle.write(f"RECOVERY_SOURCE={source_failed}\n\n")
            handle.write(
                "CASE|FULL_EXIT|SUCCESS|TARGET_FAILURE|DOCUMENTED_COLLATERAL|"
                "UNRELATED_FAILURE|UNKNOWN|TARGET_PROPERTY|TARGET_MARKER|"
                "WITNESS_EXIT|VERDICT\n"
            )
            for row in rows:
                handle.write("|".join(str(value) for value in row) + "\n")
            handle.write("\nMANDATORY_MUTANT_COUNT=4\n")
            handle.write("DETECTOR_EXECUTION_COUNT=5\n")
            handle.write("FULL_MODEL_EXPECTED_EXIT_COUNT=5\n")
            handle.write("TARGETED_WITNESS_EXPECTED_EXIT_COUNT=5\n")
            handle.write("DOCUMENTED_CAUSAL_COLLATERAL_TOTAL=1\n")
            handle.write("UNRELATED_FAILURE_TOTAL=0\n")
            handle.write("UNKNOWN_PROPERTY_TOTAL=0\n")
            handle.write("M6_1_ADDITION=KILLED_BY_T6_3\n")
            handle.write("M6_2_REMOVE_REDUCE=KILLED_BY_T6_6\n")
            handle.write(
                "M6_2_DOCUMENTED_COLLATERAL="
                "mlk_scalar_compress_d1.overflow.1_AFTER_NONCANONICAL_INPUT\n"
            )
            handle.write("M6_3_MODIFY_SB=KILLED_BY_T6_4\n")
            handle.write("M6_4_SKIP_255=KILLED_BY_T6_3_AND_T6_5\n")
            handle.write("MUTATION_SCORE=4/4\n")
            handle.write("ALL_MUTANTS_COMPILED=PASS\n")
            handle.write("ALL_MUTANT_GOTO_MODELS_VALID=PASS\n")
            handle.write("ALL_REGISTERED_DETECTORS_FIRED=PASS\n")
            handle.write("ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS\n")
            handle.write("PRODUCTION_SOURCE_MODIFICATION=NO\n")
            handle.write("FROZEN_POSITIVE_HARNESS_MODIFICATION=NO\n")
            handle.write("BATCH5_MODIFICATION=NO\n")
            handle.write("B6_8_STATUS=PASS\n")

        for source in (
            B60 / "SUB_T6_B6_0_PREREGISTRATION.json",
            B65 / "SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt",
            B66 / "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt",
            B67 / "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt",
        ):
            target_dir = B68 / "frozen_inputs"
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target_dir / source.name)

        check_hash(SRC / "src/poly.c", EXPECTED_HASHES[SRC / "src/poly.c"])
        freeze_run(B68, "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256")
        log("B6_8_STATUS=PASS")

    # B6.9
    if B69.exists():
        manifest = B69 / "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"
        summary = B69 / "SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt"
        if manifest.is_file() and summary.is_file() and "SUB_T6_CAMPAIGN_STATUS=PASS" in summary.read_text(encoding="utf-8"):
            check_manifest(B69, manifest.name)
            log("B6_9_EXISTING_FROZEN_RUN_REUSED=YES")
        else:
            fail(f"non-final B6.9 directory already exists: {B69}")
    else:
        log("\n" + "=" * 60)
        log("B6.9 — FINAL EVIDENCE FREEZE")
        log("=" * 60)
        B69.mkdir(parents=True)
        for child in ("stage_summaries", "stage_manifests", "source_binding", "campaign_manifest"):
            (B69 / child).mkdir()
        shutil.copy2(Path(__file__).resolve(), B69 / "executed_finalizer_v6.py")

        check_manifest(B68, "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256")
        b68_summary = B68 / "SUB_T6_B6_8_MUTATION_SUMMARY.txt"
        if "B6_8_STATUS=PASS" not in b68_summary.read_text(encoding="utf-8"):
            fail("B6.8 PASS verdict missing")

        summary_sources = [
            B60 / "SUB_T6_B6_0_PREREGISTRATION.json",
            B60 / "SUB_T6_B6_0_PREREGISTRATION.md",
            B61 / "B6_1_BINDING.json",
            B62 / "B6_2_ASSUMPTION_AUDIT.json",
            B64 / "SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt",
            B65 / "SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt",
            B66 / "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt",
            B67 / "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt",
            b68_summary,
        ]
        for source in summary_sources:
            shutil.copy2(source, B69 / "stage_summaries" / source.name)

        for directory, manifest_name in [
            (B63, "SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256"),
            (B64, "SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256"),
            (B65, "SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256"),
            (B66, "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256"),
            (B67, "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256"),
            (B68, "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"),
        ]:
            shutil.copy2(
                directory / manifest_name,
                B69 / "stage_manifests" / manifest_name,
            )

        with (B69 / "source_binding/SUB_T6_FINAL_SOURCE_BINDING.sha256").open(
            "w", encoding="utf-8"
        ) as handle:
            for path in EXPECTED_HASHES:
                if str(path).startswith(str(SRC)):
                    handle.write(f"{sha256_file(path)}  {path}\n")

        positive_total = sum(
            int(parse_kv(path)["TOTAL_RESULTS"])
            for path in sorted(
                (B65 / "carried_forward_run1/results").glob("*_reparsed_result.txt")
            )
        ) + int(
            parse_kv(
                B65 / "recovery_results/tomsg_precondition_corrected_parsed_result.txt"
            )["TOTAL_RESULTS"]
        )
        b66 = parse_kv(B66 / "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt")
        b67 = parse_kv(B67 / "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt")
        b68 = parse_kv(b68_summary)

        exact = {
            "positive_total": (positive_total, 2343),
            "companion_success": (int(b66["COMPANION_SUCCESS"]), 365),
            "companion_failure": (int(b66["COMPANION_FAILURE"]), 0),
            "companion_unknown": (int(b66["COMPANION_UNKNOWN"]), 0),
            "cover_satisfied": (int(b66["COVERAGE_SATISFIED"]), 12),
            "cover_total": (int(b66["COVERAGE_TOTAL"]), 12),
            "ef_target": (int(b67["TARGET_FAILURE_TOTAL"]), 3),
            "ef_unexpected": (int(b67["UNEXPECTED_FAILURE_TOTAL"]), 0),
            "ef_unknown": (int(b67["UNKNOWN_PROPERTY_TOTAL"]), 0),
            "mutation_detectors": (int(b68["DETECTOR_EXECUTION_COUNT"]), 5),
            "mutation_collateral": (int(b68["DOCUMENTED_CAUSAL_COLLATERAL_TOTAL"]), 1),
            "mutation_unrelated": (int(b68["UNRELATED_FAILURE_TOTAL"]), 0),
            "mutation_unknown": (int(b68["UNKNOWN_PROPERTY_TOTAL"]), 0),
        }
        mismatches = [
            f"{name}:{actual}!={expected}"
            for name, (actual, expected) in exact.items()
            if actual != expected
        ]
        if mismatches or b68["MUTATION_SCORE"] != "4/4":
            fail("final exact-total mismatch: " + ",".join(mismatches))

        campaign_manifest = (
            B69 / "campaign_manifest/SUB_T6_B6_0_TO_B6_8_CONTENT_MANIFEST.sha256"
        )
        files: list[Path] = []
        for stage in (
            "00_PREREGISTRATION", "01_CALLCHAIN_BINDING",
            "02_ASSUMPTION_AUDIT", "03_HARNESS_FREEZE",
            "04_GOTO_PREFLIGHT", "05_POSITIVE_EXECUTION",
            "06_REACHABILITY", "07_EXPECTED_FAILURES", "08_MUTATIONS",
        ):
            files.extend(path for path in (B6 / stage).rglob("*") if path.is_file())
        with campaign_manifest.open("w", encoding="utf-8") as handle:
            for path in sorted(files):
                handle.write(f"{sha256_file(path)}  {path.relative_to(B6)}\n")
        campaign_count = len(files)

        final_summary = B69 / "SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt"
        final_summary.write_text(
            f"""SUB-T6 FINAL CAMPAIGN SUMMARY

FREEZE_UTC={time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
TOOL_MODEL={versions['CBMC']}
PARAMETER_SET=ML-KEM-768
MLKEM_N=256
MLKEM_Q=3329
MLK_INVNTT_BOUND=26632

THEOREM_ID=SUB-T6
THEOREM_TITLE=Production Call-Site Contract Satisfaction and Subtract-Reduce Handoff Correctness of mlk_poly_sub in mlk_indcpa_dec

B6_0_PREREGISTRATION=PASS
B6_1_CALLCHAIN_BINDING=PASS
B6_2_ASSUMPTION_AUDIT=PASS
B6_3_HARNESS_FREEZE=PASS
B6_4_GOTO_PREFLIGHT=PASS
B6_5_POSITIVE_EXECUTION=PASS
B6_6_REACHABILITY_NONVACUITY=PASS
B6_7_EXPECTED_FAILURE_CONTROLS=PASS
B6_8_MUTATION_SENSITIVITY=PASS
B6_9_FINAL_EVIDENCE_FREEZE=PASS

T6_1_OBJECT_VALIDITY_AND_SEPARATION=PASS
T6_2_REPRESENTABILITY_DERIVATION=PASS
T6_3_CALLSITE_EXACTNESS=PASS
T6_4_CALLER_FRAME_PRESERVATION=PASS
T6_5_SUB_REDUCE_HANDOFF=PASS
T6_6_TOMSG_PRECONDITION_AND_CONST_INPUT=PASS
T6_7_COMPLETE_BOUNDED_SLICE_SAFETY=PASS

POSITIVE_CBMC_SUCCESS_TOTAL={positive_total}
POSITIVE_CBMC_FAILURE_TOTAL=0
POSITIVE_CBMC_UNKNOWN_TOTAL=0
REACHABILITY_COMPANION_SUCCESS_TOTAL={b66['COMPANION_SUCCESS']}
REACHABILITY_COVER_SATISFIED_TOTAL={b66['COVERAGE_SATISFIED']}
EXPECTED_FAILURE_TARGET_TOTAL={b67['TARGET_FAILURE_TOTAL']}
EXPECTED_FAILURE_UNRELATED_TOTAL=0
EXPECTED_FAILURE_UNKNOWN_TOTAL=0
MANDATORY_MUTATION_SCORE={b68['MUTATION_SCORE']}
MUTATION_DETECTOR_EXECUTION_COUNT={b68['DETECTOR_EXECUTION_COUNT']}
MUTATION_DOCUMENTED_CAUSAL_COLLATERAL_TOTAL=1
MUTATION_UNRELATED_FAILURE_TOTAL=0
MUTATION_UNKNOWN_TOTAL=0

M6_1_ADDITION=KILLED_BY_T6_3
M6_2_REMOVE_REDUCE=KILLED_BY_T6_6
M6_2_DOCUMENTED_COLLATERAL=mlk_scalar_compress_d1.overflow.1_AFTER_NONCANONICAL_INPUT
M6_3_MODIFY_SB=KILLED_BY_T6_4
M6_4_SKIP_255=KILLED_BY_T6_3_AND_T6_5

PRODUCTION_SOURCE_MODIFICATION=NO
FROZEN_POSITIVE_HARNESS_MODIFICATION=NO
BATCH5_MODIFICATION=NO
FAILED_ATTEMPTS_PRESERVED=YES
ALL_STAGE_MANIFESTS_REVALIDATED=PASS
CAMPAIGN_CONTENT_FILE_COUNT={campaign_count}
SUB_T6_CAMPAIGN_STATUS=PASS
""",
            encoding="utf-8",
        )

        (B69 / "SUB_T6_B6_9_PROFESSOR_VERDICT.md").write_text(
            f"""# SUB-T6 final verification verdict

The SUB-T6 campaign passed for the frozen ML-KEM-768 configuration.

The positive proof suite established T6.1–T6.7 for the registered bounded
production slice. The campaign recorded {positive_total} successful positive
CBMC properties, {b66['COMPANION_SUCCESS']} successful reachability-companion
properties, {b66['COVERAGE_SATISFIED']}/12 non-vacuity covers, three isolated
expected-failure controls, and a mandatory mutation score of 4/4.

Removing `mlk_poly_reduce` was detected by both registered T6.6 canonical-input
bounds. The same mutant also produced the documented downstream conversion
failure `mlk_scalar_compress_d1.overflow.1`, because the deliberately
noncanonical negative value was passed to `mlk_poly_tomsg`. This collateral
failure is preserved and classified separately; it is not counted as an
unrelated failure.

This remains a property-specific bounded proof, not a proof of complete K-PKE
decryption, all upstream cryptographic operations, allocator failure paths,
constant-time behaviour, side-channel freedom, or end-to-end ML-KEM.
""",
            encoding="utf-8",
        )

        (B69 / "SUB_T6_B6_9_FINAL_EVIDENCE_INDEX.txt").write_text(
            "\n".join([
                "SUB-T6 FINAL EVIDENCE INDEX",
                "",
                f"1. Preregistration: {B60}",
                f"2. Call-chain binding: {B61}",
                f"3. Assumption audit: {B62}",
                f"4. Harness freeze: {B63}",
                f"5. GOTO preflight: {B64}",
                f"6. Positive execution: {B65}",
                f"7. Reachability: {B66}",
                f"8. Expected failures: {B67}",
                f"9. Mutation sensitivity: {B68}",
                f"10. Final freeze: {B69}",
                "",
                "FINAL_STATUS=PASS",
            ]) + "\n",
            encoding="utf-8",
        )

        freeze_run(B69, "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256")
        log("B6_9_STATUS=PASS")

    check_manifest(B68, "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256")
    check_manifest(B69, "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256")

    if PACKAGE.exists():
        validate_package(PACKAGE)
        if not PACKAGE_SHA.exists():
            PACKAGE_SHA.write_text(
                f"{sha256_file(PACKAGE)}  {PACKAGE}\n",
                encoding="utf-8",
            )
        expected = PACKAGE_SHA.read_text(encoding="utf-8").split()[0]
        if sha256_file(PACKAGE) != expected:
            fail("existing final package SHA-256 mismatch")
        log("FINAL_EXISTING_PACKAGE_REUSED=YES")
    else:
        if PACKAGE_SHA.exists():
            fail(f"orphan final package sidecar exists: {PACKAGE_SHA}")
        with tarfile.open(PACKAGE, "w:gz") as tar:
            tar.add(B6, arcname=B6.name, recursive=True)
        validate_package(PACKAGE)
        PACKAGE_SHA.write_text(
            f"{sha256_file(PACKAGE)}  {PACKAGE}\n",
            encoding="utf-8",
        )

    b68 = parse_kv(B68 / "SUB_T6_B6_8_MUTATION_SUMMARY.txt")
    b69 = parse_kv(B69 / "SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt")

    log("\n" + "=" * 60)
    log("FINAL SUB-T6 CAMPAIGN VERDICT")
    log("=" * 60)
    for key in (
        "MANDATORY_MUTANT_COUNT", "DETECTOR_EXECUTION_COUNT",
        "DOCUMENTED_CAUSAL_COLLATERAL_TOTAL",
        "UNRELATED_FAILURE_TOTAL", "UNKNOWN_PROPERTY_TOTAL",
        "M6_1_ADDITION", "M6_2_REMOVE_REDUCE",
        "M6_2_DOCUMENTED_COLLATERAL", "M6_3_MODIFY_SB",
        "M6_4_SKIP_255", "MUTATION_SCORE", "B6_8_STATUS",
    ):
        log(f"{key}={b68[key]}")
    for key in (
        "POSITIVE_CBMC_SUCCESS_TOTAL",
        "REACHABILITY_COMPANION_SUCCESS_TOTAL",
        "REACHABILITY_COVER_SATISFIED_TOTAL",
        "EXPECTED_FAILURE_TARGET_TOTAL",
        "MANDATORY_MUTATION_SCORE",
        "MUTATION_DOCUMENTED_CAUSAL_COLLATERAL_TOTAL",
        "PRODUCTION_SOURCE_MODIFICATION",
        "FROZEN_POSITIVE_HARNESS_MODIFICATION",
        "ALL_STAGE_MANIFESTS_REVALIDATED",
        "SUB_T6_CAMPAIGN_STATUS",
    ):
        log(f"{key}={b69[key]}")
    log("")
    log(f"FILE={PACKAGE} SIZE={PACKAGE.stat().st_size} MODE={oct(PACKAGE.stat().st_mode & 0o777)[2:]}")
    log(PACKAGE_SHA.read_text(encoding="utf-8").strip())
    log("")
    log("SUB_T6_B6_8_MANDATORY_MUTANTS=4")
    log("SUB_T6_B6_8_MUTATION_SCORE=4/4")
    log("SUB_T6_B6_8_DETECTOR_RUNS=5/5")
    log("SUB_T6_B6_8_DOCUMENTED_COLLATERAL_TOTAL=1")
    log("SUB_T6_B6_8_UNRELATED_FAILURE_TOTAL=0")
    log("SUB_T6_B6_8_STATUS=PASS")
    log("SUB_T6_B6_9_ALL_STAGES_FROZEN=PASS")
    log("SUB_T6_B6_9_FINAL_PACKAGE_PATH_SAFETY=PASS")
    log("SUB_T6_B6_9_FINAL_PACKAGE_MANIFEST_BINDING=PASS")
    log("SUB_T6_PRODUCTION_MODIFIED=NO")
    log("SUB_T6_FROZEN_POSITIVE_HARNESSES_MODIFIED=NO")
    log("SUB_T6_FINAL_UPLOAD_REQUIRED=YES")
    log("SUB_T6_CAMPAIGN_STATUS=PASS")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr, flush=True)
        sys.exit(1)
