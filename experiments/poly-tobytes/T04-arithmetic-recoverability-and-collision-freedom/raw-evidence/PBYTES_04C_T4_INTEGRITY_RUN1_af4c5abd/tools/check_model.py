from __future__ import annotations

import re
import shlex
import sys
from pathlib import Path

functions = Path(sys.argv[1]).read_text(
    encoding="utf-8",
    errors="replace",
)

loops_text = Path(sys.argv[2]).read_text(
    encoding="utf-8",
    errors="replace",
)

graph = Path(sys.argv[3]).read_text(
    encoding="utf-8",
    errors="replace",
)

expected_loops = {
    item
    for item in sys.argv[4].split(",")
    if item
}

expected_public_calls = int(sys.argv[5])
env_path = Path(sys.argv[6])

observed_loops = set(
    re.findall(
        r"^Loop ([^:]+):",
        loops_text,
        flags=re.MULTILINE,
    )
)

required_edges = {
    "harness -> mlk_poly_tobytes",
    "mlk_poly_tobytes -> mlk_poly_tobytes_c",
    "__CPROVER__start -> harness",
}

values = {
    "EXPECTED_PUBLIC_CALL_COUNT": expected_public_calls,
    "PUBLIC_CALL_COUNT": len(
        re.findall(
            r"\bCALL mlk_poly_tobytes\(",
            functions,
        )
    ),
    "PORTABLE_CALL_COUNT": len(
        re.findall(
            r"\bCALL mlk_poly_tobytes_c\(",
            functions,
        )
    ),
    "FROMBYTES_CALL_COUNT": len(
        re.findall(
            r"\bCALL mlk_poly_frombytes(?:_c)?\(",
            functions,
        )
    ),
    "TOMONT_OCCURRENCE_COUNT": len(
        re.findall(
            r"\bmlk_poly_tomont\b",
            functions,
        )
    ),
    "NATIVE_OCCURRENCE_COUNT": len(
        re.findall(
            r"\bmlk_poly_tobytes_native\b",
            functions,
        )
    ),
    "OBSERVED_LOOP_COUNT": len(observed_loops),
    "EXPECTED_LOOP_COUNT": len(expected_loops),
    "MISSING_LOOP_COUNT": len(
        expected_loops - observed_loops
    ),
    "UNEXPECTED_LOOP_COUNT": len(
        observed_loops - expected_loops
    ),
    "MISSING_EDGE_COUNT": sum(
        edge not in graph
        for edge in required_edges
    ),
    "OBSERVED_LOOPS": ",".join(
        sorted(observed_loops)
    ),
}

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in values.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
