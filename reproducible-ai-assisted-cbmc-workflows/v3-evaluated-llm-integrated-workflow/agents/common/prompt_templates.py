"""
prompt_templates.py

Shared prompt rules for LLM-backed thesis workflow stages.

These templates preserve the agreed trust boundary:
- Raw FIPS/code/tool evidence is primary.
- Deterministic Python output is advisory only.
- LLM output is the authoritative candidate output for that stage, not formal truth.
- Existing proof artefacts and deterministic templates must not be copied.
"""

from __future__ import annotations

from typing import Optional


COMMON_LLM_STAGE_PREAMBLE = """
You are the authoritative LLM reasoning component for this workflow stage.

In this workflow, “authoritative” means that your structured JSON response becomes the stage output passed to the next workflow component. It does not mean that your conclusions are proven, formally verified, or automatically correct.

Primary evidence outranks deterministic advisory material. Treat deterministic Python analysis only as fallible local hints, diagnostics, or baseline material. Do not copy it blindly. Verify every important claim against the provided primary evidence. If deterministic analysis conflicts with primary evidence, reject or downgrade the deterministic claim and record the disagreement.

Do not claim proof, verification, implementation correctness, FIPS compliance, cryptographic security, full functional correctness, or full ML-KEM correctness unless such a claim is explicitly supported by formal tool output and the workflow schema allows that wording.

Return only valid JSON matching the required schema.
""".strip()


EVIDENCE_HIERARCHY = """
Evidence priority, from strongest to weakest:

1. Raw FIPS 203 material, selected official specification excerpts, implementation source files, header files, build/proof configuration files, and existing repository comments/contracts/annotations.
2. Raw CBMC or formal-tool output when the stage analyses tool results.
3. Previous LLM stage outputs, but only as candidate workflow records.
4. Deterministic Python local analysis, diagnostics, hints, baseline summaries, or templates.
5. Model inference.

If evidence is missing, mark the claim as uncertain instead of inventing facts.
""".strip()


DETERMINISTIC_REFERENCE_RULE = """
Deterministic Python outputs may be provided as advisory reference material. They are not authoritative. Use them only to locate potentially relevant information, detect possible structure, compare candidate interpretations, or identify possible mistakes.

Do not copy deterministic summaries, deterministic properties, deterministic assertions, deterministic harness templates, deterministic review comments, deterministic repair plans, or deterministic evaluation text blindly. Independently verify all important claims against primary evidence.

If a deterministic hint is useful, record how it was used. If it is unsupported or contradicted, reject or downgrade it and record the disagreement.
""".strip()


INDEPENDENT_REASONING_NON_COPYING_RULE = """
Some provided materials may include existing proof harnesses, repository verification files, deterministic Python-generated artefacts, previous candidate harnesses, previous repair attempts, or human-corrected examples. Treat these materials as comparison, diagnostics, or advisory context only.

Do not copy existing repository proof harnesses, deterministic templates, previous generated harnesses, previous repair patches, or human-corrected artefacts verbatim or near-verbatim. Do not preserve their structure merely by renaming variables or reordering statements. Use them only to understand constraints, avoid known mistakes, identify required dependencies, and compare your candidate design against existing approaches.

Your output must be independently reasoned from the primary evidence: the FIPS 203 material, selected implementation source files, header files, constants, function signatures, comments, contracts, and available tool evidence. Preserve exact implementation identifiers where required, such as function names, type names, macro names, constants, include names, and field names. These required identifiers are not considered copying.

If your candidate artefact is necessarily similar to an existing harness because the same target function, types, constants, or CBMC primitives must be used, explicitly explain which similarities are unavoidable and which design choices are independently introduced.

If you rely on any idea from advisory material, record it as an influence and explain how your generated candidate differs from it.

Do not claim global novelty. Use careful wording such as “independently generated candidate harness,” “structurally distinct candidate artefact,” or “separate candidate harness variant.”
""".strip()


JSON_ONLY_RULE = """
Output requirement:

Return only a valid JSON object matching the required schema. Do not include Markdown fences, commentary, apologies, explanations outside JSON, or prose before or after the JSON object.
""".strip()


def build_common_stage_prompt(
    *,
    stage_name: str,
    task_description: str,
    responsibilities: str,
    prohibitions: str,
    schema_summary: Optional[str] = None,
    include_non_copying_rule: bool = False,
) -> str:
    parts = [
        COMMON_LLM_STAGE_PREAMBLE,
        "",
        f"Stage name: {stage_name}",
        "",
        "Stage task:",
        task_description.strip(),
        "",
        EVIDENCE_HIERARCHY,
        "",
        DETERMINISTIC_REFERENCE_RULE,
    ]

    if include_non_copying_rule:
        parts.extend(["", INDEPENDENT_REASONING_NON_COPYING_RULE])

    parts.extend([
        "",
        "Your responsibilities:",
        responsibilities.strip(),
        "",
        "Do not:",
        prohibitions.strip(),
    ])

    if schema_summary:
        parts.extend(["", "Required schema summary:", schema_summary.strip()])

    parts.extend(["", JSON_ONLY_RULE])

    return "\n".join(parts).strip() + "\n"
