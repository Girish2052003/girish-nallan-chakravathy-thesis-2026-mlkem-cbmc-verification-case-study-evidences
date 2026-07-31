#!/usr/bin/env python3

import collections
import re
import sys
import xml.etree.ElementTree as ET


EXPECTED_PROPERTIES = [
    "FROMMSG_T4_P1_COORDINATE_SUPPORT_PRESERVATION",
    "FROMMSG_T4_P2_GLOBAL_CODEBOOK_WEIGHT_PRESERVATION",
    "FROMMSG_T4_P3_GLOBAL_HAMMING_METRIC_PRESERVATION",
    "FROMMSG_T4_P4_GLOBAL_SCALED_DISTANCE_PRESERVATION",
]


def bind_properties(property_list_path, property_map_path):
    with open(
        property_list_path,
        "r",
        encoding="utf-8",
        errors="replace",
    ) as handle:
        lines = handle.readlines()

    blocks = []
    current_id = None
    current_lines = []

    for line in lines:
        match = re.match(r"^Property (.+):\s*$", line)

        if match:
            if current_id is not None:
                blocks.append(
                    (
                        current_id,
                        "".join(current_lines),
                    )
                )

            current_id = match.group(1).strip()
            current_lines = [line]
        elif current_id is not None:
            current_lines.append(line)

    if current_id is not None:
        blocks.append(
            (
                current_id,
                "".join(current_lines),
            )
        )

    mappings = []

    for expected in EXPECTED_PROPERTIES:
        matches = [
            property_id
            for property_id, block in blocks
            if expected in block
        ]

        if len(matches) != 1:
            print(
                f"{expected}_BINDING_COUNT={len(matches)}"
            )
            print("FROMMSG_T4_PROPERTY_BINDING=NOT_PASS")
            raise SystemExit(2)

        property_id = matches[0]

        print(f"{expected}_PROPERTY_ID={property_id}")
        mappings.append((expected, property_id))

    with open(
        property_map_path,
        "w",
        encoding="utf-8",
    ) as handle:
        for expected, property_id in mappings:
            handle.write(
                f"{expected}\t{property_id}\n"
            )

    print(
        f"CUSTOM_PROPERTY_BINDING_COUNT={len(mappings)}"
    )
    print("FROMMSG_T4_PROPERTY_BINDING=PASS")


def parse_positive(
    xml_path,
    property_map_path,
    summary_path,
):
    try:
        root = ET.parse(xml_path).getroot()
    except Exception as exc:
        lines = [
            "RESULT_XML_PARSE=FAIL",
            f"RESULT_XML_PARSE_ERROR={exc}",
            "FROMMSG_T4_POSITIVE_CLASSIFICATION=NOT_PASS",
        ]

        text = "\n".join(lines)
        print(text)

        with open(
            summary_path,
            "w",
            encoding="utf-8",
        ) as handle:
            handle.write(text + "\n")

        raise SystemExit(3)

    status_node = root.find(".//cprover-status")

    cprover_status = (
        status_node.text.strip()
        if status_node is not None
        and status_node.text
        else "NOT_FOUND"
    )

    results = root.findall(".//result")

    counts = collections.Counter(
        result.attrib.get("status", "MISSING")
        for result in results
    )

    result_statuses = collections.defaultdict(list)

    for result in results:
        property_id = result.attrib.get(
            "property",
            "UNKNOWN",
        )

        result_statuses[property_id].append(
            result.attrib.get(
                "status",
                "MISSING",
            )
        )

    mappings = []

    with open(
        property_map_path,
        "r",
        encoding="utf-8",
    ) as handle:
        for raw_line in handle:
            raw_line = raw_line.rstrip("\n")

            if not raw_line:
                continue

            fields = raw_line.split("\t")

            if len(fields) != 2:
                raise SystemExit(
                    "malformed property map"
                )

            mappings.append(
                (fields[0], fields[1])
            )

    lines = [
        "RESULT_XML_PARSE=PASS",
        f"CPROVER_STATUS={cprover_status}",
        f"TOTAL_RESULT_RECORDS={len(results)}",
    ]

    for key in sorted(counts):
        lines.append(
            f"RESULT_STATUS_{key}={counts[key]}"
        )

    selected_success = True

    for theorem_name, property_id in mappings:
        statuses = result_statuses.get(
            property_id,
            [],
        )

        lines.append(
            f"{theorem_name}_PROPERTY_ID={property_id}"
        )

        lines.append(
            f"{theorem_name}_RESULT_RECORD_COUNT="
            f"{len(statuses)}"
        )

        if len(statuses) == 1:
            selected_status = statuses[0]
        elif len(statuses) == 0:
            selected_status = "NOT_FOUND"
        else:
            selected_status = "DUPLICATE"

        lines.append(
            f"{theorem_name}_STATUS={selected_status}"
        )

        if selected_status != "SUCCESS":
            selected_success = False

    accepted = (
        cprover_status == "SUCCESS"
        and len(results) > 0
        and counts.get("FAILURE", 0) == 0
        and counts.get("ERROR", 0) == 0
        and len(mappings) == 4
        and selected_success
    )

    lines.append(
        "FROMMSG_T4_POSITIVE_CLASSIFICATION="
        + ("PASS" if accepted else "NOT_PASS")
    )

    text = "\n".join(lines)
    print(text)

    with open(
        summary_path,
        "w",
        encoding="utf-8",
    ) as handle:
        handle.write(text + "\n")

    raise SystemExit(0 if accepted else 1)


def main():
    if len(sys.argv) < 2:
        raise SystemExit(
            "usage: parser MODE ..."
        )

    mode = sys.argv[1]

    if mode == "bind":
        if len(sys.argv) != 4:
            raise SystemExit(
                "bind mode: PROPERTY_LIST PROPERTY_MAP"
            )

        bind_properties(
            sys.argv[2],
            sys.argv[3],
        )

        raise SystemExit(0)

    if mode == "positive":
        if len(sys.argv) != 5:
            raise SystemExit(
                "positive mode: XML PROPERTY_MAP SUMMARY"
            )

        parse_positive(
            sys.argv[2],
            sys.argv[3],
            sys.argv[4],
        )

    raise SystemExit(f"unknown mode: {mode}")


if __name__ == "__main__":
    main()
