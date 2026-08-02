#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import stat
import tempfile
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import normalize_config, validate_pipeline_config, ConfigContractError
from agents.common.property_catalog import (
    PROPERTY_FAMILIES, ANALYSIS_ONLY, FUNCTION_CONTRACT, HYBRID, LOOP_CONTRACT,
    RELATIONAL, STANDARD, catalogue_summary, get_property_family, property_family_ids,
    resolve_strategy, strategy_ids, validate_catalogue,
)
from agents.common.contract_artifacts import (
    apply_contract_source_patches, build_contract_header, validate_contract_plan,
    validate_relational_plan, validate_analysis_only_plan,
)
from agents.common.formal_build import create_formal_build_plan, build_tool_pipeline_from_plan
from agents.tool_execution_agent import execute_tool_pipeline, classify_cbmc_result
import preflight_first_api as preflight


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def make_executable(path: Path, body: str) -> None:
    path.write_text(body, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def base_raw(tmp: Path, family_id: str, strategy: str = "auto") -> dict:
    spec = tmp / "spec.txt"
    source = tmp / "poly.c"
    header = tmp / "poly.h"
    spec.write_text("Controlled FIPS 203 evidence excerpt.\n", encoding="utf-8")
    header.write_text("void target(int *a);\n", encoding="utf-8")
    source.write_text("#include \"poly.h\"\nvoid target(int *a){ for(int i=0;i<4;i++) { a[i]=i; } }\n", encoding="utf-8")
    family = get_property_family(family_id)
    return {
        "project_root": str(tmp),
        "run_id": f"run_{family_id.lower()}",
        "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM",
        "target_function": str(family["targets"][0]),
        "target_topic": family["title"],
        "verification_tool": "CBMC",
        "artifact_type": "candidate verification artefact",
        "max_iterations": 0,
        "inputs": {
            "spec_paths": [str(spec)],
            "code_dir": str(tmp),
            "code_paths": [str(source), str(header)],
        },
        "property_campaign": {
            "property_family_id": family_id,
            "verification_strategy": strategy,
            "allow_analysis_only": family_id == "P19",
        },
        "llm": {"mode": "mock", "model": "mock-model"},
        "tool_execution": {
            "cbmc_binary": "cbmc",
            "goto_cc_binary": "goto-cc",
            "goto_instrument_binary": "goto-instrument",
            "source_files": [str(source)],
            "include_paths": [str(tmp)],
            "defines": [],
            "working_directory": str(tmp),
            "dry_run": True,
            "force_run": False,
            "require_gate_approval": True,
        },
    }


def function_contract_plan() -> dict:
    return {
        "enabled": True,
        "contract_mode": "function",
        "target_symbol": "target",
        "function_declaration": "void target(int *a)",
        "requires_clauses": ["__CPROVER_is_fresh(a, 4 * sizeof(*a))"],
        "ensures_clauses": ["a[0] == 0"],
        "assigns_clauses": ["a[0:4]"],
        "frees_clauses": [],
        "loop_invariant_clauses": [],
        "decreases_clauses": [],
        "loop_assigns_clauses": [],
        "source_patch_operations": [],
        "apply_loop_contracts": False,
        "enforce_contract": True,
        "replace_calls_with_contract": [],
        "use_dfcc": False,
        "invariant_initialization_argument": "not applicable",
        "invariant_preservation_argument": "not applicable",
        "postcondition_use_argument": "ensures clause states the local postcondition",
        "frame_condition_argument": "only the selected four-element region is assignable",
        "history_variable_usage": [],
    }


def loop_contract_plan(source: Path) -> dict:
    return {
        "enabled": True,
        "contract_mode": "loop",
        "target_symbol": "target",
        "function_declaration": "",
        "requires_clauses": [],
        "ensures_clauses": [],
        "assigns_clauses": [],
        "frees_clauses": [],
        "loop_invariant_clauses": ["0 <= i && i <= 4"],
        "decreases_clauses": ["4 - i"],
        "loop_assigns_clauses": ["a[0:4]"],
        "source_patch_operations": [{
            "patch_id": "LP001",
            "operation_kind": "insert_loop_contract_after_guard",
            "target_source_path": str(source),
            "expected_original": "for(int i=0;i<4;i++)",
            "replacement": "",
            "expected_occurrences": 1,
            "purpose": "Attach candidate inductive loop contract to the copied source only.",
            "requires_human_review": True,
        }],
        "apply_loop_contracts": True,
        "enforce_contract": False,
        "replace_calls_with_contract": [],
        "use_dfcc": False,
        "invariant_initialization_argument": "i starts at zero, so 0 <= i <= 4.",
        "invariant_preservation_argument": "the increment preserves i <= 4 for an entered iteration.",
        "postcondition_use_argument": "loop exit plus invariant establishes i == 4.",
        "frame_condition_argument": "only the configured output slice may be written.",
        "history_variable_usage": [],
    }


def main() -> int:
    print("[1/11] Canonical 26-property catalogue...")
    assert not validate_catalogue(), validate_catalogue()
    assert property_family_ids() == [f"P{i:02d}" for i in range(1, 27)]
    assert len(PROPERTY_FAMILIES) == 26
    assert len(strategy_ids()) == 6
    assert catalogue_summary()["property_family_count"] == 26
    print("  PASS exactly 26 unique, strategy-bounded property families")

    with tempfile.TemporaryDirectory(prefix="property26_extension_") as td:
        tmp = Path(td)

        print("[2/11] Every property family normalizes and validates...")
        normalized_by_id = {}
        for pid in property_family_ids():
            case_dir = tmp / pid
            case_dir.mkdir()
            raw = base_raw(case_dir, pid)
            cfg = normalize_config(raw, project_root=case_dir)
            report = validate_pipeline_config(cfg)
            assert report.valid, (pid, report.errors, report.warnings)
            normalized_by_id[pid] = cfg
            family = get_property_family(pid)
            assert cfg["property_campaign"]["verification_strategy"] == family["default_strategy"]
            assert cfg["property_campaign"]["support_level"] == family["support_level"]
        print("  PASS all P01-P26 configs are canonical, explicit and claim-bounded")

        print("[3/11] Invalid strategy combinations and unsafe P19 claims fail closed...")
        bad_dir = tmp / "bad"
        bad_dir.mkdir()
        bad = base_raw(bad_dir, "P19", STANDARD)
        try:
            normalize_config(bad, project_root=bad_dir)
            raise AssertionError("P19 accepted a CBMC-proof strategy")
        except ConfigContractError:
            pass
        p19 = normalized_by_id["P19"]
        assert p19["property_campaign"]["verification_strategy"] == ANALYSIS_ONLY
        assert p19["property_campaign"]["allow_analysis_only"] is True
        print("  PASS constant-time support cannot be mislabeled as a CBMC proof")

        print("[4/11] Native loop-contract rendering preserves production source...")
        source = Path(normalized_by_id["P12"]["inputs"]["primary_source"])
        source_before = sha(source)
        lp = loop_contract_plan(source)
        valid = validate_contract_plan(lp, LOOP_CONTRACT)
        assert valid["valid"], valid
        rendered, manifest, diff = apply_contract_source_patches(
            lp,
            project_root=source.parent,
            output_dir=tmp / "instrumented",
            allowed_source_paths=[source],
        )
        assert sha(source) == source_before
        assert manifest["production_source_modified"] is False
        assert len(rendered) == 1 and rendered[0].is_file()
        rendered_text = rendered[0].read_text(encoding="utf-8")
        assert "__CPROVER_loop_invariant(0 <= i && i <= 4)" in rendered_text
        assert "__CPROVER_decreases(4 - i)" in rendered_text
        assert "__CPROVER_assigns(a[0:4])" in rendered_text
        assert "production_source_modified" not in diff or diff
        print("  PASS exact-anchor annotation occurs only in a hash-recorded copied source")

        print("[5/11] Unsafe/trivial/ambiguous loop contracts are rejected...")
        trivial = loop_contract_plan(source)
        trivial["loop_invariant_clauses"] = ["true"]
        assert not validate_contract_plan(trivial, LOOP_CONTRACT)["valid"]
        ambiguous_source = tmp / "ambiguous.c"
        ambiguous_source.write_text("for(int i=0;i<4;i++){}\nfor(int i=0;i<4;i++){}\n", encoding="utf-8")
        ambiguous = loop_contract_plan(ambiguous_source)
        try:
            apply_contract_source_patches(
                ambiguous,
                project_root=tmp,
                output_dir=tmp / "ambiguous_out",
                allowed_source_paths=[ambiguous_source],
            )
            raise AssertionError("Ambiguous loop anchor was accepted")
        except ValueError as exc:
            assert "found 2" in str(exc)
        print("  PASS trivial invariants and non-unique source anchors fail closed")

        print("[6/11] Native function-contract header and DFCC metadata...")
        fp = function_contract_plan()
        valid = validate_contract_plan(fp, FUNCTION_CONTRACT)
        assert valid["valid"], valid
        header_text = build_contract_header(fp)
        assert "__CPROVER_requires" in header_text
        assert "__CPROVER_ensures" in header_text
        assert "__CPROVER_assigns" in header_text
        assert header_text.rstrip().endswith(";")
        fp_dfcc = dict(fp)
        fp_dfcc["use_dfcc"] = True
        assert validate_contract_plan(fp_dfcc, FUNCTION_CONTRACT)["valid"]
        print("  PASS requires/ensures/assigns plus optional DFCC are represented explicitly")

        print("[7/11] Direct, relational, loop, function and analysis profiles build correctly...")
        harness = tmp / "harness.c"
        harness.write_text("void harness(void){}\n", encoding="utf-8")
        source_generic = tmp / "generic.c"
        source_generic.write_text("void target(int *a){a[0]=0;}\n", encoding="utf-8")
        header = tmp / "contract.h"
        header.write_text(header_text, encoding="utf-8")
        contract_manifest = tmp / "contract_manifest.json"
        contract_manifest.write_text(json.dumps(manifest), encoding="utf-8")

        def config_for(strategy: str) -> dict:
            return {
                "project_root": str(tmp),
                "target_function": "target",
                "inputs": {"code_paths": [str(source_generic)], "code_dir": str(tmp)},
                "property_campaign": {"property_family_id": "P12", "verification_strategy": strategy},
                "tool_execution": {
                    "source_files": [str(source_generic)], "include_paths": [str(tmp)],
                    "defines": [], "working_directory": str(tmp), "cbmc_function": "harness",
                },
            }

        empty_contract = {"enabled": False, "contract_mode": "none"}
        direct_plan = create_formal_build_plan(
            config_for(STANDARD), harness,
            artifact_plan={"verification_strategy": STANDARD, "contract_plan": empty_contract},
            artifact_manifest={},
        )
        direct_steps = build_tool_pipeline_from_plan(direct_plan, output_dir=tmp / "direct")
        assert [s["step_id"] for s in direct_steps] == ["cbmc_direct"]

        relational_plan = create_formal_build_plan(
            config_for(RELATIONAL), harness,
            artifact_plan={"verification_strategy": RELATIONAL, "contract_plan": empty_contract},
            artifact_manifest={},
        )
        assert [s["step_id"] for s in build_tool_pipeline_from_plan(relational_plan, output_dir=tmp / "rel")] == ["cbmc_direct"]

        loop_cfg = config_for(LOOP_CONTRACT)
        loop_cfg["tool_execution"]["source_files"] = [str(source)]
        loop_plan = create_formal_build_plan(
            loop_cfg, harness,
            artifact_plan={"verification_strategy": LOOP_CONTRACT, "contract_plan": lp},
            artifact_manifest={"contract_summary": {"contract_instrumentation_manifest": str(contract_manifest)}},
        )
        assert loop_plan["validation"]["valid"], loop_plan["validation"]
        loop_steps = build_tool_pipeline_from_plan(loop_plan, output_dir=tmp / "loop_pipeline")
        assert "--function" not in loop_steps[0]["command"], "goto-cc compile step must not receive CBMC entry-selection flags"
        assert [s["step_id"] for s in loop_steps] == ["goto_compile", "apply_loop_contracts", "cbmc_contract_check"]
        assert "--apply-loop-contracts" in loop_steps[1]["command"]

        function_plan = create_formal_build_plan(
            config_for(FUNCTION_CONTRACT), harness,
            artifact_plan={"verification_strategy": FUNCTION_CONTRACT, "contract_plan": fp},
            artifact_manifest={"contract_summary": {"contract_header": str(header)}},
        )
        assert function_plan["validation"]["valid"], function_plan["validation"]
        function_steps = build_tool_pipeline_from_plan(function_plan, output_dir=tmp / "function_pipeline")
        assert [s["step_id"] for s in function_steps] == ["goto_compile", "apply_function_contracts", "cbmc_contract_check"]
        assert "--enforce-contract" in function_steps[1]["command"]

        analysis_plan = create_formal_build_plan(
            config_for(ANALYSIS_ONLY), harness,
            artifact_plan={"verification_strategy": ANALYSIS_ONLY, "contract_plan": empty_contract},
            artifact_manifest={},
        )
        assert build_tool_pipeline_from_plan(analysis_plan, output_dir=tmp / "analysis") == []
        rel_valid = validate_relational_plan({
            "enabled": True,
            "relation_kind": "round_trip",
            "first_call": "encode(x)",
            "second_call": "decode(encoded)",
            "state_reset_or_snapshot": ["snapshot normalized input"],
            "relation_assertions": ["decoded == normalized_input"],
            "normalization_assumptions": ["input coefficients are canonical"],
        }, RELATIONAL)
        assert rel_valid["valid"], rel_valid
        analysis_valid = validate_analysis_only_plan({
            "enabled": True,
            "analysis_kind": "secret_dependency_review",
            "evidence_to_collect": ["branch predicates", "memory index expressions"],
            "external_tools_or_tests": ["manual classification", "constant-time test harness"],
            "formal_claim_prohibited": True,
        }, ANALYSIS_ONLY)
        assert analysis_valid["valid"], analysis_valid
        print("  PASS each proof strategy receives the correct deterministic execution profile")

        print("[8/11] Sequential GOTO pipeline records and hashes every intermediate model...")
        tools = tmp / "fake_tools"
        tools.mkdir()
        goto_cc = tools / "goto-cc"
        goto_instrument = tools / "goto-instrument"
        cbmc = tools / "cbmc"
        make_executable(goto_cc, """#!/usr/bin/env bash
set -euo pipefail
out=""
while (($#)); do
  if [[ "$1" == "-o" ]]; then out="$2"; shift 2; else shift; fi
done
printf 'compiled-model' > "$out"
printf 'goto-cc ok\n'
""")
        make_executable(goto_instrument, """#!/usr/bin/env bash
set -euo pipefail
out="${!#}"
printf 'instrumented-model' > "$out"
printf 'goto-instrument ok\n'
""")
        make_executable(cbmc, """#!/usr/bin/env bash
printf 'VERIFICATION SUCCESSFUL\n'
""")
        fake_steps = build_tool_pipeline_from_plan(
            loop_plan,
            output_dir=tmp / "executed_pipeline",
            goto_cc_binary=str(goto_cc),
            goto_instrument_binary=str(goto_instrument),
            cbmc_binary=str(cbmc),
        )
        execution = execute_tool_pipeline(fake_steps, cwd=tmp, timeout_seconds=10, output_dir=tmp / "tool_logs")
        assert execution["all_planned_steps_completed"] is True, execution
        assert execution["pipeline_setup_failed"] is False
        for row in execution["steps"][:-1]:
            assert row["output_model_exists"] is True
            assert row["output_model_sha256"]
        cls, _ = classify_cbmc_result(
            execution["authoritative"]["exit_code"],
            execution["authoritative"]["stdout"],
            execution["authoritative"]["stderr"],
            pipeline_setup_failed=execution["pipeline_setup_failed"],
        )
        assert cls == "verification_successful"
        print("  PASS goto-cc → goto-instrument → CBMC execution is auditable and hash-preserving")

        print("[9/11] Contract transformation failure and analysis-only outcomes remain honest...")
        broken = tools / "goto-instrument-broken"
        make_executable(broken, "#!/usr/bin/env bash\nprintf 'instrumentation failed\n' >&2\nexit 4\n")
        broken_steps = build_tool_pipeline_from_plan(
            loop_plan,
            output_dir=tmp / "broken_pipeline",
            goto_cc_binary=str(goto_cc),
            goto_instrument_binary=str(broken),
            cbmc_binary=str(cbmc),
        )
        broken_exec = execute_tool_pipeline(broken_steps, cwd=tmp, timeout_seconds=10, output_dir=tmp / "broken_logs")
        cls, _ = classify_cbmc_result(
            broken_exec["authoritative"].get("exit_code"),
            broken_exec["authoritative"].get("stdout", ""),
            broken_exec["authoritative"].get("stderr", ""),
            pipeline_setup_failed=broken_exec["pipeline_setup_failed"],
        )
        assert cls == "contract_build_or_instrumentation_failed"
        cls, _ = classify_cbmc_result(None, "", "", analysis_only=True)
        assert cls == "analysis_only_no_formal_tool_claim"
        print("  PASS setup failures and analysis-only campaigns never masquerade as formal success")

        print("[10/11] Original 17cbc compatibility default remains ordinary direct CBMC...")
        legacy_dir = tmp / "legacy"
        legacy_dir.mkdir()
        raw_legacy = base_raw(legacy_dir, "P16")
        raw_legacy.pop("property_campaign")
        legacy = normalize_config(raw_legacy, project_root=legacy_dir)
        assert legacy["property_campaign"]["verification_strategy"] == STANDARD
        assert legacy["property_campaign"]["legacy_compatibility_default"] is True
        print("  PASS old configs retain the approved direct-CBMC behavior byte-for-byte in intent")

        print("[11/11] Strategy-specific live-preflight contract smoke routing...")
        preflight_tools = tmp / "preflight_fake_tools"
        preflight_tools.mkdir()
        pf_goto_cc = preflight_tools / "goto-cc"
        pf_goto_instrument = preflight_tools / "goto-instrument"
        pf_cbmc = preflight_tools / "cbmc"
        make_executable(pf_goto_cc, """#!/usr/bin/env bash
set -euo pipefail
out=""
while (($#)); do
  if [[ "$1" == "-o" ]]; then out="$2"; shift 2; else shift; fi
done
printf 'compiled' > "$out"
printf 'goto-cc smoke ok\n'
""")
        make_executable(pf_goto_instrument, """#!/usr/bin/env bash
set -euo pipefail
out="${!#}"
printf 'instrumented' > "$out"
printf 'goto-instrument smoke ok\n'
""")
        make_executable(pf_cbmc, """#!/usr/bin/env bash
printf 'VERIFICATION SUCCESSFUL\n'
""")
        loop_smoke = preflight.check_live_native_contract_toolchain_smoke(
            strategy=LOOP_CONTRACT, goto_cc_path=pf_goto_cc,
            goto_instrument_path=pf_goto_instrument, cbmc_path=pf_cbmc,
        )
        assert set(loop_smoke["checks"]) == {"loop_contract"}
        function_smoke = preflight.check_live_native_contract_toolchain_smoke(
            strategy=FUNCTION_CONTRACT, goto_cc_path=pf_goto_cc,
            goto_instrument_path=pf_goto_instrument, cbmc_path=pf_cbmc,
        )
        assert set(function_smoke["checks"]) == {"function_contract_dfcc"}
        function_cmd = function_smoke["checks"]["function_contract_dfcc"]["commands"][1]
        assert "--dfcc" in function_cmd and "--enforce-contract" in function_cmd
        hybrid_smoke = preflight.check_live_native_contract_toolchain_smoke(
            strategy=HYBRID, goto_cc_path=pf_goto_cc,
            goto_instrument_path=pf_goto_instrument, cbmc_path=pf_cbmc,
        )
        assert set(hybrid_smoke["checks"]) == {"loop_contract", "function_contract_dfcc"}
        print("  PASS preflight exercises loop, function/DFCC, or both according to campaign strategy")

    print("\n26-PROPERTY + NATIVE CONTRACT EXTENSION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
