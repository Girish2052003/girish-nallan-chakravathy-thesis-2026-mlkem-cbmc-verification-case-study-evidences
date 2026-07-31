#!/usr/bin/env python3

import collections
import sys
import xml.etree.ElementTree as ET


def main():
    if len(sys.argv) != 3:
        raise SystemExit(
            "usage: parse_frommsg_t2_positive.py RESULT_XML SUMMARY"
        )

    xml_path = sys.argv[1]
    summary_path = sys.argv[2]

    try:
        root = ET.parse(xml_path).getroot()
    except Exception as exc:
        lines = [
            "RESULT_XML_PARSE=FAIL",
            f"RESULT_XML_PARSE_ERROR={exc}",
            "FROMMSG_T2_POSITIVE_CLASSIFICATION=NOT_PASS",
        ]

        text = "\n".join(lines)
        print(text)

        with open(summary_path, "w", encoding="utf-8") as handle:
            handle.write(text + "\n")

        raise SystemExit(2)

    status_node = root.find(".//cprover-status")

    global_status = (
        status_node.text.strip()
        if status_node is not None and status_node.text
        else "NOT_FOUND"
    )

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
            "FROMMSG_T2_P1_EXACT_TARGET_TOGGLE_PAIR",
        "harness.assertion.2":
            "FROMMSG_T2_P2_TARGET_TOGGLE_SUM",
        "harness.assertion.3":
            "FROMMSG_T2_P3_DIFFERENCE_IFF_FLIPPED_COORDINATE",
        "harness.assertion.4":
            "FROMMSG_T2_P4_BOOLEAN_COMPLEMENT_PRESERVATION",
    }

    lines = [
        "RESULT_XML_PARSE=PASS",
        f"CPROVER_STATUS={global_status}",
        f"TOTAL_RESULT_RECORDS={len(results)}",
    ]

    for key in sorted(counts):
        lines.append(f"RESULT_STATUS_{key}={counts[key]}")

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
        global_status == "SUCCESS"
        and counts.get("FAILURE", 0) == 0
        and counts.get("ERROR", 0) == 0
        and all_wanted_success
    )

    lines.append(
        "FROMMSG_T2_POSITIVE_CLASSIFICATION="
        + ("PASS" if accepted else "NOT_PASS")
    )

    text = "\n".join(lines)
    print(text)

    with open(summary_path, "w", encoding="utf-8") as handle:
        handle.write(text + "\n")

    raise SystemExit(0 if accepted else 1)


if __name__ == "__main__":
    main()
