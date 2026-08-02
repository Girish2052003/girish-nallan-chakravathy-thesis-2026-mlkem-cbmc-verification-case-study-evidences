# Open Property Discovery and Targeted Campaigns

The pipeline supports two scientifically distinct modes. Both use the same
Agents 1--11, run layout, critic, CBMC execution, repair flow, logging and final
reporting.

## Open discovery

Use `configs/CONFIG_TEMPLATE_OPEN_DISCOVERY.json` when the question is:

> What relevant formal-verification properties can the LLM identify from the
> supplied FIPS 203 text and selected C/header evidence?

Required block:

```json
"property_discovery": {
  "mode": "open_discovery",
  "catalogue_visibility": "hidden",
  "allow_uncatalogued_properties": true,
  "selected_property_id": null,
  "selection_policy": "feasibility_then_risk_then_rank"
}
```

Do not add a `property_campaign` block in this mode. Agents 2--4 receive no
P01--P26 family, title, strategy, support matrix or catalogue content. Agent 4
saves the raw LLM candidate set first. Deterministic post-processing then:

1. preserves the raw file byte-for-byte;
2. maps candidates to P01--P26 when a sufficiently clear mapping exists;
3. retains novel candidates as `UNMAPPED`;
4. selects exactly one concrete candidate before Agent 5;
5. records classification and selection as experiment metadata, not proof.

Agent 6 and CBMC remain strict. Open discovery does not approve weak, vacuous,
tautological, irrelevant or assumption-incomplete artefacts.

Set `selected_property_id` only when a human intentionally selects one of the
stable IDs produced by Agent 4. Otherwise the default policy selects by CBMC
feasibility, then risk, then the LLM ranking.

## Targeted campaign

Use an existing P01--P26 campaign when the question is:

> Can the workflow generate and check a candidate artefact for this deliberately
> selected property family?

```json
"property_discovery": {
  "mode": "targeted_campaign"
},
"property_campaign": {
  "property_family_id": "P16",
  "verification_strategy": "standard_cbmc_harness"
}
```

This preserves the historical behaviour. Existing configs that omit
`property_discovery` remain targeted campaigns for backward compatibility.

## Relationship to semantic advisory mode

For the primary LLM-first experiments, retain:

```json
"semantic_advisory_mode": "off"
```

This keeps deterministic semantic advice out of the LLM prompt. Open discovery
additionally hides even the preselected property-family and strategy context.
The post-discovery classifier never alters the authoritative raw LLM output.
