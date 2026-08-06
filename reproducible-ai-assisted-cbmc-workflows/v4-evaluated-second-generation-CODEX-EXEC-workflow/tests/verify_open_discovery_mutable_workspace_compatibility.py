#!/usr/bin/env python3
"""Protect mutable one-folder operation for both targeted and open discovery."""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.master_orchestrator import DEFAULT_AGENTS, MasterOrchestrator


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def prepare_config(template_name: str, workspace: Path, run_id: str) -> Path:
    config = json.loads((ROOT / "configs" / template_name).read_text(encoding="utf-8"))
    config.update({
        "project_root": str(workspace),
        "output_root": "runs",
        "run_id": run_id,
    })
    config_path = workspace / "configs" / f"{run_id}.json"
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
    return config_path


def exercise(template_name: str, run_id: str) -> tuple[set[str], Path]:
    with tempfile.TemporaryDirectory(prefix="mutable_discovery_") as td:
        workspace = Path(td).resolve()
        config_path = prepare_config(template_name, workspace, run_id)
        orchestrator = MasterOrchestrator(
            config_path,
            dry_run=True,
            strict_outputs=True,
            skip_input_checks=True,
        )
        orchestrator.validate_config()
        require(orchestrator.workspace_mode == "mutable_workspace", "Mutable mode was not retained")
        require(orchestrator.run_dir == workspace / "runs" / run_id, "Run directory is not in-tree")
        orchestrator.setup_run_dir()
        stage_names = {p.name for p in (orchestrator.run_dir / "stages").iterdir() if p.is_dir()}
        expected = {"01_master_orchestrator", *(spec.stage_key for spec in DEFAULT_AGENTS.values())}
        require(stage_names == expected, f"Stage layout mismatch: {sorted(stage_names)}")
        require((orchestrator.run_dir / "run_manifest.json").is_file(), "Internal run manifest is missing")
        require((orchestrator.run_dir / "run_config.resolved.json").is_file(), "Resolved config is missing")
        # Return values only; the temporary tree is deliberately disposable.
        return stage_names, orchestrator.run_dir


def main() -> int:
    targeted_stages, _ = exercise("CONFIG_TEMPLATE_MUTABLE_WORKSPACE.json", "targeted_mutable_001")
    open_stages, _ = exercise("CONFIG_TEMPLATE_OPEN_DISCOVERY.json", "open_mutable_001")
    require(targeted_stages == open_stages, "Open mode changed the established run/stage layout")
    print("OPEN DISCOVERY MUTABLE WORKSPACE COMPATIBILITY: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
