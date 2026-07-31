from __future__ import annotations

import re
import shlex
import sys
from pathlib import Path

inventory_path = Path(sys.argv[1])

expected_labels = {
    item
    for item in sys.argv[2].split(",")
    if item
}

mapping_path = Path(sys.argv[3])
env_path = Path(sys.argv[4])

text = inventory_path.read_text(
    encoding="utf-8",
    errors="replace",
)

property_pattern = re.compile(
    r"^Property\s+(\S+)"
)

label_pattern = re.compile(
    r"PBYTES-T4\.P[1-4]"
)

current_property = None
mapping: dict[str, str] = {}

for line in text.splitlines():
    property_match = property_pattern.match(line)

    if property_match:
        current_property = (
            property_match.group(1).rstrip(":")
        )

    label_match = label_pattern.search(line)

    if label_match and current_property:
        label = label_match.group(0)

        if label in mapping and mapping[label] != current_property:
            raise SystemExit(
                f"Duplicate property mapping for {label}"
            )

        mapping[label] = current_property

missing = sorted(
    expected_labels - set(mapping)
)

unexpected = sorted(
    set(mapping) - expected_labels
)

values = {
    "MAPPED_PROPERTY_COUNT": len(mapping),
    "EXPECTED_PROPERTY_COUNT": len(expected_labels),
    "MISSING_PROPERTY_COUNT": len(missing),
    "UNEXPECTED_PROPERTY_COUNT": len(unexpected),
    "MISSING_PROPERTIES": ",".join(missing),
    "UNEXPECTED_PROPERTIES": ",".join(unexpected),
}

with mapping_path.open("w", encoding="utf-8") as stream:
    stream.write("label\tproperty_id\n")

    for label in sorted(mapping):
        stream.write(
            f"{label}\t{mapping[label]}\n"
        )

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in values.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
