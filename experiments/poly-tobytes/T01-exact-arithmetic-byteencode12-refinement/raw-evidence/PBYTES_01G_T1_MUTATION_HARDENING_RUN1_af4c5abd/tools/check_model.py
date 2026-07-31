from __future__ import annotations

import re
import shlex
import sys
from pathlib import Path

functions_path = Path(sys.argv[1])
loops_path = Path(sys.argv[2])
graph_path = Path(sys.argv[3])
env_path = Path(sys.argv[4])

functions = functions_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loops_text = loops_path.read_text(
    encoding="utf-8",
    errors="replace",
)

graph = graph_path.read_text(
    encoding="utf-8",
    errors="replace",
)

expected_loops = {
    "harness.0",
    "harness.1",
    "harness.2",
    "harness.3",
    "harness.4",
    "harness.5",
    "mlk_poly_tobytes_c.0",
}

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
}

with env_path.open("w", encoding="utf-8") as stream:
    for key, value in values.items():
        stream.write(
            f"{key}={shlex.quote(str(value))}\n"
        )
