#!/usr/bin/env python3

import collections
import sys
import xml.etree.ElementTree as ET


def parse_xml(path):
    try:
        return ET.parse(path).getroot()
    except Exception as exc:
        print("XML_PARSE=FAIL")
        print(f"XML_PARSE_ERROR={exc}")
        raise SystemExit(2)


def get_cprover_status(root):
    node = root.find(".//cprover-status")

    if node is None or not node.text:
        return "NOT_FOUND"

    return node.text.strip()


def append_summary(summary_path, lines):
    text = "\n".join(lines)
    print(text)

    with open(summary_path, "a", encoding="utf-8") as handle:
        handle.write(text + "\n")


def parse_positive(xml_path, summary_path):
    root = parse_xml(xml_path)
    global_status = get_cprover_status(root)
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
            "FROMMSG_T3_P1_EXACT_BYTE_ROUND_TRIP",
        "harness.assertion.2":
            "FROMMSG_T3_P2_EXACT_BIT_ROUND_TRIP",
        "harness.assertion.3":
            "FROMMSG_T3_P3_CODEBOOK_FIXED_POINT",
        "harness.assertion.4":
            "FROMMSG_T3_P4_EXACT_CODEBOOK_DECODING",
    }

    lines = [
        "POSITIVE_XML_RECHECK_PARSE=PASS",
        f"POSITIVE_RECHECK_CPROVER_STATUS={global_status}",
        f"POSITIVE_RECHECK_TOTAL_RESULT_RECORDS={len(results)}",
    ]

    for key in sorted(counts):
        lines.append(
            f"POSITIVE_RECHECK_RESULT_STATUS_{key}={counts[key]}"
        )

    selected_success = True

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
            selected_success = False

    accepted = (
        global_status == "SUCCESS"
        and len(results) == 140
        and counts.get("SUCCESS", 0) == 140
        and counts.get("FAILURE", 0) == 0
        and counts.get("ERROR", 0) == 0
        and selected_success
    )

    lines.append(
        "FROMMSG_T3_POSITIVE_RECHECK="
        + ("PASS" if accepted else "NOT_PASS")
    )

    append_summary(summary_path, lines)
    raise SystemExit(0 if accepted else 1)


def parse_expected(
    xml_path,
    summary_path,
    property_id,
    family,
    label,
):
    root = parse_xml(xml_path)
    global_status = get_cprover_status(root)
    selected_status = "NOT_FOUND"

    for result in root.findall(".//result"):
        if result.attrib.get("property") == property_id:
            selected_status = result.attrib.get(
                "status",
                "MISSING",
            )
            break

    accepted = (
        global_status == "FAILURE"
        and selected_status == "FAILURE"
    )

    lines = [
        f"{family}_{label}_XML_PARSE=PASS",
        f"{family}_{label}_CPROVER_STATUS={global_status}",
        f"{family}_{label}_PROPERTY_ID={property_id}",
        f"{family}_{label}_PROPERTY_STATUS={selected_status}",
        (
            f"{family}_{label}_"
            "EXPECTED_FAILURE_CLASSIFICATION="
            + ("PASS" if accepted else "NOT_PASS")
        ),
    ]

    append_summary(summary_path, lines)
    raise SystemExit(0 if accepted else 1)


def main():
    if len(sys.argv) < 4:
        raise SystemExit(
            "usage: parser MODE XML SUMMARY [PROPERTY FAMILY LABEL]"
        )

    mode = sys.argv[1]

    if mode == "positive":
        parse_positive(sys.argv[2], sys.argv[3])

    if mode == "expected":
        if len(sys.argv) != 7:
            raise SystemExit(
                "expected mode requires PROPERTY FAMILY LABEL"
            )

        parse_expected(
            sys.argv[2],
            sys.argv[3],
            sys.argv[4],
            sys.argv[5],
            sys.argv[6],
        )

    raise SystemExit(f"unknown mode: {mode}")


if __name__ == "__main__":
    main()
