from __future__ import annotations

import shlex
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

xml_path = Path(sys.argv[1])
mapping_path = Path(sys.argv[2])
target_label = sys.argv[3]
property_path = Path(sys.argv[4])
mapped_path = Path(sys.argv[5])
env_path = Path(sys.argv[6])

label_to_id: dict[str, str] = {}

for line in mapping_path.read_text(
    encoding="utf-8",
).splitlines()[1:]:
    if not line:
        continue

    label, property_id = line.split("\t", 1)
    label_to_id[label] = property_id

if target_label not in label_to_id:
    raise SystemExit(
        f"Target label {target_label} missing from mapping"
    )

target_property = label_to_id[target_label]

id_to_label = {
    property_id: label
    for label, property_id in label_to_id.items()
}

summary: dict[str, str | int] = {
    "XML_PARSE_STATUS": "FAIL",
    "CPROVER_STATUS": "NOT_FOUND",
    "TOTAL_RESULT_COUNT": 0,
    "SUCCESS_RESULT_COUNT": 0,
    "FAILURE_RESULT_COUNT": 0,
    "ERROR_RESULT_COUNT": 0,
    "UNKNOWN_RESULT_COUNT": 0,
    "TARGET_PROPERTY": target_property,
    "TARGET_PROPERTY_STATUS": "MISSING",
    "MAPPED_PROPERTY_EXPECTED_COUNT": len(label_to_id),
    "MAPPED_PROPERTY_SEEN_COUNT": 0,
    "MAPPED_PROPERTY_FAILURE_COUNT": 0,
    "OTHER_MAPPED_FAILURE_COUNT": 0,
    "NONMAPPED_NONSUCCESS_COUNT": 0,
    "UNWIND_FAILURE_COUNT": 0,
}

rows: list[tuple[str, str, str]] = []
mapped_status: dict[str, str] = {}

try:
    root = ET.parse(xml_path).getroot()

    summary["XML_PARSE_STATUS"] = "PASS"

    status_node = root.find(".//cprover-status")

    if status_node is not None and status_node.text:
        summary["CPROVER_STATUS"] = (
            status_node.text.strip()
        )

    results = list(root.findall(".//result"))

    summary["TOTAL_RESULT_COUNT"] = len(results)

    counts = Counter(
        result.attrib.get("status", "UNKNOWN")
        for result in results
    )

    summary["SUCCESS_RESULT_COUNT"] = counts["SUCCESS"]
    summary["FAILURE_RESULT_COUNT"] = counts["FAILURE"]
    summary["ERROR_RESULT_COUNT"] = counts["ERROR"]
    summary["UNKNOWN_RESULT_COUNT"] = counts["UNKNOWN"]

    for result in results:
        property_id = result.attrib.get(
            "property",
            "",
        )

        status = result.attrib.get(
            "status",
            "UNKNOWN",
        )

        description_node = result.find("description")

        description = (
            description_node.text.strip()
            if description_node is not None
            and description_node.text
            else ""
        )

        rows.append(
            (property_id, status, description)
        )

        if property_id in id_to_label:
            mapped_status[id_to_label[property_id]] = status
        elif status != "SUCCESS":
            summary[
                "NONMAPPED_NONSUCCESS_COUNT"
            ] += 1

        if (
            "unwind" in property_id.lower()
            and status != "SUCCESS"
        ):
            summary["UNWIND_FAILURE_COUNT"] += 1

    summary["TARGET_PROPERTY_STATUS"] = (
        mapped_status.get(
            target_label,
            "MISSING",
        )
    )

    summary["MAPPED_PROPERTY_SEEN_COUNT"] = len(
        mapped_status
    )

    mapped_failures = {
        label
        for label, status in mapped_status.items()
        if status == "FAILURE"
    }

    summary["MAPPED_PROPERTY_FAILURE_COUNT"] = len(
        mapped_failures
    )

    summary["OTHER_MAPPED_FAILURE_COUNT"] = len(
        mapped_failures - {target_label}
    )

except Exception as exc:
    rows.append(
        (
            "XML_PARSE_ERROR",
            "ERROR",
            repr(exc),
        )
    )

with property_path.open("w", encoding="utf-8") as stream:
    stream.write(
        "property_id\tstatus\tdescription\n"
    )

    for property_id, status, description in rows:
        cleaned = (
            description
            .replace("\t", " ")
            .replace("\n", " ")
        )

        stream.write(
            f"{property_id}\t{status}\t{cleaned}\n"
        )

with mapped_path.open("w", encoding="utf-8") as stream:
    stream.write(
        "label\tproperty_id\tstatus\ttarget\n"
    )

    for label in sorted(label_to_id):
        property_id = label_to_id[label]

        stream.write(
            f"{label}\t{property_id}\t"
            f"{mapped_status.get(label, 'MISSING')}\t"
            f"{'YES' if label == target_label else 'NO'}\n"
        )

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in summary.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
