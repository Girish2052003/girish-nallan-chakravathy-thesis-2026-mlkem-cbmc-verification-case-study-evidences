#!/usr/bin/env python3
from __future__ import annotations

import copy
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import unittest

SKILL_ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = SKILL_ROOT / "scripts" / "run_controlled_mutation.py"


def sha(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: pathlib.Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n", encoding="utf-8")


class MutationRunnerTests(unittest.TestCase):
    maxDiff = None

    def setUp(self):
        self.tmp = pathlib.Path(tempfile.mkdtemp(prefix="mutation-runner-test-"))
        self.workspace = self.tmp / "workspace"
        self.out_parent = self.tmp / "evidence"
        self.bin = self.tmp / "bin"
        (self.workspace / "include").mkdir(parents=True)
        (self.workspace / "src").mkdir(parents=True)
        (self.workspace / "mutations").mkdir(parents=True)
        self.bin.mkdir()
        (self.workspace / "include" / "math_ops.h").write_text(
            "#ifndef MATH_OPS_H\n#define MATH_OPS_H\nint compute(int left, int right);\n#endif\n", encoding="utf-8"
        )
        (self.workspace / "src" / "math_ops.c").write_text(
            '#include "math_ops.h"\nint compute(int left, int right)\n{\n  return left + right;\n}\n', encoding="utf-8"
        )
        (self.workspace / "harness.c").write_text(
            '#include "math_ops.h"\nint main(void)\n{\n  int value = compute(2, 1);\n  __CPROVER_assert(value == 3, "compute property");\n  return 0;\n}\n', encoding="utf-8"
        )
        patch = (
            "diff --git a/src/math_ops.c b/src/math_ops.c\n"
            "index 1111111..2222222 100644\n"
            "--- a/src/math_ops.c\n"
            "+++ b/src/math_ops.c\n"
            "@@ -1,5 +1,5 @@\n"
            " #include \"math_ops.h\"\n"
            " int compute(int left, int right)\n"
            " {\n"
            "-  return left + right;\n"
            "+  return left - right;\n"
            " }\n"
        )
        (self.workspace / "mutations" / "change.patch").write_text(patch, encoding="utf-8")
        self._make_tools()
        self.request = self._base_request()

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def _make_tools(self):
        cbmc = self.bin / "cbmc"
        cbmc.write_text(
            "#!/usr/bin/env python3\n"
            "import json, pathlib, sys, time\n"
            "src = pathlib.Path('src/math_ops.c').read_text()\n"
            "if 'SLEEP_FOREVER' in src:\n"
            "    time.sleep(20)\n"
            "if 'MALFORMED_JSON' in src:\n"
            "    print('not-json')\n"
            "    raise SystemExit(0)\n"
            "if 'TOOL_ERROR' in src:\n"
            "    print(json.dumps({'messageType':'ERROR','messageText':'frontend error'}))\n"
            "    print('tool error', file=sys.stderr)\n"
            "    raise SystemExit(64)\n"
            "status = 'FAILURE' if 'left - right' in src else 'SUCCESS'\n"
            "record = {'result':[{'property':'main.assertion.1','description':'compute property','status':status}]}\n"
            "print(json.dumps(record, sort_keys=True))\n"
            "raise SystemExit(10 if status == 'FAILURE' else 0)\n",
            encoding="utf-8",
        )
        cbmc.chmod(0o755)
        gcc = self.bin / "gcc"
        gcc.write_text(
            "#!/usr/bin/env python3\n"
            "import pathlib, sys, time\n"
            "src = pathlib.Path('src/math_ops.c').read_text()\n"
            "if 'GCC_SLEEP' in src: time.sleep(20)\n"
            "if 'BAD_SYNTAX' in src:\n"
            "    print('syntax error', file=sys.stderr); raise SystemExit(1)\n"
            "raise SystemExit(0)\n",
            encoding="utf-8",
        )
        gcc.chmod(0o755)

    def _base_request(self):
        files = []
        for path, role, allowed in [
            ("harness.c", "HARNESS", False),
            ("include/math_ops.h", "HEADER", False),
            ("src/math_ops.c", "PRODUCTION_SOURCE", True),
        ]:
            files.append({
                "path": path,
                "role": role,
                "expected_sha256": sha(self.workspace / path),
                "mutation_allowed": allowed,
            })
        return {
            "schema_version": "1.0",
            "request_id": "mutation-test-001",
            "experiment_timestamp": "2026-08-03T08:51:00+03:00",
            "target_symbol": "compute",
            "files": files,
            "mutation": {
                "mutation_id": "replace-add-with-subtract",
                "patch_path": "mutations/change.patch",
                "expected_sha256": sha(self.workspace / "mutations/change.patch"),
                "rationale": "Replace addition with subtraction to test whether the selected assertion observes the changed behavior.",
                "expected_effect": "The caller expects the selected property to change from SUCCESS in the baseline to FAILURE in the mutant.",
            },
            "execution": {
                "syntax_check": {
                    "enabled": True,
                    "required": True,
                    "executable": str(self.bin / "gcc"),
                    "sources": ["src/math_ops.c", "harness.c"],
                    "arguments": ["-fsyntax-only", "-std=c90", "-Iinclude"],
                    "timeout_seconds": 5,
                },
                "cbmc": {
                    "executable": str(self.bin / "cbmc"),
                    "sources": ["src/math_ops.c", "harness.c"],
                    "arguments": ["-Iinclude", "--function", "main", "--unwind", "5"],
                    "timeout_seconds": 5,
                    "required": True,
                },
            },
            "expected_transition": {
                "property_id": "main.assertion.1",
                "baseline_allowed_statuses": ["SUCCESS"],
                "mutant_allowed_statuses": ["FAILURE"],
            },
            "notes": "Synthetic generic C fixture.",
        }

    def run_case(self, request=None, name="run", workspace=None):
        request = copy.deepcopy(self.request if request is None else request)
        workspace = self.workspace if workspace is None else workspace
        req_path = self.tmp / f"{name}.json"
        out = self.out_parent / name
        write_json(req_path, request)
        cp = subprocess.run(
            [sys.executable, str(SCRIPT), "--request", str(req_path), "--workspace-root", str(workspace), "--output-dir", str(out)],
            text=True, capture_output=True,
        )
        return cp, out

    def test_01_valid_run(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0, cp.stderr)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["baseline_cbmc_outcome"], "PASS_REPORTED_BY_CBMC")
        self.assertEqual(report["mutant_cbmc_outcome"], "FAIL_REPORTED_BY_CBMC")
        self.assertEqual(report["declared_transition_match"], "MATCHES_CALLER_DECLARATION")
        self.assertEqual(report["execution_completeness_status"], "COMPLETE")

    def test_02_authoritative_unchanged(self):
        before = sha(self.workspace / "src/math_ops.c")
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        self.assertEqual(sha(self.workspace / "src/math_ops.c"), before)
        integrity = json.loads((out / "authoritative_integrity_comparison.json").read_text())
        self.assertTrue(integrity["authoritative_tree_unchanged"])

    def test_03_disposable_cleanup(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        self.assertFalse((out / "._work").exists())
        cleanup = json.loads((out / "cleanup_and_restoration_report.json").read_text())
        self.assertTrue(cleanup["disposable_workspaces_removed"])

    def test_04_patch_exactly_preserved(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        self.assertEqual((out / "applied.patch").read_bytes(), (self.workspace / "mutations/change.patch").read_bytes())

    def test_05_mutated_hash_recorded(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        m = json.loads((out / "mutated_file_manifest.json").read_text())
        self.assertEqual(m["files"][0]["path"], "src/math_ops.c")
        self.assertNotEqual(m["files"][0]["before_sha256"], m["files"][0]["after_sha256"])

    def test_06_optional_syntax_disabled(self):
        r = copy.deepcopy(self.request)
        r["execution"]["syntax_check"] = {"enabled": False, "required": False, "executable": str(self.bin / "gcc"), "sources": [], "arguments": ["-fsyntax-only"], "timeout_seconds": 5}
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 0)
        result = json.loads((out / "baseline/syntax/syntax_check.result.json").read_text())
        self.assertEqual(result["status"], "NOT_REQUESTED")

    def test_07_required_syntax_failure_incomplete(self):
        bad_patch = (self.workspace / "mutations/change.patch").read_text().replace("return left - right;", "BAD_SYNTAX")
        (self.workspace / "mutations/change.patch").write_text(bad_patch)
        r = self._base_request()
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["execution_completeness_status"], "INCOMPLETE")

    def test_08_optional_syntax_failure_warning(self):
        bad_patch = (self.workspace / "mutations/change.patch").read_text().replace("return left - right;", "BAD_SYNTAX")
        (self.workspace / "mutations/change.patch").write_text(bad_patch)
        r = self._base_request()
        r["execution"]["syntax_check"]["required"] = False
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 0)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["execution_completeness_status"], "COMPLETE_WITH_WARNINGS")

    def test_09_transition_differs(self):
        r = copy.deepcopy(self.request)
        r["expected_transition"]["mutant_allowed_statuses"] = ["SUCCESS"]
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 0)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["declared_transition_match"], "DIFFERS_FROM_CALLER_DECLARATION")

    def test_10_transition_absent(self):
        r = copy.deepcopy(self.request)
        r["expected_transition"] = None
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 0)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["declared_transition_match"], "NOT_DECLARED")

    def test_11_patch_hash_mismatch(self):
        r = copy.deepcopy(self.request)
        r["mutation"]["expected_sha256"] = "0" * 64
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        self.assertFalse(out.exists())

    def test_12_source_hash_mismatch(self):
        r = copy.deepcopy(self.request)
        r["files"][0]["expected_sha256"] = "0" * 64
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        self.assertFalse(out.exists())

    def test_13_patch_context_mismatch(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("return left + right;", "return left * right;"))
        r = self._base_request()
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        self.assertTrue((out / "error_report.json").exists())

    def test_14_patch_undeclared_file(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("src/math_ops.c", "src/other.c"))
        r = self._base_request()
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_15_patch_forbidden_file(self):
        p = self.workspace / "mutations/change.patch"
        patch = p.read_text().replace("src/math_ops.c", "harness.c").replace(
            '#include "math_ops.h"\n int compute(int left, int right)\n {\n-  return left + right;\n+  return left - right;\n }\n',
            '#include "math_ops.h"\n int main(void)\n {\n-  int value = compute(2, 1);\n+  int value = compute(2, 2);\n'
        )
        p.write_text(patch)
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_16_file_creation_patch_rejected(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text("--- /dev/null\n+++ b/src/new.c\n@@ -0,0 +1 @@\n+int x;\n")
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_17_rename_patch_rejected(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text("--- a/src/math_ops.c\n+++ b/src/renamed.c\n@@ -1,1 +1,1 @@\n-a\n+b\n")
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_18_binary_patch_rejected(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text("GIT binary patch\n")
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_19_path_traversal_file_rejected(self):
        r = copy.deepcopy(self.request)
        r["files"][0]["path"] = "../harness.c"
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_20_patch_path_traversal_rejected(self):
        r = copy.deepcopy(self.request)
        r["mutation"]["patch_path"] = "../change.patch"
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_21_source_symlink_rejected(self):
        real = self.workspace / "src/math_ops.real.c"
        (self.workspace / "src/math_ops.c").rename(real)
        (self.workspace / "src/math_ops.c").symlink_to(real.name)
        r = copy.deepcopy(self.request)
        r["files"][2]["expected_sha256"] = sha(real)
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_22_patch_symlink_rejected(self):
        real = self.workspace / "mutations/real.patch"
        (self.workspace / "mutations/change.patch").rename(real)
        (self.workspace / "mutations/change.patch").symlink_to(real.name)
        r = copy.deepcopy(self.request)
        r["mutation"]["expected_sha256"] = sha(real)
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_23_output_inside_workspace_rejected(self):
        req_path = self.tmp / "inside.json"
        write_json(req_path, self.request)
        out = self.workspace / "evidence"
        cp = subprocess.run([sys.executable, str(SCRIPT), "--request", str(req_path), "--workspace-root", str(self.workspace), "--output-dir", str(out)], capture_output=True, text=True)
        self.assertEqual(cp.returncode, 2)

    def test_24_existing_output_rejected(self):
        out = self.out_parent / "existing"
        out.mkdir(parents=True)
        req_path = self.tmp / "existing.json"
        write_json(req_path, self.request)
        cp = subprocess.run([sys.executable, str(SCRIPT), "--request", str(req_path), "--workspace-root", str(self.workspace), "--output-dir", str(out)], capture_output=True, text=True)
        self.assertEqual(cp.returncode, 2)

    def test_25_duplicate_files_rejected(self):
        r = copy.deepcopy(self.request)
        r["files"].append(copy.deepcopy(r["files"][0]))
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_26_unknown_request_field_rejected(self):
        r = copy.deepcopy(self.request)
        r["mystery"] = True
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_27_hidden_argument_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["cbmc"]["arguments"].append("@args.txt")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_28_shell_syntax_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["cbmc"]["arguments"].append(";rm")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_29_conflicting_json_ui_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["cbmc"]["arguments"].append("--json-ui")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_30_cbmc_output_option_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["cbmc"]["arguments"].append("--outfile")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_31_wrong_cbmc_basename_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["cbmc"]["executable"] = "/bin/echo"
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_32_wrong_compiler_basename_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["syntax_check"]["executable"] = "/bin/echo"
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_33_compiler_plugin_rejected(self):
        r = copy.deepcopy(self.request)
        r["execution"]["syntax_check"]["arguments"].append("-fplugin=evil.so")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_34_compiler_requires_syntax_only(self):
        r = copy.deepcopy(self.request)
        r["execution"]["syntax_check"]["arguments"].remove("-fsyntax-only")
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_35_cbmc_timeout(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("return left - right;", "return left - right; /* SLEEP_FOREVER */"))
        r = self._base_request()
        r["execution"]["cbmc"]["timeout_seconds"] = 1
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        result = json.loads((out / "mutant/cbmc/cbmc.result.json").read_text())
        self.assertEqual(result["outcome"], "TIMEOUT")

    def test_36_malformed_json(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("return left - right;", "return left - right; /* MALFORMED_JSON */"))
        r = self._base_request()
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        result = json.loads((out / "mutant/cbmc/cbmc.result.json").read_text())
        self.assertEqual(result["outcome"], "UNPARSEABLE_JSON")

    def test_37_tool_error(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("return left - right;", "return left - right; /* TOOL_ERROR */"))
        r = self._base_request()
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 2)
        result = json.loads((out / "mutant/cbmc/cbmc.result.json").read_text())
        self.assertEqual(result["outcome"], "TOOL_ERROR")

    def test_38_exact_cbmc_argv_same_except_workspace(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        b = json.loads((out / "baseline/cbmc/cbmc.argv.json").read_text())
        m = json.loads((out / "mutant/cbmc/cbmc.argv.json").read_text())
        self.assertEqual(b, m)
        self.assertIn("--json-ui", b)

    def test_39_byte_reproducibility(self):
        cp1, out1 = self.run_case(name="repro1")
        cp2, out2 = self.run_case(name="repro2")
        self.assertEqual(cp1.returncode, 0)
        self.assertEqual(cp2.returncode, 0)
        files1 = {p.relative_to(out1).as_posix(): p.read_bytes() for p in out1.rglob("*") if p.is_file()}
        files2 = {p.relative_to(out2).as_posix(): p.read_bytes() for p in out2.rglob("*") if p.is_file()}
        self.assertEqual(files1, files2)

    def test_40_artifact_manifest_hashes(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        manifest = json.loads((out / "controlled_mutation_artifact_manifest.json").read_text())
        for item in manifest["files"]:
            self.assertEqual(item["sha256"], sha(out / item["path"]))

    def test_41_raw_evidence_preserved(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        self.assertIn("SUCCESS", (out / "baseline/cbmc/cbmc.stdout.json").read_text())
        self.assertIn("FAILURE", (out / "mutant/cbmc/cbmc.stdout.json").read_text())

    def test_42_caller_declarations_preserved(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["caller_supplied_rationale"], self.request["mutation"]["rationale"])
        self.assertEqual(report["caller_supplied_expected_effect"], self.request["mutation"]["expected_effect"])

    def test_43_forbidden_scientific_verdicts_absent(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        text = "\n".join(p.read_text(errors="ignore") for p in out.rglob("*") if p.is_file())
        for forbidden in ["PROOF_VALID", "IMPLEMENTATION_CORRECT", "MUTANT_KILLED", "SCIENTIFICALLY_ACCEPTED"]:
            self.assertNotIn(forbidden, text)

    def test_44_generic_non_mlkem_target(self):
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        canonical = json.loads((out / "canonical_request.json").read_text())
        self.assertEqual(canonical["target_symbol"], "compute")
        self.assertNotIn("mlkem", json.dumps(canonical).lower())

    def test_45_no_patch_or_git_apply_subprocess(self):
        source = SCRIPT.read_text()
        self.assertNotIn("git apply", source)
        self.assertNotIn("['patch'", source)
        self.assertNotIn('"patch",', source)
        self.assertNotIn("shell=True", source)
        self.assertNotIn("os.system", source)

    def test_46_no_network_or_model_calls(self):
        source = SCRIPT.read_text()
        for token in ["requests.", "urllib", "socket.", "openai", "anthropic", "http://", "https://"]:
            self.assertNotIn(token, source)

    def test_47_patch_must_end_newline(self):
        p = self.workspace / "mutations/change.patch"
        p.write_bytes(p.read_bytes().rstrip(b"\n"))
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_48_patch_noop_rejected(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(
            "--- a/src/math_ops.c\n+++ b/src/math_ops.c\n@@ -1,1 +1,1 @@\n-#include \"math_ops.h\"\n+#include \"math_ops.h\"\n"
        )
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_49_duplicate_patch_sections_rejected(self):
        p = self.workspace / "mutations/change.patch"
        original = p.read_text()
        p.write_text(original + original)
        r = self._base_request()
        cp, _ = self.run_case(r)
        self.assertEqual(cp.returncode, 2)

    def test_50_required_cbmc_false_allows_warning(self):
        p = self.workspace / "mutations/change.patch"
        p.write_text(p.read_text().replace("return left - right;", "return left - right; /* TOOL_ERROR */"))
        r = self._base_request()
        r["execution"]["cbmc"]["required"] = False
        cp, out = self.run_case(r)
        self.assertEqual(cp.returncode, 0)
        report = json.loads((out / "comparison_report.json").read_text())
        self.assertEqual(report["execution_completeness_status"], "COMPLETE_WITH_WARNINGS")

    def test_51_json_schema_validation(self):
        import jsonschema
        cp, out = self.run_case()
        self.assertEqual(cp.returncode, 0)
        refs = SKILL_ROOT / "references"
        pairs = [
            ("INPUT_SCHEMA.json", out / "canonical_request.json"),
            ("AUTHORITATIVE_MANIFEST_SCHEMA.json", out / "authoritative_manifest.before.json"),
            ("AUTHORITATIVE_MANIFEST_SCHEMA.json", out / "authoritative_manifest.after.json"),
            ("INTEGRITY_SCHEMA.json", out / "authoritative_integrity_comparison.json"),
            ("PATCH_INPUT_MANIFEST_SCHEMA.json", out / "patch_input_manifest.json"),
            ("PATCH_APPLICATION_SCHEMA.json", out / "patch_application_report.json"),
            ("MUTATED_FILE_MANIFEST_SCHEMA.json", out / "mutated_file_manifest.json"),
            ("SYNTAX_RESULT_SCHEMA.json", out / "baseline/syntax/syntax_check.result.json"),
            ("SYNTAX_RESULT_SCHEMA.json", out / "mutant/syntax/syntax_check.result.json"),
            ("CBMC_RESULT_SCHEMA.json", out / "baseline/cbmc/cbmc.result.json"),
            ("CBMC_RESULT_SCHEMA.json", out / "mutant/cbmc/cbmc.result.json"),
            ("COMPARISON_SCHEMA.json", out / "comparison_report.json"),
            ("CLEANUP_SCHEMA.json", out / "cleanup_and_restoration_report.json"),
            ("ARTIFACT_MANIFEST_SCHEMA.json", out / "controlled_mutation_artifact_manifest.json"),
        ]
        for schema_name, data_path in pairs:
            schema = json.loads((refs / schema_name).read_text())
            data = json.loads(data_path.read_text())
            jsonschema.Draft202012Validator(schema).validate(data)

    def test_52_schema_files_are_valid_draft_2020_12(self):
        import jsonschema
        for path in (SKILL_ROOT / "references").glob("*_SCHEMA.json"):
            schema = json.loads(path.read_text())
            jsonschema.Draft202012Validator.check_schema(schema)


if __name__ == "__main__":
    unittest.main(verbosity=2)
