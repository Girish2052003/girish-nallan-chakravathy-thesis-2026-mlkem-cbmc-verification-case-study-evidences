from __future__ import annotations

import shlex
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

xml_path = Path(sys.argv[1])
expected_csv = sys.argv[2]
env_path = Path(sys.argv[3])
status_path = Path(sys.argv[4])
failed_path = Path(sys.argv[5])

expected_failures = {
    item
    for item in expected_csv.split(",")
    if item
}

explicit_properties = {
    f"harness.assertion.{number}"
    for number in range(1, 10)
}

summary: dict[str, str | int] = {
    "XML_PARSE_STATUS": "FAIL",
    "CPROVER_STATUS": "NOT_FOUND",
    "TOTAL_RESULT_COUNT": 0,
    "SUCCESS_RESULT_COUNT": 0,
    "FAILURE_RESULT_COUNT": 0,
    "ERROR_RESULT_COUNT": 0,
    "UNKNOWN_RESULT_COUNT": 0,
    "EXPLICIT_SEEN_COUNT": 0,
    "EXPLICIT_SUCCESS_COUNT": 0,
    "EXPLICIT_FAILURE_COUNT": 0,
    "EXPECTED_FAILURE_COUNT": len(expected_failures),
    "EXPECTED_FAILURE_SEEN_COUNT": 0,
    "MISSING_EXPECTED_FAILURE_COUNT": len(expected_failures),
    "UNEXPECTED_EXPLICIT_FAILURE_COUNT": 0,
    "NONEXPLICIT_NONSUCCESS_COUNT": 0,
    "UNWIND_FAILURE_COUNT": 0,
    "MISSING_EXPECTED_FAILURES": ",".join(
        sorted(expected_failures)
    ),
    "UNEXPECTED_EXPLICIT_FAILURES": "",
}

rows: list[tuple[str, str, str]] = []
observed_explicit: dict[str, str] = {}

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
            observed_explicit[property_id] = status
        elif status != "SUCCESS":
            summary[
                "NONEXPLICIT_NONSUCCESS_COUNT"
            ] += 1

        if (
            "unwind" in property_id.lower()
            and status != "SUCCESS"
        ):
            summary["UNWIND_FAILURE_COUNT"] += 1

    actual_explicit_failures = {
        property_id
        for property_id, status
        in observed_explicit.items()
        if status == "FAILURE"
    }

    missing_expected = sorted(
        expected_failures - actual_explicit_failures
    )

    unexpected_explicit = sorted(
        actual_explicit_failures - expected_failures
    )

    summary["EXPLICIT_SEEN_COUNT"] = len(
        observed_explicit
    )

    summary["EXPLICIT_SUCCESS_COUNT"] = sum(
        status == "SUCCESS"
        for status in observed_explicit.values()
    )

    summary["EXPLICIT_FAILURE_COUNT"] = len(
        actual_explicit_failures
    )

    summary["EXPECTED_FAILURE_SEEN_COUNT"] = len(
        expected_failures & actual_explicit_failures
    )

    summary["MISSING_EXPECTED_FAILURE_COUNT"] = len(
        missing_expected
    )

    summary["UNEXPECTED_EXPLICIT_FAILURE_COUNT"] = len(
        unexpected_explicit
    )

    summary["MISSING_EXPECTED_FAILURES"] = ",".join(
        missing_expected
    )

    summary["UNEXPECTED_EXPLICIT_FAILURES"] = ",".join(
        unexpected_explicit
    )

except Exception as exc:
    rows.append(
        (
            "XML_PARSE_ERROR",
            "ERROR",
            repr(exc),
        )
    )

with status_path.open("w", encoding="utf-8") as stream:
    stream.write("property_id\tstatus\tdescription\n")

    for property_id, status, description in rows:
        cleaned = (
            description
            .replace("\t", " ")
            .replace("\n", " ")
        )

        stream.write(
            f"{property_id}\t{status}\t{cleaned}\n"
        )

with failed_path.open("w", encoding="utf-8") as stream:
    stream.write("property_id\tstatus\n")

    for property_id in sorted(observed_explicit):
        status = observed_explicit[property_id]

        if status != "SUCCESS":
            stream.write(
                f"{property_id}\t{status}\n"
            )

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in summary.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
