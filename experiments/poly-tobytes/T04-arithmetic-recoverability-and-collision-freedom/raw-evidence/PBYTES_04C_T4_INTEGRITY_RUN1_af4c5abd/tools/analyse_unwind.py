from __future__ import annotations

import shlex
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

xml_path = Path(sys.argv[1])
failure_path = Path(sys.argv[2])
env_path = Path(sys.argv[3])

summary: dict[str, str | int] = {
    "XML_PARSE_STATUS": "FAIL",
    "CPROVER_STATUS": "NOT_FOUND",
    "TOTAL_RESULT_COUNT": 0,
    "SUCCESS_RESULT_COUNT": 0,
    "FAILURE_RESULT_COUNT": 0,
    "ERROR_RESULT_COUNT": 0,
    "UNKNOWN_RESULT_COUNT": 0,
    "UNWIND_FAILURE_COUNT": 0,
    "NONUNWIND_FAILURE_COUNT": 0,
}

failure_rows: list[tuple[str, str, str]] = []

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
        if result.attrib.get("status") != "FAILURE":
            continue

        property_id = result.attrib.get(
            "property",
            "",
        )

        description_node = result.find("description")

        description = (
            description_node.text.strip()
            if description_node is not None
            and description_node.text
            else ""
        )

        is_unwind = (
            "unwind" in property_id.lower()
            or "unwind" in description.lower()
        )

        if is_unwind:
            summary["UNWIND_FAILURE_COUNT"] += 1
        else:
            summary["NONUNWIND_FAILURE_COUNT"] += 1

        failure_rows.append(
            (
                property_id,
                "YES" if is_unwind else "NO",
                description,
            )
        )

except Exception as exc:
    failure_rows.append(
        (
            "XML_PARSE_ERROR",
            "NO",
            repr(exc),
        )
    )

with failure_path.open("w", encoding="utf-8") as stream:
    stream.write(
        "property_id\tunwind_related\tdescription\n"
    )

    for property_id, unwind_related, description in failure_rows:
        cleaned = (
            description
            .replace("\t", " ")
            .replace("\n", " ")
        )

        stream.write(
            f"{property_id}\t{unwind_related}\t{cleaned}\n"
        )

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in summary.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
