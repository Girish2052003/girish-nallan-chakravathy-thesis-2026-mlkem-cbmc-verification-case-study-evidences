from __future__ import annotations

import base64
import hashlib
import json
import os
import re
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import threading
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

try:  # POSIX research target; Windows falls back to an in-process lock.
    import fcntl  # type: ignore
except Exception:  # pragma: no cover - exercised only on non-POSIX systems.
    fcntl = None

_PROCESS_LOCK = threading.Lock()


def _write_json(path: Path, value: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def _discover_project_root(layout: Any) -> Path:
    run_dir = Path(getattr(layout, "run_dir", ".")).resolve()
    candidates = [run_dir, *run_dir.parents]
    for candidate in candidates:
        if (candidate / "agents" / "common" / "llm_client.py").is_file() and (candidate / "configs").is_dir():
            return candidate
    raise ValueError(
        "Unable to discover the workflow root from the run directory. "
        "Set llm.codex_working_directory to an absolute project path."
    )


def _resolve_root(cfg: Any, layout: Any) -> Path:
    configured = cfg.codex_working_directory
    if configured not in (None, "", "."):
        candidate = Path(configured).expanduser()
        if candidate.is_absolute():
            root = candidate.resolve()
        else:
            root = (_discover_project_root(layout) / candidate).resolve()
    else:
        root = _discover_project_root(layout)
    if not root.is_dir():
        raise ValueError(f"Invalid Codex working directory: {root}")
    return root


def _resolve_relative_roots(root: Path, values: Sequence[str], *, label: str) -> List[Path]:
    resolved: List[Path] = []
    for raw in values:
        value = str(raw).strip()
        if not value:
            raise ValueError(f"Empty {label} entry is not permitted")
        candidate = Path(value)
        if candidate.is_absolute():
            raise ValueError(f"Absolute {label} entry is not permitted: {value}")
        target = (root / candidate).resolve()
        if not _is_relative_to(target, root) or target == root:
            raise ValueError(f"{label} entry escapes or covers the project root: {value}")
        resolved.append(target)
    unique = sorted(set(resolved), key=lambda item: (len(item.parts), str(item)))
    minimal: List[Path] = []
    for target in unique:
        if not any(_is_relative_to(target, parent) for parent in minimal):
            minimal.append(target)
    return minimal


def _validate_boundaries(cfg: Any, layout: Any, root: Path) -> Tuple[List[Path], List[Path], List[Path]]:
    mutable = _resolve_relative_roots(root, cfg.codex_mutable_paths, label="codex_mutable_paths")
    if not mutable:
        raise ValueError("codex_mutable_paths must contain at least one controlled output directory")
    protected = _resolve_relative_roots(root, cfg.codex_protected_paths, label="codex_protected_paths")
    for left in mutable:
        for right in protected:
            if _is_relative_to(left, right) or _is_relative_to(right, left):
                raise ValueError(f"Mutable and protected boundaries overlap: {left} versus {right}")
    run_dir = Path(getattr(layout, "run_dir", ".")).resolve()
    if not _is_relative_to(run_dir, root) or not any(_is_relative_to(run_dir, item) for item in mutable):
        raise ValueError(
            f"Run directory must be inside the project root and a declared mutable path: {run_dir}"
        )
    add_dirs: List[Path] = []
    for raw in cfg.codex_add_dirs:
        candidate = Path(raw).expanduser()
        target = candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
        if not _is_relative_to(target, root):
            raise ValueError(f"External --add-dir is forbidden by the controlled boundary: {target}")
        if not any(_is_relative_to(target, item) for item in mutable):
            raise ValueError(f"--add-dir must lie inside a declared mutable path: {target}")
        add_dirs.append(target)
    return mutable, protected, add_dirs


def _mutable_symlink_violations(mutable_roots: Sequence[Path]) -> List[str]:
    violations: List[str] = []
    for mutable_root in mutable_roots:
        if not mutable_root.exists():
            continue
        if mutable_root.is_symlink():
            violations.append(str(mutable_root))
            continue
        for directory, dirnames, filenames in os.walk(mutable_root, followlinks=False):
            base = Path(directory)
            for name in [*dirnames, *filenames]:
                candidate = base / name
                if candidate.is_symlink():
                    violations.append(str(candidate))
    return sorted(set(violations))


def _remove_mutable_symlinks(paths: Sequence[str]) -> Dict[str, Any]:
    errors: List[str] = []
    for raw in paths:
        try:
            Path(raw).unlink(missing_ok=True)
        except Exception as exc:
            errors.append(f"remove {raw}: {type(exc).__name__}: {exc}")
    remaining = [raw for raw in paths if Path(raw).is_symlink()]
    return {"attempted": bool(paths), "valid": not errors and not remaining,
            "errors": errors, "remaining": remaining}


def _restore_control_integrity(expected: Mapping[Path, bytes]) -> Dict[str, Any]:
    changed: List[str] = []
    errors: List[str] = []
    for path, payload in expected.items():
        observed = path.read_bytes() if path.is_file() else None
        if observed == payload:
            continue
        changed.append(str(path))
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            if path.exists() or path.is_symlink():
                _remove_path(path)
            path.write_bytes(payload)
        except Exception as exc:
            errors.append(f"restore {path}: {type(exc).__name__}: {exc}")
    remaining = [str(path) for path, payload in expected.items()
                 if not path.is_file() or path.read_bytes() != payload]
    return {
        "valid": not changed,
        "changed": changed,
        "restore_attempted": bool(changed),
        "restore_valid": not errors and not remaining,
        "restore_errors": errors,
        "post_restore_changes": remaining,
    }


def _under_any(path: Path, roots: Sequence[Path]) -> bool:
    return any(path == root or _is_relative_to(path, root) for root in roots)


def _entry_record(path: Path) -> Dict[str, Any]:
    info = path.lstat()
    mode = stat.S_IMODE(info.st_mode)
    if path.is_symlink():
        return {"type": "symlink", "target": os.readlink(path), "mode": mode}
    if path.is_file():
        return {"type": "file", "sha256": _sha256_file(path), "size_bytes": info.st_size, "mode": mode}
    if path.is_dir():
        return {"type": "directory", "mode": mode}
    return {"type": "other", "mode": mode, "size_bytes": info.st_size}


def _workspace_snapshot(root: Path, mutable_roots: Sequence[Path]) -> Dict[str, Dict[str, Any]]:
    snapshot: Dict[str, Dict[str, Any]] = {}
    stack = [root]
    while stack:
        directory = stack.pop()
        for entry in sorted(os.scandir(directory), key=lambda item: item.name):
            path = Path(entry.path)
            if _under_any(path, mutable_roots):
                continue
            relative = path.relative_to(root).as_posix()
            snapshot[relative] = _entry_record(path)
            if entry.is_dir(follow_symlinks=False):
                stack.append(path)
            elif entry.is_symlink():
                target = path.resolve(strict=False)
                if not _is_relative_to(target, root):
                    raise ValueError(f"External symlink outside mutable paths is forbidden: {relative} -> {target}")
    return snapshot


def _snapshot_diff(
    before: Mapping[str, Mapping[str, Any]], after: Mapping[str, Mapping[str, Any]]
) -> Dict[str, List[str]]:
    keys = set(before) | set(after)
    added = sorted(key for key in keys if key not in before)
    deleted = sorted(key for key in keys if key not in after)
    modified = sorted(key for key in keys if key in before and key in after and before[key] != after[key])
    return {"added": added, "deleted": deleted, "modified": modified,
            "all_changes": sorted(set(added) | set(deleted) | set(modified))}


def _copy_guard_tree(root: Path, mutable_roots: Sequence[Path], backup: Path) -> None:
    backup.mkdir(parents=True, exist_ok=True)
    for relative, record in _workspace_snapshot(root, mutable_roots).items():
        source = root / relative
        destination = backup / relative
        if record["type"] == "directory":
            destination.mkdir(parents=True, exist_ok=True)
            os.chmod(destination, int(record["mode"]))
        elif record["type"] == "file":
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination, follow_symlinks=False)
        elif record["type"] == "symlink":
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.symlink_to(str(record["target"]))


def _remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink(missing_ok=True)
    elif path.is_dir():
        shutil.rmtree(path)


def _restore_guard_tree(
    root: Path,
    backup: Path,
    before: Mapping[str, Mapping[str, Any]],
    diff: Mapping[str, Sequence[str]],
) -> Dict[str, Any]:
    errors: List[str] = []
    changed = sorted(set(diff.get("all_changes", [])), key=lambda value: (value.count("/"), value), reverse=True)
    for relative in changed:
        target = root / relative
        try:
            _remove_path(target)
        except Exception as exc:
            errors.append(f"remove {relative}: {type(exc).__name__}: {exc}")
    restore = sorted(
        (relative for relative in changed if relative in before),
        key=lambda value: (value.count("/"), value),
    )
    for relative in restore:
        source = backup / relative
        target = root / relative
        record = before[relative]
        try:
            if record["type"] == "directory":
                target.mkdir(parents=True, exist_ok=True)
                os.chmod(target, int(record["mode"]))
            elif record["type"] == "file":
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target, follow_symlinks=False)
            elif record["type"] == "symlink":
                target.parent.mkdir(parents=True, exist_ok=True)
                target.symlink_to(str(record["target"]))
        except Exception as exc:
            errors.append(f"restore {relative}: {type(exc).__name__}: {exc}")
    return {"attempted": bool(changed), "valid": not errors, "errors": errors}


def _render_codex_input(api_input: Sequence[Mapping[str, Any]], out_dir: Path) -> Tuple[str, Dict[str, Any]]:
    blocks: List[str] = []
    files_dir = out_dir / "input_files"
    manifest_files: List[Dict[str, Any]] = []
    file_index = 0
    for message in api_input:
        role = str(message.get("role") or "user")
        blocks.append(f"[MESSAGE ROLE: {role}]")
        for item in message.get("content", []):
            item_type = item.get("type")
            if item_type == "input_text":
                blocks.append(str(item.get("text") or ""))
                continue
            if item_type != "input_file":
                raise ValueError(f"Unsupported Codex input item type: {item_type!r}")
            file_index += 1
            filename = Path(str(item.get("filename") or f"input_{file_index}.bin")).name
            file_data = str(item.get("file_data") or "")
            if ";base64," not in file_data:
                raise ValueError(f"Unsupported input_file transport for {filename}: expected data URI")
            header, payload = file_data.split(";base64,", 1)
            raw = base64.b64decode(payload, validate=True)
            target = files_dir / f"{file_index:03d}_{filename}"
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            record = {
                "index": file_index,
                "filename": filename,
                "materialized_path": str(target),
                "mime_type": header.removeprefix("data:"),
                "size_bytes": len(raw),
                "sha256": hashlib.sha256(raw).hexdigest(),
            }
            manifest_files.append(record)
            blocks.append(
                "\n".join([
                    "[RAW PRIMARY EVIDENCE FILE]",
                    f"filename: {filename}",
                    f"materialized_path: {target}",
                    f"size_bytes: {len(raw)}",
                    f"sha256: {record['sha256']}",
                    "Instruction: inspect the complete file at materialized_path; do not infer its content from the name.",
                ])
            )
    blocks.append("[CONTROL PLANE]\nReturn exactly one JSON object matching the supplied schema.")
    prompt = "\n\n".join(blocks)
    manifest = {
        "schema_version": "codex_input_materialization.v1",
        "input_message_count": len(api_input),
        "materialized_file_count": len(manifest_files),
        "files": manifest_files,
        "prompt_bytes": len(prompt.encode("utf-8")),
        "prompt_sha256": hashlib.sha256(prompt.encode("utf-8")).hexdigest(),
        "all_input_items_preserved": True,
    }
    return prompt, manifest


def _resolve_binary(value: str) -> Path:
    located = shutil.which(value)
    candidate = Path(located or value).expanduser()
    if not candidate.is_file():
        raise FileNotFoundError(f"Codex CLI not found: {value}")
    return candidate.resolve()


def _runtime_provenance(binary: Path, expected_version: Optional[str]) -> Dict[str, Any]:
    completed = subprocess.run(
        [str(binary), "--version"], capture_output=True, text=True, timeout=15, check=False
    )
    output = (completed.stdout or completed.stderr).strip()
    detected_match = re.search(r"(?<![0-9])([0-9]+\.[0-9]+\.[0-9]+)(?![0-9])", output)
    detected_version = detected_match.group(1) if detected_match else None
    version_match = expected_version is None or detected_version == expected_version
    return {
        "schema_version": "codex_runtime_provenance.v1",
        "binary_path": str(binary),
        "binary_size_bytes": binary.stat().st_size,
        "binary_sha256": _sha256_file(binary),
        "version_command": [str(binary), "--version"],
        "version_returncode": completed.returncode,
        "version_output": output,
        "detected_version": detected_version,
        "expected_version": expected_version,
        "expected_version_match": version_match,
        "python_version": sys.version,
        "platform": sys.platform,
        "os_name": os.name,
    }


def _toml_scalar(value: str) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def _build_command(
    cfg: Any,
    binary: Path,
    root: Path,
    schema_path: Path,
    final_path: Path,
    add_dirs: Sequence[Path],
) -> List[str]:
    command = [str(binary), "exec", "--json", "--color", "never"]
    if cfg.codex_strict_config:
        command.append("--strict-config")
    if cfg.codex_ephemeral:
        command.append("--ephemeral")
    command += ["--sandbox", cfg.codex_sandbox, "--cd", str(root)]
    command += ["--output-schema", str(schema_path), "--output-last-message", str(final_path)]
    if not cfg.model or cfg.model.startswith("SET_TO_") or cfg.model == "REPLACE_WITH_AVAILABLE_MODEL":
        raise ValueError("A concrete Codex model identifier is required for a real codex_exec stage")
    command += ["--model", cfg.model]
    if cfg.codex_skip_git_repo_check:
        command.append("--skip-git-repo-check")
    if cfg.codex_ignore_user_config:
        command.append("--ignore-user-config")
    if cfg.codex_ignore_rules:
        command.append("--ignore-rules")
    command += ["--config", f"approval_policy={_toml_scalar(cfg.codex_approval_policy)}"]
    if cfg.reasoning_mode:
        raise ValueError(
            "reasoning_mode is not a supported Codex CLI 0.144.4 configuration key; "
            "omit it or use the Responses API backend."
        )
    if cfg.reasoning_effort:
        command += ["--config", f"model_reasoning_effort={_toml_scalar(cfg.reasoning_effort)}"]
    if cfg.reasoning_summary:
        command += ["--config", f"model_reasoning_summary={_toml_scalar(cfg.reasoning_summary)}"]
    if cfg.text_verbosity:
        command += ["--config", f"model_verbosity={_toml_scalar(cfg.text_verbosity)}"]
    for path in add_dirs:
        command += ["--add-dir", str(path)]
    command.append("-")
    return command


def _child_environment(cfg: Any) -> Dict[str, str]:
    if not cfg.codex_minimal_environment:
        return os.environ.copy()
    allowed = set(cfg.codex_environment_allowlist)
    allowed.add(str(cfg.api_key_env))
    environment = {key: value for key, value in os.environ.items() if key in allowed}
    environment.setdefault("PATH", os.environ.get("PATH", ""))
    return environment


def _terminate_process_tree(proc: subprocess.Popen[str], grace_seconds: float) -> str:
    if proc.poll() is not None:
        return "already_exited"
    if os.name == "posix":
        try:
            os.killpg(proc.pid, signal.SIGTERM)
            proc.wait(timeout=max(0.1, grace_seconds))
            return "posix_process_group_sigterm"
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
            return "posix_process_group_sigkill"
        except Exception:
            proc.kill()
            proc.wait()
            return "direct_kill_fallback"
    if os.name == "nt":  # pragma: no cover - target environment is Ubuntu.
        try:
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(proc.pid)], check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            proc.wait(timeout=max(0.1, grace_seconds))
            return "windows_taskkill_tree"
        except Exception:
            proc.kill()
            proc.wait()
            return "direct_kill_fallback"
    proc.kill()
    proc.wait()
    return "direct_kill_fallback"


def _run_process(
    command: Sequence[str],
    *,
    root: Path,
    prompt: str,
    events_path: Path,
    stderr_path: Path,
    timeout_seconds: float,
    stream_terminal: bool,
    stage: str,
    environment: Mapping[str, str],
    termination_grace_seconds: float,
) -> Dict[str, Any]:
    started = time.monotonic()
    timed_out = False
    termination_method = "normal_exit"
    with tempfile.TemporaryDirectory(prefix="codex_stream_capture_") as capture_dir:
        capture_root = Path(capture_dir)
        captured_events = capture_root / "events.jsonl"
        captured_stderr = capture_root / "stderr.log"
        with captured_events.open("w", encoding="utf-8") as stdout_file, captured_stderr.open(
            "w", encoding="utf-8"
        ) as stderr_file:
            proc = subprocess.Popen(
                list(command), cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                text=True, bufsize=1, env=dict(environment), start_new_session=(os.name == "posix"),
            )
            assert proc.stdin and proc.stdout and proc.stderr
            proc.stdin.write(prompt)
            proc.stdin.close()

            def pump(source: Any, destination: Any, terminal: Any) -> None:
                for line in iter(source.readline, ""):
                    destination.write(line)
                    destination.flush()
                    if stream_terminal:
                        terminal.write(f"[CODEX:{stage}] {line}")
                        terminal.flush()

            threads = [
                threading.Thread(target=pump, args=(proc.stdout, stdout_file, sys.stdout), daemon=True),
                threading.Thread(target=pump, args=(proc.stderr, stderr_file, sys.stderr), daemon=True),
            ]
            for thread in threads:
                thread.start()
            try:
                returncode = proc.wait(timeout=timeout_seconds)
            except subprocess.TimeoutExpired:
                timed_out = True
                termination_method = _terminate_process_tree(proc, termination_grace_seconds)
                returncode = proc.returncode if proc.returncode is not None else -9
            for thread in threads:
                thread.join(timeout=5)
        events_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(captured_events, events_path)
        shutil.copy2(captured_stderr, stderr_path)
    return {
        "returncode": returncode,
        "timed_out": timed_out,
        "termination_method": termination_method,
        "duration_seconds": round(time.monotonic() - started, 3),
    }


@contextmanager
def _execution_lock(root: Path, mutable_roots: Sequence[Path]) -> Iterable[Dict[str, Any]]:
    lock_root = mutable_roots[0]
    lock_root.mkdir(parents=True, exist_ok=True)
    lock_path = lock_root / ".codex_exec_control.lock"
    with _PROCESS_LOCK:
        with lock_path.open("a+", encoding="utf-8") as handle:
            method = "thread_lock_only"
            if fcntl is not None:
                fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
                method = "thread_lock_plus_posix_flock"
            try:
                yield {"path": str(lock_path), "method": method}
            finally:
                if fcntl is not None:
                    fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def _attempt_paths(base: Path, attempt: int) -> Dict[str, Path]:
    directory = base / f"attempt_{attempt:02d}"
    directory.mkdir(parents=True, exist_ok=True)
    return {
        "dir": directory,
        "final": directory / "last_message.json",
        "events": directory / "events.jsonl",
        "stderr": directory / "stderr.log",
        "command": directory / "command.json",
        "boundary": directory / "change_boundary.json",
    }


def _copy_latest_records(paths: Mapping[str, Path], out_dir: Path) -> None:
    for key, filename in (("final", "last_message.json"), ("events", "events.jsonl"),
                          ("stderr", "stderr.log"), ("command", "command.json"),
                          ("boundary", "change_boundary.json")):
        source = paths[key]
        if source.exists():
            shutil.copy2(source, out_dir / filename)


def _execute_codex_attempt(
    *,
    cfg: Any,
    request: Any,
    stage: str,
    attempt: int,
    binary: Path,
    root: Path,
    mutable_roots: Sequence[Path],
    protected_roots: Sequence[Path],
    add_dirs: Sequence[Path],
    schema_path: Path,
    provenance_path: Path,
    out_dir: Path,
    prompt: str,
    control_payloads: Mapping[Path, bytes],
    environment: Mapping[str, str],
    lock_record: Mapping[str, Any],
    validate_json_schema: Any,
    extract_json_object: Any,
    utc_now_iso: Any,
) -> Dict[str, Any]:
    paths = _attempt_paths(out_dir, attempt)
    command = _build_command(cfg, binary, root, schema_path, paths["final"], add_dirs)
    command_record = {
        "schema_version": "codex_exec_command.v2",
        "created_utc": utc_now_iso(),
        "stage": stage,
        "attempt": attempt,
        "command": command,
        "cwd": str(root),
        "stdin_bytes": len(prompt.encode("utf-8")),
        "stdin_sha256": hashlib.sha256(prompt.encode("utf-8")).hexdigest(),
        "sandbox": cfg.codex_sandbox,
        "approval_policy": cfg.codex_approval_policy,
        "model": cfg.model,
        "reasoning_effort": cfg.reasoning_effort,
        "reasoning_summary": cfg.reasoning_summary,
        "text_verbosity": cfg.text_verbosity,
        "protected_paths": [str(path.relative_to(root)) for path in protected_roots],
        "mutable_allowlist": [str(path.relative_to(root)) for path in mutable_roots],
        "add_dirs": [str(path) for path in add_dirs],
        "runtime_provenance": str(provenance_path),
        "environment_variable_names": sorted(environment),
        "execution_lock": dict(lock_record),
    }
    _write_json(paths["command"], command_record)
    with tempfile.TemporaryDirectory(prefix="codex_workspace_guard_") as temporary:
        backup = Path(temporary) / "backup"
        before = _workspace_snapshot(root, mutable_roots)
        _copy_guard_tree(root, mutable_roots, backup)
        process_result = _run_process(
            command,
            root=root,
            prompt=prompt,
            events_path=paths["events"],
            stderr_path=paths["stderr"],
            timeout_seconds=cfg.codex_timeout_seconds,
            stream_terminal=cfg.codex_stream_terminal,
            stage=stage,
            environment=environment,
            termination_grace_seconds=cfg.codex_process_termination_grace_seconds,
        )
        _write_json(paths["command"], command_record)
        control_integrity = _restore_control_integrity(control_payloads)
        mutable_symlinks = _mutable_symlink_violations(mutable_roots)
        symlink_cleanup = _remove_mutable_symlinks(mutable_symlinks)
        after = _workspace_snapshot(root, mutable_roots)
        diff = _snapshot_diff(before, after)
        mutable_boundary_valid = not mutable_symlinks
        boundary_valid = bool(
            (not diff["all_changes"] or not cfg.codex_enforce_change_boundary)
            and mutable_boundary_valid
            and control_integrity["valid"]
        )
        rollback: Dict[str, Any] = {"attempted": False, "valid": True, "errors": []}
        if diff["all_changes"] and cfg.codex_enforce_change_boundary:
            rollback = _restore_guard_tree(root, backup, before, diff)
            confirmed = _snapshot_diff(before, _workspace_snapshot(root, mutable_roots))
            rollback["post_restore_changes"] = confirmed["all_changes"]
            rollback["valid"] = bool(rollback["valid"] and not confirmed["all_changes"])
        boundary_record = {
            "schema_version": "codex_change_boundary.v2",
            "created_utc": utc_now_iso(),
            "enforced": cfg.codex_enforce_change_boundary,
            "valid": boundary_valid,
            "policy": "all workspace changes are forbidden unless the path is inside codex_mutable_paths",
            "mutable_allowlist": [str(path.relative_to(root)) for path in mutable_roots],
            "protected_paths": [str(path.relative_to(root)) for path in protected_roots],
            "unauthorised_changes": diff,
            "mutable_symlink_policy": {
                "valid": mutable_boundary_valid,
                "forbidden_symlinks": mutable_symlinks,
                "cleanup": symlink_cleanup,
            },
            "execution_control_integrity": control_integrity,
            "rollback": rollback,
        }
        _write_json(paths["boundary"], boundary_record)

    raw = paths["final"].read_text(encoding="utf-8", errors="replace") if paths["final"].exists() else ""
    raw_bytes = raw.encode("utf-8")
    output_size_valid = len(raw_bytes) <= int(cfg.codex_max_final_output_bytes)
    parsed = None
    parse_error = None
    try:
        parsed = extract_json_object(raw, strict=cfg.strict_json_object_only)
    except Exception as exc:
        parse_error = f"{type(exc).__name__}: {exc}"
    schema_result = (
        validate_json_schema(parsed, request.json_schema)
        if parsed is not None
        else {"valid": False, "errors": [parse_error or "No final JSON object was produced"]}
    )
    security_failure = bool(
        (diff["all_changes"] and cfg.codex_enforce_change_boundary)
        or mutable_symlinks
        or not control_integrity["valid"]
    )
    success = bool(
        process_result["returncode"] == 0
        and not process_result["timed_out"]
        and boundary_valid
        and boundary_record["rollback"]["valid"]
        and symlink_cleanup["valid"]
        and control_integrity["restore_valid"]
        and output_size_valid
        and schema_result.get("valid")
    )
    record = {
        "attempt": attempt,
        **process_result,
        "success": success,
        "security_failure": security_failure,
        "boundary_valid": boundary_valid,
        "rollback_valid": boundary_record["rollback"]["valid"],
        "mutable_symlink_cleanup_valid": symlink_cleanup["valid"],
        "control_integrity_valid": control_integrity["valid"],
        "control_integrity_restore_valid": control_integrity["restore_valid"],
        "output_size_bytes": len(raw_bytes),
        "output_size_limit_bytes": int(cfg.codex_max_final_output_bytes),
        "output_size_valid": output_size_valid,
        "schema_validation": schema_result,
        "parse_error": parse_error,
        "paths": {key: str(value) for key, value in paths.items() if key != "dir"},
        "parsed": parsed,
    }
    _copy_latest_records(paths, out_dir)
    return record


def _failure_code(final_result: Mapping[str, Any]) -> Optional[str]:
    if final_result["success"]:
        return None
    if not final_result["boundary_valid"]:
        return "codex_exec_unauthorised_workspace_change"
    if not final_result["control_integrity_restore_valid"]:
        return "codex_exec_control_evidence_restore_failed"
    if not final_result["mutable_symlink_cleanup_valid"]:
        return "codex_exec_mutable_symlink_cleanup_failed"
    if not final_result["rollback_valid"]:
        return "codex_exec_workspace_rollback_failed"
    if final_result["timed_out"]:
        return "codex_exec_timeout"
    if final_result["returncode"] != 0:
        return f"codex_exec_failed_returncode_{final_result['returncode']}"
    if not final_result["output_size_valid"]:
        return "codex_exec_final_output_exceeded_local_byte_limit"
    return final_result["parse_error"] or "codex_exec_schema_validation_failed"


def _finalise_codex_result(
    *,
    cfg: Any,
    layout: Any,
    request: Any,
    stage: str,
    out_dir: Path,
    summary_path: Path,
    provenance_path: Path,
    input_manifest_path: Path,
    attempt_records: Sequence[Mapping[str, Any]],
    max_attempts: int,
    result_type: Any,
    utc_now_iso: Any,
    prompt_path: Optional[str],
    metadata_path: Optional[str],
) -> Any:
    final_result = attempt_records[-1]
    success = bool(final_result["success"])
    output_path = (
        layout.write_llm_authoritative_json(stage, request.output_filename, final_result["parsed"])
        if success else None
    )
    _write_json(summary_path, {
        "schema_version": "codex_exec_summary.v2",
        "created_utc": utc_now_iso(),
        "stage": stage,
        "success": success,
        "attempt_count": len(attempt_records),
        "max_attempts": max_attempts,
        "attempts": [{key: value for key, value in row.items() if key != "parsed"} for row in attempt_records],
        "runtime_provenance": str(provenance_path),
        "input_materialization": str(input_manifest_path),
    })
    validation = {
        "schema_version": "llm_stage_validation.v1",
        "created_utc": utc_now_iso(),
        "stage": stage,
        "mode": cfg.mode.value,
        "execution_backend": "codex_exec",
        "llm_call_executed": True,
        "valid": success,
        "attempts": len(attempt_records),
        "returncode": final_result["returncode"],
        "timed_out": final_result["timed_out"],
        "duration_seconds": round(sum(float(row["duration_seconds"]) for row in attempt_records), 3),
        "schema_validation": final_result["schema_validation"],
        "parse_error": final_result["parse_error"],
        "change_boundary_valid": final_result["boundary_valid"],
        "rollback_valid": final_result["rollback_valid"],
        "control_integrity_valid": final_result["control_integrity_valid"],
        "control_integrity_restore_valid": final_result["control_integrity_restore_valid"],
        "mutable_symlink_cleanup_valid": final_result["mutable_symlink_cleanup_valid"],
        "output_size_valid": final_result["output_size_valid"],
        "terminal_streaming_enabled": cfg.codex_stream_terminal,
        "command_record": str(out_dir / "command.json"),
        "events_jsonl": str(out_dir / "events.jsonl"),
        "stderr_log": str(out_dir / "stderr.log"),
        "last_message": str(out_dir / "last_message.json"),
        "boundary_record": str(out_dir / "change_boundary.json"),
        "runtime_provenance": str(provenance_path),
        "input_materialization": str(input_manifest_path),
        "execution_summary": str(summary_path),
    }
    validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)
    return result_type(
        stage=stage,
        mode=cfg.mode.value,
        success=success,
        llm_call_executed=True,
        output_path=str(output_path) if output_path else None,
        raw_response_path=str(out_dir / "last_message.json"),
        validation_path=str(validation_path),
        prompt_path=prompt_path,
        metadata_path=metadata_path,
        attempts=len(attempt_records),
        error=_failure_code(final_result),
        parsed_json=final_result["parsed"] if success else None,
        validation=validation,
    )


def run_codex_exec(
    *,
    cfg: Any,
    layout: Any,
    request: Any,
    api_input: Sequence[Mapping[str, Any]],
    validate_json_schema: Any,
    extract_json_object: Any,
    result_type: Any,
    utc_now_iso: Any,
    prompt_path: Optional[str],
    metadata_path: Optional[str],
) -> Any:
    stage = request.stage
    binary = _resolve_binary(cfg.codex_binary)
    root = _resolve_root(cfg, layout)
    mutable_roots, protected_roots, add_dirs = _validate_boundaries(cfg, layout, root)
    out_dir = layout.llm_authoritative_dir(stage) / "codex_exec"
    out_dir.mkdir(parents=True, exist_ok=True)
    schema_path = out_dir / "output_schema.json"
    input_manifest_path = out_dir / "input_materialization.json"
    provenance_path = out_dir / "runtime_provenance.json"
    summary_path = out_dir / "execution_summary.json"
    _write_json(schema_path, request.json_schema or {"type": "object"})
    prompt, input_manifest = _render_codex_input(api_input, out_dir)
    _write_json(input_manifest_path, input_manifest)
    provenance = _runtime_provenance(binary, cfg.codex_expected_version)
    _write_json(provenance_path, provenance)
    if cfg.codex_require_version_match and not provenance["expected_version_match"]:
        raise RuntimeError(
            f"Codex version mismatch: expected {cfg.codex_expected_version!r}, "
            f"observed {provenance['version_output']!r}"
        )
    environment = _child_environment(cfg)
    existing_mutable_symlinks = _mutable_symlink_violations(mutable_roots)
    if existing_mutable_symlinks:
        raise ValueError(
            "Symlinks are forbidden inside Codex mutable paths: "
            + ", ".join(existing_mutable_symlinks)
        )
    control_paths = [schema_path, input_manifest_path, provenance_path]
    control_paths.extend(Path(row["materialized_path"]) for row in input_manifest["files"])
    control_payloads = {path: path.read_bytes() for path in control_paths}
    max_attempts = max(1, 1 + int(cfg.max_retries))
    attempts: List[Dict[str, Any]] = []
    with _execution_lock(root, mutable_roots) as lock_record:
        for attempt in range(1, max_attempts + 1):
            record = _execute_codex_attempt(
                cfg=cfg, request=request, stage=stage, attempt=attempt, binary=binary,
                root=root, mutable_roots=mutable_roots, protected_roots=protected_roots,
                add_dirs=add_dirs, schema_path=schema_path, provenance_path=provenance_path,
                out_dir=out_dir, prompt=prompt, control_payloads=control_payloads,
                environment=environment, lock_record=lock_record,
                validate_json_schema=validate_json_schema, extract_json_object=extract_json_object,
                utc_now_iso=utc_now_iso,
            )
            attempts.append(record)
            if record["success"] or record["security_failure"]:
                break
            if attempt < max_attempts:
                time.sleep(max(0.0, float(cfg.retry_sleep_seconds)))
    return _finalise_codex_result(
        cfg=cfg, layout=layout, request=request, stage=stage, out_dir=out_dir,
        summary_path=summary_path, provenance_path=provenance_path,
        input_manifest_path=input_manifest_path, attempt_records=attempts,
        max_attempts=max_attempts, result_type=result_type, utc_now_iso=utc_now_iso,
        prompt_path=prompt_path, metadata_path=metadata_path,
    )
