#!/usr/bin/env python3

from pathlib import Path
import argparse
import datetime
import hashlib
import json
import subprocess


REPOSITORY_URL = (
    "https://github.com/Girish2052003/"
    "girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-"
    "verification-case-study-evidences"
)

PEER_TAGS = {
    "v1.0.0": "v1.1.0",
    "v1.1.0": "v1.0.0",
}


def git(root, *args):
    return subprocess.check_output(
        ["git", "-C", str(root), *args],
        text=True,
    ).strip()


def git_bytes(root, *args):
    return subprocess.check_output(
        ["git", "-C", str(root), *args]
    )


def sha_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha_file(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def snapshot_sha(root, commit, relative_path):
    try:
        data = git_bytes(
            root,
            "show",
            f"{commit}:{relative_path}",
        )
    except subprocess.CalledProcessError:
        return None
    return sha_bytes(data)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--tag", default="v1.0.0")
    parser.add_argument("--release-archive")
    parser.add_argument("--output")
    args = parser.parse_args()

    root = Path(args.repo_root).resolve()

    head = git(root, "rev-parse", "HEAD")
    commit = git(root, "rev-list", "-n", "1", args.tag)
    tag_type = git(root, "cat-file", "-t", args.tag)
    dirty = git(root, "status", "--porcelain")

    if tag_type != "tag":
        raise SystemExit(
            f"Release tag {args.tag} is not an annotated Git tag"
        )

    if dirty:
        raise SystemExit(
            "Working tree is not clean; freeze record refused"
        )

    peer_tag = PEER_TAGS.get(args.tag)
    peer_commit = None

    if peer_tag:
        peer_type = git(root, "cat-file", "-t", peer_tag)
        peer_commit = git(root, "rev-list", "-n", "1", peer_tag)

        if peer_type != "tag":
            raise SystemExit(
                f"Peer release tag {peer_tag} is not annotated"
            )

        if peer_commit != commit:
            raise SystemExit(
                "Maintained release tags do not share one snapshot: "
                f"{args.tag}={commit} {peer_tag}={peer_commit}"
            )

    merge_base = git(root, "merge-base", commit, head)

    if merge_base != commit:
        raise SystemExit(
            "Release snapshot is not an ancestor of current HEAD: "
            f"snapshot={commit} HEAD={head}"
        )

    output = (
        Path(args.output)
        if args.output
        else Path.cwd() / f"RELEASE_FREEZE_RECORD_{args.tag}.json"
    )

    evidence_hashes = {
        "THESIS_EVIDENCE_INDEX.md": snapshot_sha(
            root,
            commit,
            "THESIS_EVIDENCE_INDEX.md",
        ),
        "docs/thesis-evidence/SHA256SUMS": snapshot_sha(
            root,
            commit,
            "docs/thesis-evidence/SHA256SUMS",
        ),
    }

    data = {
        "repository_url": REPOSITORY_URL,
        "release_tag": args.tag,
        "tag_object_type": tag_type,
        "release_snapshot_commit": commit,
        "tagged_commit": commit,
        "shared_release_target": peer_tag is not None,
        "shared_with_release_tag": peer_tag,
        "head_commit_at_record_generation": head,
        "release_snapshot_is_ancestor_of_head": True,
        "main_branch_may_advance_independently": True,
        "working_tree_clean": True,
        "generated_utc": datetime.datetime.now(
            datetime.timezone.utc
        ).isoformat(),
        "evidence_documentation_hash_basis": (
            "release_snapshot_commit"
        ),
        "evidence_documentation_sha256s": evidence_hashes,
        "release_archive": None,
    }

    if args.release_archive:
        archive = Path(args.release_archive)
        data["release_archive"] = {
            "path": str(archive),
            "size_bytes": archive.stat().st_size,
            "sha256": sha_file(archive),
        }

    output.write_text(
        json.dumps(data, indent=2) + "\n",
        encoding="utf-8",
    )

    print(output)
    print(json.dumps(data, indent=2))


if __name__ == "__main__":
    main()
