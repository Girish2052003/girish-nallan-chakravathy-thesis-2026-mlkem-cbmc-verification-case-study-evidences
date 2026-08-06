#!/usr/bin/env python3
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

PACKAGE_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = Path.cwd().resolve()
RUN_DIR = PACKAGE_ROOT / "evidence" / "run_1"
EXPECTED_COMMIT = "af4c5abdd5958bdc65a03cd5ee86708264f93304"
PARAM_SET = "768"
NAMESPACE_PREFIX = "mlk_sa_br"
THEOREMS = {
    "SA_BR_T1": {
        "harness": "sa_br_t1_sign_conjugacy_harness.c",
        "assertions": [
            "SA_BR_T1_SIGN_CONJUGATE_REDUCTION",
            "SA_BR_T1_ABSOLUTE_REMAINDER_PRESERVED",
            "SA_BR_T1_POSITIVE_QUOTIENT_INTEGRAL",
            "SA_BR_T1_NEGATIVE_QUOTIENT_INTEGRAL",
            "SA_BR_T1_EXACT_QUOTIENT_REVERSAL"
        ],
        "goals": [
            "SA_BR_T1_ASSUMPTIONS_FEASIBLE",
            "SA_BR_T1_POSITIVE_NONTRIVIAL_INPUT",
            "SA_BR_T1_NEGATIVE_NONTRIVIAL_INPUT",
            "SA_BR_T1_TARGET_1_REACHED",
            "SA_BR_T1_TARGET_2_REACHED",
            "SA_BR_T1_ASSERTION_BLOCK_REACHED"
        ],
        "fail_control": "SA_BR_T1_FC_FALSE_EVEN_SYMMETRY"
    },
    "SA_BR_T2": {
        "harness": "sa_br_t2_centered_addition_carry_harness.c",
        "assertions": [
            "SA_BR_T2_INTERMEDIATE_SUM_REPRESENTABLE",
            "SA_BR_T2_CORRECTION_COEFFICIENT_BOUND",
            "SA_BR_T2_EXACT_ONE_CORRECTION_LAW",
            "SA_BR_T2_FULL_SUM_CENTERED_ORACLE_EQUIVALENCE",
            "SA_BR_T2_REDUCED_OPERAND_SUM_RESIDUE_PRESERVATION",
            "SA_BR_T2_FULL_SUM_CONGRUENCE",
            "SA_BR_T2_FINAL_CENTERED_RANGE"
        ],
        "goals": [
            "SA_BR_T2_ASSUMPTIONS_FEASIBLE",
            "SA_BR_T2_POSITIVE_CORRECTION_FEASIBLE",
            "SA_BR_T2_NEGATIVE_CORRECTION_FEASIBLE",
            "SA_BR_T2_ZERO_CORRECTION_FEASIBLE",
            "SA_BR_T2_TARGET_1_REACHED",
            "SA_BR_T2_TARGET_2_REACHED",
            "SA_BR_T2_TARGET_3_REACHED",
            "SA_BR_T2_ASSERTION_BLOCK_REACHED"
        ],
        "fail_control": "SA_BR_T2_FC_FALSE_NO_WRAP_CORRECTION"
    }
}

class CampaignError(RuntimeError):
    pass

def log(message=""):
    print(message, flush=True)

def require(condition, message):
    if not condition:
        raise CampaignError(message)

def run(args, *, cwd=None, stdout_path=None, stderr_path=None, check=True):
    out = stdout_path.open("w", encoding="utf-8", newline="\n") if stdout_path else subprocess.PIPE
    err = stderr_path.open("w", encoding="utf-8", newline="\n") if stderr_path else subprocess.PIPE
    try:
        cp = subprocess.run([str(x) for x in args], cwd=str(cwd) if cwd else None,
                            text=True, stdout=out, stderr=err, check=False)
    finally:
        if stdout_path: out.close()
        if stderr_path: err.close()
    if check and cp.returncode != 0:
        so = cp.stdout if isinstance(cp.stdout, str) else ""
        se = cp.stderr if isinstance(cp.stderr, str) else ""
        raise CampaignError(f"command failed ({cp.returncode}): {' '.join(map(str,args))}\n{so}{se}")
    return cp

def records(value):
    if isinstance(value, dict):
        if "status" in value:
            yield value
        for child in value.values():
            yield from records(child)
    elif isinstance(value, list):
        for child in value:
            yield from records(child)

def statuses_for_token(data, token):
    return [str(r.get("status","")).upper() for r in records(data)
            if token in json.dumps(r, sort_keys=True)]

def sha256(path):
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024*1024), b""):
            h.update(block)
    return h.hexdigest()

def property_map(model, out_dir, goals):
    j = out_dir / "cover_property_inventory.json"
    t = out_dir / "cover_properties.txt"
    cp = run(["cbmc", str(model), "--show-properties", "--json-ui"],
             cwd=REPO_ROOT, stdout_path=j, stderr_path=out_dir/"cover_property_inventory.stderr", check=False)
    require(cp.returncode == 0, f"show-properties JSON exit {cp.returncode}")
    run(["goto-instrument", "--show-properties", str(model)], cwd=REPO_ROOT,
        stdout_path=t, stderr_path=out_dir/"cover_properties.stderr")

    data = json.loads(j.read_text(encoding="utf-8"))
    mapping = {}
    def walk(v):
        if isinstance(v, dict):
            s = json.dumps(v, sort_keys=True)
            for goal in goals:
                if goal in s and goal not in mapping:
                    for key in ("property", "propertyId", "property_id", "id"):
                        value = v.get(key)
                        if isinstance(value, str) and value and value != goal:
                            mapping[goal] = value
                            break
            for child in v.values(): walk(child)
        elif isinstance(v, list):
            for child in v: walk(child)
    walk(data)

    text = t.read_text(encoding="utf-8", errors="ignore")
    blocks = re.split(r"(?m)(?=^Property\s+[^:\n]+:\s*$)", text)
    for block in blocks:
        m = re.match(r"(?m)^Property\s+([^:\n]+):\s*$", block)
        if not m: continue
        for goal in goals:
            if goal in block and goal not in mapping:
                mapping[goal] = m.group(1).strip()

    missing = [g for g in goals if g not in mapping]
    require(not missing, f"property IDs missing for {missing}")
    require(len(set(mapping.values())) == len(mapping), "duplicate property IDs")
    (out_dir/"cover_property_mapping.json").write_text(
        json.dumps(mapping, indent=2)+"\n", encoding="utf-8")
    return mapping

def validate_failure(path, token):
    data = json.loads(path.read_text(encoding="utf-8"))
    statuses = statuses_for_token(data, token)
    require(any(s in {"FAILURE","FAILED"} for s in statuses),
            f"{token}: no exact failing witness; statuses={statuses}")
    for rec in records(data):
        s = str(rec.get("status","")).upper()
        if s in {"FAILURE","FAILED"} and token not in json.dumps(rec, sort_keys=True):
            raise CampaignError(f"{token}: unrelated failing property present")

def run_theorem(label, spec, target_source, common_build, common_proof):
    out = RUN_DIR/label
    out.mkdir()
    harness = PACKAGE_ROOT/"harnesses"/spec["harness"]
    shutil.copy2(harness, out/"harness.c")
    proof_model = out/"proof_model.goto"
    cover_model = out/"cover_model.goto"
    fail_model = out/"fail_control_model.goto"

    for name, extra, model in [
        ("proof", [], proof_model),
        ("cover", ["-DSKILL_REACHABILITY_MODE=1"], cover_model),
        ("fail_control", ["-DSKILL_FAIL_CONTROL=1"], fail_model),
    ]:
        cmd = common_build + extra + [str(harness), str(target_source), "-o", str(model)]
        (out/f"{name}_build_command.txt").write_text(" ".join(map(str,cmd))+"\n", encoding="utf-8")
        cp = run(cmd, cwd=REPO_ROOT, stdout_path=out/f"{name}_build.log",
                 stderr_path=out/f"{name}_build.stderr", check=False)
        (out/f"{name}_build_exit_code.txt").write_text(f"{cp.returncode}\n", encoding="utf-8")
        require(cp.returncode == 0, f"{label}: {name} build exit {cp.returncode}")
        require(model.stat().st_size > 0, f"{label}: {name} model empty")

    for name, model in [("proof",proof_model),("cover",cover_model),("fail_control",fail_model)]:
        run(["goto-instrument","--show-goto-functions",str(model)], cwd=REPO_ROOT,
            stdout_path=out/f"{name}_functions.txt", stderr_path=out/f"{name}_functions.stderr")
        run(["goto-instrument","--show-properties",str(model)], cwd=REPO_ROOT,
            stdout_path=out/f"{name}_properties.txt", stderr_path=out/f"{name}_properties.stderr")
    run(["goto-instrument","--show-symbol-table",str(proof_model)], cwd=REPO_ROOT,
        stdout_path=out/"proof_symbols.txt", stderr_path=out/"proof_symbols.stderr")
    for name, model in [("proof",proof_model),("cover",cover_model)]:
        run(["goto-instrument","--show-loops",str(model)], cwd=REPO_ROOT,
            stdout_path=out/f"{name}_loops.txt", stderr_path=out/f"{name}_loops.stderr")

    run(["python3",str(PACKAGE_ROOT/"runner"/"audit_body_binding.py"),
         str(RUN_DIR/"exposure_report.json"),str(out/"proof_functions.txt"),
         str(out/"cover_functions.txt"),str(out/"fail_control_functions.txt"),
         str(out/"body_binding.json")], cwd=REPO_ROOT)

    log(f"{label}: universal proof")
    proof_cmd = ["timeout","--signal=TERM","--kill-after=15s","300s","cbmc",str(proof_model)] + common_proof
    (out/"proof_command.txt").write_text(" ".join(proof_cmd)+"\n", encoding="utf-8")
    cp = run(proof_cmd, cwd=REPO_ROOT, stdout_path=out/"proof.json",
             stderr_path=out/"proof.stderr", check=False)
    (out/"proof_exit_code.txt").write_text(f"{cp.returncode}\n", encoding="utf-8")
    require(cp.returncode == 0, f"{label}: proof exit {cp.returncode}")
    proof_data = json.loads((out/"proof.json").read_text(encoding="utf-8"))
    for token in spec["assertions"]:
        sts = statuses_for_token(proof_data, token)
        require(sts and not any(s in {"FAILURE","FAILED","UNKNOWN","ERROR"} for s in sts),
                f"{label}: proof token failed {token} {sts}")

    mapping = property_map(cover_model, out, spec["goals"])
    witness_dir = out/"reachability_witnesses"
    witness_dir.mkdir()
    aggregate = []
    command_lines = []
    for i, token in enumerate(spec["goals"],1):
        pid = mapping[token]
        safe = re.sub(r"[^A-Za-z0-9_.-]+","_",token)
        result = witness_dir/f"{i:02d}_{safe}.json"
        stderr = witness_dir/f"{i:02d}_{safe}.stderr"
        command = ["timeout","--signal=TERM","--kill-after=10s","120s","cbmc",str(cover_model),"--function","main","--unwind","4",
                   "--property",pid,"--slice-formula","--json-ui","--trace"]
        rendered = " ".join(command)
        command_lines.append(rendered)
        (witness_dir/f"{i:02d}_{safe}.command.txt").write_text(rendered+"\n", encoding="utf-8")
        log(f"{label}: witness {i}/{len(spec['goals'])} {token}")
        cp = run(command, cwd=REPO_ROOT, stdout_path=result, stderr_path=stderr, check=False)
        (witness_dir/f"{i:02d}_{safe}.exit_code.txt").write_text(
            f"{cp.returncode}\n", encoding="utf-8")
        require(cp.returncode == 10, f"{label}: {token} exit {cp.returncode}, expected 10")
        validate_failure(result, token)
        aggregate.append({"goal":token,"property_id":pid,"status":"WITNESSED",
                          "cbmc_exit_code":10,"result_file":result.relative_to(out).as_posix()})

    (out/"cover_command.txt").write_text("\n".join(command_lines)+"\n", encoding="utf-8")
    (out/"cover.json").write_text(json.dumps(
        {"method":"property-targeted planned-failing assertions","status":"PASS",
         "named_goal_count":len(aggregate),"goals":aggregate}, indent=2)+"\n", encoding="utf-8")
    (out/"cover.stderr").write_text("", encoding="utf-8")
    (out/"cover_exit_code.txt").write_text("0\n", encoding="utf-8")

    log(f"{label}: expected-failure control")
    fail_cmd = ["timeout","--signal=TERM","--kill-after=10s","120s","cbmc",str(fail_model)] + common_proof + ["--trace"]
    (out/"fail_control_command.txt").write_text(" ".join(fail_cmd)+"\n", encoding="utf-8")
    cp = run(fail_cmd, cwd=REPO_ROOT, stdout_path=out/"fail_control.json",
             stderr_path=out/"fail_control.stderr", check=False)
    (out/"fail_control_exit_code.txt").write_text(f"{cp.returncode}\n", encoding="utf-8")
    require(cp.returncode == 10, f"{label}: fail control exit {cp.returncode}")
    fdata = json.loads((out/"fail_control.json").read_text(encoding="utf-8"))
    require(any(s in {"FAILURE","FAILED"} for s in statuses_for_token(fdata,spec["fail_control"])),
            f"{label}: exact fail control not rejected")

    hash_paths = [out/"harness.c",target_source,proof_model,cover_model,fail_model,
                  out/"proof.json",out/"cover.json",out/"fail_control.json",out/"body_binding.json"]
    hash_paths += sorted(witness_dir.glob("*.json"))
    (out/"sha256.txt").write_text("".join(
        f"{sha256(p)}  {p.relative_to(out).as_posix() if out in p.parents else p.name}\n"
        for p in hash_paths), encoding="utf-8")

    success_count = sum(1 for r in records(proof_data)
                        if str(r.get("status","")).upper() in {"SUCCESS","SATISFIED","PASS","PASSED"})
    return success_count, [x["goal"] for x in aggregate]

def main():
    require(not RUN_DIR.exists(), "evidence/run_1 already exists")
    for tool in ("git","cbmc","goto-cc","goto-instrument","gcc","python3","sha256sum","timeout"):
        require(shutil.which(tool), f"missing tool {tool}")
    commit = run(["git","rev-parse","HEAD"], cwd=REPO_ROOT).stdout.strip()
    tree = run(["git","rev-parse","HEAD^{tree}"], cwd=REPO_ROOT).stdout.strip()
    status = run(["git","status","--porcelain=v1","--untracked-files=no"],
                 cwd=REPO_ROOT).stdout.strip()
    require(commit == EXPECTED_COMMIT, f"commit mismatch {commit}")
    require(not status, "tracked worktree not clean")
    require("6.9.0" in run(["cbmc","--version"]).stdout, "CBMC must be 6.9.0")
    require(sys.byteorder == "little", "host must be little-endian")

    RUN_DIR.mkdir(parents=True)
    (RUN_DIR/"RUN_INCOMPLETE.txt").write_text("RUN_INCOMPLETE\n", encoding="utf-8")
    log("===== TARGETED AUTHORITATIVE BARRETT RUN 1 =====")
    log(f"COMMIT={commit}")

    (RUN_DIR/"identity.txt").write_text("\n".join([
        "campaign=MLK_BARRET_REDUCE_SKILL ASSISTED","technical_target=mlk_barrett_reduce",
        "run_index=1",f"utc_started={dt.datetime.now(dt.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}",
        f"repo_root={REPO_ROOT}",f"commit={commit}",f"tree={tree}",
        f"parameter_set={PARAM_SET}",f"namespace_prefix={NAMESPACE_PREFIX}",
        "tracked_git_status=clean",
        "reachability_method=property-targeted planned-failing assertions"])+"\n", encoding="utf-8")
    (RUN_DIR/"environment.json").write_text(json.dumps({
        "platform":sys.platform,"machine":os.uname().machine,"byteorder":sys.byteorder,
        "python":sys.version.split()[0]},indent=2)+"\n", encoding="utf-8")

    for filename, command in {
        "cbmc_version.txt":["cbmc","--version"],"goto_cc_version.txt":["goto-cc","--version"],
        "goto_instrument_version.txt":["goto-instrument","--version"],
        "gcc_version.txt":["gcc","--version"],"python_version.txt":["python3","--version"]}.items():
        cp=run(command)
        (RUN_DIR/filename).write_text((cp.stdout or "")+(cp.stderr or ""), encoding="utf-8")

    poly=REPO_ROOT/"mlkem"/"src"/"poly.c"
    (RUN_DIR/"production_poly_c_sha256.txt").write_text(
        f"{sha256(poly)}  mlkem/src/poly.c\n", encoding="utf-8")
    shutil.copy2(PACKAGE_ROOT/"manifests"/"MANIFEST.sha256",
                 RUN_DIR/"package_manifest_before_run.sha256")
    generated=RUN_DIR/"generated"; generated.mkdir()
    target=generated/"mlk_barrett_reduce_exposed.c"
    run(["python3",str(PACKAGE_ROOT/"runner"/"expose_barrett.py"),"mlkem/src/poly.c",
         str(target),str(RUN_DIR/"exposure_report.json")], cwd=REPO_ROOT)
    run(["python3",str(PACKAGE_ROOT/"runner"/"audit_repository_distinctness.py"),
         str(REPO_ROOT),str(RUN_DIR/"repository_distinctness.json")], cwd=REPO_ROOT)

    common_build=["goto-cc","-std=c90","-I.","-Imlkem","-Imlkem/src",
                  f"-DMLK_CONFIG_PARAMETER_SET={PARAM_SET}",
                  f"-DMLK_CONFIG_NAMESPACE_PREFIX={NAMESPACE_PREFIX}",
                  "-DMLK_CONFIG_NO_ASM=1","-DCBMC"]
    common_proof=["--function","main","--bounds-check","--pointer-check",
                  "--pointer-overflow-check","--signed-overflow-check",
                  "--unsigned-overflow-check","--conversion-check",
                  "--div-by-zero-check","--undefined-shift-check","--unwind","4",
                  "--unwinding-assertions","--slice-formula","--json-ui"]

    theorem_results={}; total_success=0; total_goals=0
    for label,spec in THEOREMS.items():
        success,goals=run_theorem(label,spec,target,common_build,common_proof)
        theorem_results[label]={"proof":"PASS","target_body_binding":"PASS",
            "expected_failure_control":"PASS","successful_property_records":success,
            "selected_claim_mapping":"YES","target_reachability":"YES",
            "assertion_reachability":"YES","assumption_feasibility":"YES",
            "reachability_method":"property-targeted assertion witnesses",
            "witnessed_reachability_goals":goals}
        total_success+=success; total_goals+=len(goals)

    distinct=json.loads((RUN_DIR/"repository_distinctness.json").read_text())
    require(distinct.get("repository_distinctness")=="SUPPORTED","distinctness failed")
    final={"campaign":"MLK_BARRET_REDUCE_SKILL ASSISTED",
           "technical_target":"mlk_barrett_reduce","pinned_commit":EXPECTED_COMMIT,
           "runs_occurred":1,"theorems":theorem_results,
           "successful_property_records_total":total_success,
           "witnessed_named_reachability_goals_total":total_goals,
           "Selected-claim mapping":"YES","Target reachability":"YES",
           "Assertion reachability":"YES","Assumption feasibility":"YES",
           "Evidence completeness":"COMPLETE","Repository distinctness":"SUPPORTED",
           "Contamination":"NONE KNOWN",
           "overall_verdict":"PASS_COMPLETE_SKILL_ASSISTED_MLK_BARRETT_REDUCE_CORPUS"}
    (RUN_DIR/"final_status.json").write_text(json.dumps(final,indent=2)+"\n", encoding="utf-8")
    require(not run(["git","status","--porcelain=v1","--untracked-files=no"],
                    cwd=REPO_ROOT).stdout.strip(),"repo changed during run")
    with (RUN_DIR/"identity.txt").open("a",encoding="utf-8") as h:
        h.write(f"utc_completed={dt.datetime.now(dt.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}\n")
    (RUN_DIR/"RUN_INCOMPLETE.txt").unlink()
    lines=[]
    for p in sorted(RUN_DIR.rglob("*"),key=lambda x:x.as_posix()):
        if p.is_file() and p.name!="RUN_MANIFEST.sha256":
            lines.append(f"{sha256(p)}  {p.relative_to(RUN_DIR).as_posix()}")
    (RUN_DIR/"RUN_MANIFEST.sha256").write_text("\n".join(lines)+"\n", encoding="utf-8")
    log("RUN_1_ACCEPTED")
    log(json.dumps(final,indent=2))
    return 0

if __name__=="__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}",file=sys.stderr,flush=True)
        raise SystemExit(1)
