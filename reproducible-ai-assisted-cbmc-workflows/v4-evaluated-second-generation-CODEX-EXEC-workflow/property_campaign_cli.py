#!/usr/bin/env python3
"""Inspect and validate the built-in 26-property campaign catalogue."""
from __future__ import annotations
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import load_normalized_config, validate_pipeline_config
from agents.common.property_catalog import PROPERTY_FAMILIES, get_property_family, resolve_strategy


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list", help="List all 26 property families.")
    show = sub.add_parser("show", help="Show one property family as JSON.")
    show.add_argument("property_family")
    frag = sub.add_parser("fragment", help="Print a canonical property_campaign JSON fragment.")
    frag.add_argument("property_family")
    frag.add_argument("--strategy", default="auto")
    validate = sub.add_parser("validate-config", help="Normalize and validate a complete experiment config.")
    validate.add_argument("config", type=Path)
    args = parser.parse_args()

    if args.command == "list":
        print(f"{'ID':<4} {'Default strategy':<31} {'Support':<28} Title")
        for row in PROPERTY_FAMILIES:
            print(f"{row['id']:<4} {row['default_strategy']:<31} {row['support_level']:<28} {row['title']}")
        return 0
    if args.command == "show":
        print(json.dumps(get_property_family(args.property_family), indent=2))
        return 0
    if args.command == "fragment":
        family = get_property_family(args.property_family)
        strategy = resolve_strategy(family, args.strategy)
        fragment = {
            "property_campaign": {
                "property_family_id": family["id"],
                "verification_strategy": strategy,
                "allow_analysis_only": family["support_level"] == "analysis_only",
            }
        }
        print(json.dumps(fragment, indent=2))
        return 0
    config = load_normalized_config(args.config)
    report = validate_pipeline_config(config)
    print(json.dumps({
        "valid": report.valid,
        "errors": list(report.errors),
        "warnings": list(report.warnings),
        "property_campaign": config.get("property_campaign"),
    }, indent=2))
    return 0 if report.valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
