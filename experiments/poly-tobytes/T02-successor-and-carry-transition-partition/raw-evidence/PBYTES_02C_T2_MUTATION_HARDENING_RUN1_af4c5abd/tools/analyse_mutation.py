from __future__ import annotations

import shlex
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

xml_path = Path(sys.argv[1])
target_property = sys.argv[2]
env_path = Path(sys.argv[3])
property_path = Path(sys.argv[4])
explicit_path = Path(sys.argv[5])

explicit_properties = {
    "harness.assertion.1",
    "harness.assertion.2",
    "harness.assertion.3",
    "harness.assertion.4",
}

summary: dict[str, str | int] = {
    "XML_PARSE_STATUS": "FAIL",
    "CPROVER_STATUS": "NOT_FOUND",
    "TOTAL_RESULT_COUNT": 0,
    "SUCCESS_RESULT_COUNT": 0,
    "FAILURE_RESULT_COUNT": 0,
    "ERROR_RESULT_COUNT": 0,
    "UNKNOWN_RESULT_COUNT": 0,
    "TARGET_PROPERTY_STATUS": "MISSING",
    "EXPLICIT_SEEN_COUNT": 0,
    "EXPLICIT_FAILURE_COUNT": 0,
    "OTHER_EXPLICIT_FAILURE_COUNT": 0,
    "NONEXPLICIT_NONSUCCESS_COUNT": 0,
    "UNWIND_FAILURE_COUNT": 0,
}

rows: list[tuple[str, str, str]] = []
explicit_status: dict[str, str] = {}

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

        if property_id in explicit_properties:
            explicit_status[property_id] = status
        elif status != "SUCCESS":
            summary[
                "NONEXPLICIT_NONSUCCESS_COUNT"
            ] += 1

        if (
            "unwind" in property_id.lower()
            and status != "SUCCESS"
        ):
            summary["UNWIND_FAILURE_COUNT"] += 1

    summary["TARGET_PROPERTY_STATUS"] = (
        explicit_status.get(
            target_property,
            "MISSING",
        )
    )

    summary["EXPLICIT_SEEN_COUNT"] = len(
        explicit_status
    )

    explicit_failures = {
        property_id
        for property_id, status
        in explicit_status.items()
        if status == "FAILURE"
    }

    summary["EXPLICIT_FAILURE_COUNT"] = len(
        explicit_failures
    )

    summary["OTHER_EXPLICIT_FAILURE_COUNT"] = len(
        explicit_failures - {target_property}
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

with explicit_path.open("w", encoding="utf-8") as stream:
    stream.write("property_id\tstatus\ttarget\n")

    for property_id in sorted(explicit_properties):
        stream.write(
            f"{property_id}\t"
            f"{explicit_status.get(property_id, 'MISSING')}\t"
            f"{'YES' if property_id == target_property else 'NO'}\n"
        )

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in summary.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
