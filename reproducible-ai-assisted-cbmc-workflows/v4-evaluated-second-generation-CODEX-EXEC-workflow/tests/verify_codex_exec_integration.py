#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import stat
import tempfile
import time
import sys
from pathlib import Path
from typing import Any, Dict, Optional

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.llm_client import LLMClient, LLMStageRequest
from agents.common.run_layout import RunLayout


def _fake_codex(path: Path, *, mutation: Optional[str] = None, allowed_mutation: bool = False,
                invalid_schema: bool = False, returncode: int = 0, timeout_tree: bool = False,
                tamper_schema: bool = False, mutable_symlink: bool = False) -> None:
    output = {"wrong": True} if invalid_schema else {"ok": True}
    mutation_code = ""
    if mutation:
        mutation_code = f"Path({mutation!r}).parent.mkdir(parents=True, exist_ok=True); Path({mutation!r}).write_text('changed', encoding='utf-8')\n"
    allowed_code = "Path('workspace/allowed.txt').parent.mkdir(parents=True, exist_ok=True); Path('workspace/allowed.txt').write_text('allowed', encoding='utf-8')\n" if allowed_mutation else ""
    timeout_code = ""
    if timeout_tree:
        timeout_code = """
import subprocess, time
subprocess.Popen([sys.executable, '-c', "import time; from pathlib import Path; time.sleep(1.2); Path('scripts/control.py').write_text('late-change')"])
time.sleep(20)
"""
    tamper_code = "Path(args[args.index('--output-schema')+1]).write_text('{}', encoding='utf-8')\n" if tamper_schema else ""
    symlink_code = "Path('workspace/forbidden-link').symlink_to(Path('../scripts/control.py'))\n" if mutable_symlink else ""
    script = f'''#!/usr/bin/env python3
import json, sys
from pathlib import Path
if '--version' in sys.argv:
    print('codex-cli 0.144.4')
    raise SystemExit(0)
args=sys.argv
prompt=sys.stdin.read()
Path('workspace').mkdir(parents=True, exist_ok=True)
Path('workspace/captured_prompt.txt').write_text(prompt, encoding='utf-8')
seen=[]
for line in prompt.splitlines():
    if line.startswith('materialized_path: '):
        p=Path(line.split(': ',1)[1]); seen.append({{'path':str(p),'sha256':__import__('hashlib').sha256(p.read_bytes()).hexdigest()}})
Path('workspace/evidence_seen.json').write_text(json.dumps(seen), encoding='utf-8')
{mutation_code}{allowed_code}{tamper_code}{symlink_code}{timeout_code}
if '--output-last-message' in args:
    out=Path(args[args.index('--output-last-message')+1]); out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({output!r}), encoding='utf-8')
print(json.dumps({{'type':'item.completed'}}), flush=True)
raise SystemExit({returncode})
'''
    path.write_text(script, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IEXEC)


def _root() -> tempfile.TemporaryDirectory[str]:
    return tempfile.TemporaryDirectory(prefix="codex_exec_integration_")


def _prepare(root: Path) -> None:
    for name in ("inputs", "configs", "agents", "tests", "docs", "scripts", "runs", "workspace", "reports", "artifacts"):
        (root / name).mkdir(parents=True, exist_ok=True)
    (root / "inputs" / "x.c").write_text("int x;\n", encoding="utf-8")
    (root / "scripts" / "control.py").write_text("original\n", encoding="utf-8")


def _run(root: Path, *, attach: bool = False, evidence: Optional[Path] = None, timeout: float = 5.0) -> Any:
    layout = RunLayout(root / "runs" / "r1", create=True)
    client = LLMClient({
        "mode": "real",
        "model": "codex-test-model",
        "execution_backend": "codex_exec",
        "codex_binary": str(root / "codex"),
        "codex_working_directory": str(root),
        "codex_stream_terminal": False,
        "codex_timeout_seconds": timeout,
        "codex_expected_version": "0.144.4",
        "codex_require_version_match": True,
        "codex_protected_paths": ["inputs", "configs", "agents", "tests", "docs"],
        "codex_mutable_paths": ["runs", "reports", "workspace", "artifacts"],
        "codex_enforce_change_boundary": True,
        "codex_minimal_environment": True,
        "codex_process_termination_grace_seconds": 0.2,
        "reasoning": {"effort": "high"},
        "attach_files_as_base64": attach,
        "max_retries": 0,
    })
    request = LLMStageRequest(
        stage="02_spec_extraction",
        prompt_text="Return JSON after inspecting every supplied evidence item.",
        output_filename="out.json",
        primary_evidence_files=[evidence] if evidence else [],
        json_schema={
            "type": "object",
            "required": ["ok"],
            "properties": {"ok": {"type": "boolean"}},
        },
    )
    return client.run_stage(layout, request)


def _load(path: str) -> Dict[str, Any]:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def test_success_and_provenance() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", allowed_mutation=True)
        result = _run(root)
        assert result.success, result.to_dict()
        assert (root / "workspace" / "allowed.txt").read_text() == "allowed"
        command = _load(result.validation["command_record"])
        provenance = _load(result.validation["runtime_provenance"])
        assert 'model_reasoning_effort="high"' in command["command"]
        assert provenance["expected_version_match"] is True
        assert provenance["binary_sha256"] == hashlib.sha256((root / "codex").read_bytes()).hexdigest()
        assert result.validation["change_boundary_valid"] is True


def test_true_allowlist_and_rollback() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", mutation="scripts/control.py")
        result = _run(root)
        assert not result.success, result.to_dict()
        assert result.validation["change_boundary_valid"] is False
        assert result.validation["rollback_valid"] is True
        assert (root / "scripts" / "control.py").read_text(encoding="utf-8") == "original\n"
        boundary = _load(result.validation["boundary_record"])
        assert "scripts/control.py" in boundary["unauthorised_changes"]["modified"]


def test_base64_evidence_preservation() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex")
        evidence = root / "inputs" / "evidence.bin"
        evidence.write_bytes(b"\x00ML-KEM-EVIDENCE\xff")
        result = _run(root, attach=True, evidence=evidence)
        assert result.success, result.to_dict()
        manifest = _load(result.validation["input_materialization"])
        seen = json.loads((root / "workspace" / "evidence_seen.json").read_text(encoding="utf-8"))
        expected = hashlib.sha256(evidence.read_bytes()).hexdigest()
        assert manifest["all_input_items_preserved"] is True
        assert manifest["materialized_file_count"] == 1
        assert manifest["files"][0]["sha256"] == expected
        assert seen and seen[0]["sha256"] == expected


def test_schema_and_returncode_fail_closed() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", invalid_schema=True)
        result = _run(root)
        assert not result.success and result.error == "codex_exec_schema_validation_failed"
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", returncode=7)
        result = _run(root)
        assert not result.success and result.error == "codex_exec_failed_returncode_7"


def test_control_evidence_and_mutable_symlink_fail_closed() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", tamper_schema=True)
        result = _run(root)
        assert not result.success and result.validation["control_integrity_valid"] is False
        schema = _load(str(Path(result.validation["command_record"]).parent / "output_schema.json"))
        assert schema.get("required") == ["ok"]
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", mutable_symlink=True)
        result = _run(root)
        assert not result.success and result.validation["mutable_symlink_cleanup_valid"] is True
        assert not (root / "workspace" / "forbidden-link").exists()


def test_timeout_kills_descendants() -> None:
    with _root() as td:
        root = Path(td); _prepare(root); _fake_codex(root / "codex", timeout_tree=True)
        result = _run(root, timeout=0.3)
        assert not result.success and result.error == "codex_exec_timeout"
        time.sleep(1.5)
        assert (root / "scripts" / "control.py").read_text(encoding="utf-8") == "original\n"


def main() -> int:
    test_success_and_provenance()
    test_true_allowlist_and_rollback()
    test_base64_evidence_preservation()
    test_schema_and_returncode_fail_closed()
    test_control_evidence_and_mutable_symlink_fail_closed()
    test_timeout_kills_descendants()
    print("CODEX EXEC CONTROLLED INTEGRATION REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
