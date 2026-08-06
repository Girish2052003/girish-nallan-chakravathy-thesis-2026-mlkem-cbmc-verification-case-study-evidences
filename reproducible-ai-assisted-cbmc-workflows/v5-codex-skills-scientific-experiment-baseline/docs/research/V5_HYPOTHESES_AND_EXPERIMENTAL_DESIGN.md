# Part VII — V5 Hypotheses and Experimental Design

## 39. Primary research hypothesis

> Under identical source, specification, environment, task, and resource conditions, Codex with access to the bounded V5 helper skills will produce more execution-ready and evidentially complete CBMC artefacts than Codex without those skills, without transferring property selection or semantic verification authority to the helper layer.

## 40. Efficiency hypothesis

> Skill-assisted Codex will require fewer avoidable iterations caused by specification retrieval, source/build mapping, CBMC invocation, trace inspection, evidence loss, and structural harness defects.

## 41. Attribution hypothesis

> Because the skills exclude theorem selection, substantive assumption generation, assertion design, counterexample interpretation, and repair choice, candidate semantic content will be more directly attributable to Codex than in the V3/V4 multi-LLM architecture.

## 42. Robustness hypothesis

> Replacing mandatory stage transitions with optional bounded skills will reduce failures caused by orchestration state, schema handoffs, critic routing, and formal-strategy reconciliation.

## 43. Portability hypothesis

> Repository-scoped file-based helper skills will be easier to transfer among suitable C/CBMC targets than the complete V1–V4 orchestrator-centred platform.

## 44. Null and adverse possibilities

A scientific experiment must permit V5 to fail. Possible outcomes include:

- Codex ignores useful skills;
- skill descriptions distract or bias property selection;
- skill reports consume context without improving results;
- Codex over-trusts lexical or normalized evidence;
- optionality causes meandering and duplicated effort;
- unassisted Codex performs equally well or better;
- Skill 9 provides an unfair evidential advantage;
- repository-specific assumptions reduce portability;
- the skills themselves contain integration defects not found by synthetic tests.

These outcomes would not invalidate the research. They would define the limits of skill-assisted formal verification.

## 45. Proposed conditions

### Condition A — unassisted Codex

Codex receives the frozen repository, specification package, task, common instructions, tool environment, sandbox, budget, and external instrumentation, but no V5 helper skills.

### Condition B — Codex with eight core skills

The same environment is used, with Skills 1–8 available. Codex may use, ignore, repeat, or replace them.

### Condition B+ — advanced mutation support

Condition B plus Skill 9. This may be analysed separately because mutation execution changes the strength of available evidence.

## 46. Common controls

The following must be identical across conditions:

- source revision and hashes;
- specification package;
- target function and task wording;
- Codex model/version and settings;
- sandbox and approval policy;
- internet policy;
- CBMC/compiler versions;
- time, token, command, and iteration budgets;
- initial absence of target-specific native proof solutions;
- event capture;
- post-run anti-copy audit;
- external evaluation rubric.

## 47. Outcomes to measure

Potential measures include:

- candidate properties produced;
- specification/code traceability;
- execution-ready artefacts;
- number and quality of substantive assumptions;
- assertion relevance and non-triviality;
- successful target/build binding;
- CBMC invocation success;
- selected-property status under the bounded model;
- target and assertion reachability;
- mutation sensitivity;
- number of avoidable iterations;
- elapsed time and command count;
- amount of human correction;
- evidence completeness;
- skill discovery and invocation behavior;
- independent/uncopied classification;
- final usefulness category.

## 48. Anti-copy placement

The withheld reference corpus must remain inaccessible during the run. An anti-copy oracle exposed to Codex would leak whether an equivalent solution exists and allow iterative probing or cosmetic evasion.

The correct sequence is:

```text
Codex run completes
→ artefacts frozen
→ independent exact/token/AST/semantic similarity audit
→ human contamination classification
```

This audit must be applied identically to all conditions.

---
