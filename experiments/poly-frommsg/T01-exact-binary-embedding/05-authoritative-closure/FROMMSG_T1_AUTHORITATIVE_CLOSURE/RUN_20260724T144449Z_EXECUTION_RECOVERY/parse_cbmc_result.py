#!/usr/bin/env python3

import collections
import sys
import xml.etree.ElementTree as ET


def emit(summary_path, lines):
    text = "\n".join(lines)

    print(text)

    with open(summary_path, "a", encoding="utf-8") as handle:
        handle.write(text)
        handle.write("\n")


def parse_xml(path):
    try:
        return ET.parse(path).getroot()
    except Exception as exc:
        print(f"XML_PARSE=FAIL")
        print(f"XML_PARSE_ERROR={exc}")
        raise SystemExit(2)


def global_status(root):
    node = root.find(".//cprover-status")

    if node is None or not node.text:
        return "NOT_FOUND"

    return node.text.strip()


def positive(xml_path, summary_path):
    root = parse_xml(xml_path)
    results = root.findall(".//result")

    counts = collections.Counter(
        result.attrib.get("status", "MISSING")
        for result in results
    )

    result_map = {
        result.attrib.get("property", "UNKNOWN"):
            result.attrib.get("status", "MISSING")
        for result in results
    }

    wanted = {
        "harness.assertion.1":
            "FROMMSG_T1_P1_EXACT_COORDINATE_EQUATION",
        "harness.assertion.2":
            "FROMMSG_T1_P2_EXACT_BINARY_OUTPUT_ALPHABET",
        "harness.assertion.3":
            "FROMMSG_T1_P3_ONE_BIT_SUPPORT_EQUIVALENCE",
        "harness.assertion.4":
            "FROMMSG_T1_P4_ZERO_BIT_SUPPORT_EQUIVALENCE",
    }

    status = global_status(root)

    lines = [
        "POSITIVE_XML_PARSE=PASS",
        f"POSITIVE_CPROVER_STATUS={status}",
        f"POSITIVE_TOTAL_RESULT_RECORDS={len(results)}",
    ]

    for key in sorted(counts):
        lines.append(
            f"POSITIVE_RESULT_STATUS_{key}={counts[key]}"
        )

    all_wanted_success = True

    for property_id, theorem_name in wanted.items():
        property_status = result_map.get(
            property_id,
            "NOT_FOUND",
        )

        lines.append(
            f"{theorem_name}_PROPERTY_ID={property_id}"
        )
        lines.append(
            f"{theorem_name}_STATUS={property_status}"
        )

        if property_status != "SUCCESS":
            all_wanted_success = False

    accepted = (
        status == "SUCCESS"
        and counts.get("FAILURE", 0) == 0
        and counts.get("ERROR", 0) == 0
        and all_wanted_success
    )

    lines.append(
        "AUTHORITATIVE_POSITIVE_CLASSIFICATION="
        + ("PASS" if accepted else "NOT_PASS")
    )

    emit(summary_path, lines)
    raise SystemExit(0 if accepted else 1)


def expected_failure(
    xml_path,
    summary_path,
    property_id,
    family,
    label,
):
    root = parse_xml(xml_path)
    status = global_status(root)

    selected_status = "NOT_FOUND"

    for result in root.findall(".//result"):
        if result.attrib.get("property") == property_id:
            selected_status = result.attrib.get(
                "status",
                "MISSING",
            )
            break

    accepted = (
        status == "FAILURE"
        and selected_status == "FAILURE"
    )

    lines = [
        f"{family}_{label}_XML_PARSE=PASS",
        f"{family}_{label}_CPROVER_STATUS={status}",
        f"{family}_{label}_PROPERTY_ID={property_id}",
        f"{family}_{label}_PROPERTY_STATUS={selected_status}",
        (
            f"{family}_{label}_"
            "EXPECTED_FAILURE_CLASSIFICATION="
            + ("PASS" if accepted else "NOT_PASS")
        ),
    ]

    emit(summary_path, lines)
    raise SystemExit(0 if accepted else 1)


def main():
    if len(sys.argv) < 4:
        raise SystemExit(
            "usage: parse_cbmc_result.py MODE XML SUMMARY ..."
        )

    mode = sys.argv[1]
    xml_path = sys.argv[2]
    summary_path = sys.argv[3]

    if mode == "positive":
        positive(xml_path, summary_path)

    if mode == "expected":
        if len(sys.argv) != 7:
            raise SystemExit(
                "expected mode requires PROPERTY FAMILY LABEL"
            )

        expected_failure(
            xml_path,
            summary_path,
            sys.argv[4],
            sys.argv[5],
            sys.argv[6],
        )

    raise SystemExit(f"unknown mode: {mode}")


if __name__ == "__main__":
    main()
