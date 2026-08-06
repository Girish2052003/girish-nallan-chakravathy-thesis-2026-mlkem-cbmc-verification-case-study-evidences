You are conducting a solution-blind, open-resource formal-verification
experiment on a frozen ML-KEM C implementation target.

EXPERIMENT ID:
<experiment identifier>

TARGET:
<exact target function or function group>

TARGET-SPECIFIC EMPHASIS:
<optional concise description of the intended function-level experiment;
do not provide a theorem, assertion, harness solution or expected result>

CONFIGURATION:
<ML-KEM parameter set and exact build configuration>

AUTHORITATIVE SOURCE IDENTITY:

ORIGIN_HEAD=af4c5abdd5958bdc65a03cd5ee86708264f93304
EXPECTED_COMMIT=af4c5abdd5958bdc65a03cd5ee86708264f93304

FROZEN PRODUCTION SOURCE:
<location of the supplied frozen mlkem-native source snapshot>

SUPPLIED SPECIFICATION MATERIAL:
<location of the supplied FIPS 203 and other permitted specification material>

DESIGNATED CLEAN-ROOM LOCATION:
<location in which the experiment workspace and generated artefacts may be
created>


1. EXPERIMENTAL PURPOSE

Independently analyse the supplied ML-KEM specification material and the
frozen production C implementation.

The purpose is to discover, formulate and investigate meaningful
implementation-level verification claims that are grounded in:

- the supplied specification;
- the actual production-code semantics;
- relevant C representations and arithmetic domains;
- the selected build configuration;
- and the behaviour of the exact target function or function group.

Produce CBMC-checkable artefacts for at least one selected primary claim,
execute the verification task, inspect failures or counterexamples, and
autonomously revise the artefact or strategy where technically justified.

The goal is not merely to make CBMC print a successful status. The selected
claim, assumptions, target binding, harness, assertions and CBMC configuration
must collectively express a meaningful, inspectable and appropriately scoped
verification problem.


2. MATERIAL-REVIEW REQUIREMENT

Before selecting a candidate theorem or property, systematically inspect the
supplied target material.

Read the complete textual experiment instructions and inspect all
target-relevant:

- specification passages;
- production source files;
- declarations and headers;
- data structures and types;
- macros and constants;
- build definitions;
- parameter-set definitions;
- direct dependencies;
- callers and callees when relevant;
- loop bounds, array accesses and pointer behaviour;
- representation conversions;
- arithmetic-domain assumptions;
- existing production comments or contracts that are unavoidably present
  inside the permitted source.

Do not rely only on filenames, previously generated summaries or an initial
source excerpt.

You may decide that some supplied material is irrelevant after inspecting it,
but do not silently ignore material that could materially affect the selected
claim.

Do not request substantive human guidance about theorem selection, property
design, assumptions, assertions, harness construction, verification strategy,
counterexample interpretation or repair.

When required evidence is missing, first attempt to resolve the gap using the
permitted source, specification, tools and general resources. If the gap
cannot be resolved, document it precisely and classify the affected result as
limited, inconclusive or unresolved rather than inventing information.


3. INITIAL THEOREM-DISCOVERY PLAN

Before implementing the authoritative verification artefact, create a concise
planning record.

Propose a small and technically justified set of candidate theorem families.

The preferred range is:

- at least one candidate theorem family;
- normally no more than four candidate theorem families.

Four is a maximum planning preference, not a quota. Do not manufacture weak,
duplicated or artificial candidates merely to reach a number.

Select the actual candidate count according to:

- the semantic richness of the target;
- the strength of available specification grounding;
- genuine separation between claims;
- CBMC feasibility;
- the expected experiment cost;
- and the need to investigate many other functions in the wider campaign.

For each candidate theorem family, record:

1. a precise provisional claim;
2. why the claim matters for the implementation;
3. its connection to specification and production code;
4. the intended input domain and substantive preconditions;
5. the verification obligations needed to investigate it;
6. how it differs materially from the other candidates;
7. the likely CBMC strategy;
8. foreseeable feasibility risks;
9. whether it is suitable as the primary end-to-end investigation.

The candidate theorem families must be substantively distinct.

Do not create separate theorem names for:

- equivalent assertions;
- cosmetic reformulations;
- the same claim under renamed variables;
- arbitrarily divided coefficients;
- trivially varied constants;
- minor syntactic changes to one underlying relationship;
- or the same mathematical idea expressed through different harness wording.

Distinctness should arise from a different semantic claim, relationship,
quantification, input domain, observation boundary or verification purpose.

After comparing the candidates, select at least one primary theorem or
property for complete investigation.

Additional candidates may be preserved without being fully proved when the
available experiment budget does not support complete investigation of all
of them.


4. THEOREMS AND VERIFICATION OBLIGATIONS

Treat a candidate theorem as a substantive implementation-level claim.

Treat verification obligations as the supporting checks required to establish
or meaningfully assess that claim under the recorded bounded model.

Depending on the selected theorem, relevant obligations may include:

- specification and source traceability;
- type and representation consistency;
- justified input-domain restrictions;
- arithmetic range and overflow reasoning;
- memory safety and array bounds;
- functional input-output relationships;
- relational or sequential behaviour;
- frame preservation or non-interference;
- target-call reachability;
- assertion reachability;
- feasibility of the assumption set;
- non-vacuity;
- build and source binding;
- mutation sensitivity;
- parameter-set consistency.

Do not maximise the number of obligations merely to make the theorem appear
stronger.

Include only obligations that are technically relevant to the selected claim.
Explain what each obligation contributes and whether it is:

- part of the theorem itself;
- a required precondition;
- a safety condition;
- a non-vacuity check;
- a supporting evidential check;
- or a limitation of the bounded model.


5. AUTONOMY

You own the complete technical process.

You may:

- inspect the supplied specification and source;
- determine relevant files and dependencies;
- formulate and compare candidate theorem families;
- choose the primary property;
- choose the verification strategy;
- create harnesses, contracts, scripts and temporary utilities;
- determine and justify assumptions;
- design assertions;
- invoke compilers, CBMC and related local tools;
- inspect counterexamples and failures;
- revise assumptions only when the revised domain is independently justified;
- strengthen, weaken, replace or abandon an unsuccessful candidate when
  scientifically appropriate;
- create the clean-room structure you consider useful;
- use permitted general technical documentation and internet resources;
- use any helper utilities available in the environment;
- ignore, repeat, bypass or replace an available utility;
- create new run-local utilities when useful;
- preserve additional candidate properties for later analysis.

You may organise the work in any order.

You are not required to follow a predefined pipeline, stage sequence or tool
order. No utility is mandatory.

A utility output is supporting information, not semantic authority. You remain
responsible for theorem selection, substantive assumptions, assertions,
counterexample interpretation, repair decisions and the final technical
account.

When a utility is unsuitable or fails, work directly or create an alternative
run-local method. Do not stop merely because an optional utility could not
complete its bounded task.


6. SOLUTION-BLIND AND ANTI-COPY RULE

This is an independent-discovery experiment.

Do not search for, retrieve, inspect, copy, rename, translate or lightly
modify an existing target-specific:

- CBMC harness;
- proof harness;
- function contract;
- theorem statement;
- assertion set;
- assumption package;
- successful command package;
- counterexample-repair history;
- mutation package;
- or completed verification solution.

Do not use an existing target-specific artefact as a starting template and
then claim independence because identifiers, comments, syntax or structure
were changed.

The withheld target-specific verification corpus must remain unconsulted
during the run.

General resources are permitted, including:

- FIPS 203 and supplied specification material;
- CBMC and GOTO-tool documentation;
- compiler documentation;
- C-language documentation;
- mathematical references;
- general formal-verification methods;
- generic CBMC examples that do not contain a solution for the selected
  target;
- general cryptographic implementation references that do not disclose the
  withheld target-specific verification answer.

When an external resource is intentionally consulted, record:

- what was consulted;
- why it was consulted;
- what general information was obtained;
- and how it influenced the work.

If a target-specific proof artefact is encountered accidentally:

1. stop inspecting it;
2. do not use its theorem, assumptions, assertion structure or harness design;
3. record the encounter and the accessible material;
4. continue independently where possible;
5. identify the possible contamination risk in the final account.

Repository distinctness and novelty will be evaluated externally after the
run is completed and the artefacts are frozen.


7. NOVELTY AND DISTINCTNESS CLAIM BOUNDARY

Aim to formulate independently derived, meaningful candidate claims that are
not obvious restatements of production comments or visible specification
sentences.

However, do not claim that a candidate theorem is:

- globally mathematically novel;
- absent from all academic literature;
- the first theorem of its kind;
- or previously unknown worldwide.

Those conclusions require an external prior-art and similarity investigation
that is outside this autonomous run.

During the run, use careful descriptions such as:

- independently proposed candidate theorem;
- implementation-level candidate property;
- candidate not derived from a supplied target-specific solution;
- candidate requiring external repository-distinctness review;
- apparently undocumented in the materials examined during the permitted run.

The final external evaluation will separately assess:

- exact duplication;
- normalised textual similarity;
- identifier-renamed similarity;
- structural or control-flow similarity;
- assumption-set overlap;
- assertion overlap;
- semantic equivalence;
- repository distinctness;
- and the defensibility of any later novelty statement.


8. SOURCE-INTEGRITY RULE

Treat the authoritative production-source snapshot as frozen.

Before substantive work, confirm that the available source identity is
consistent with:

ORIGIN_HEAD=af4c5abdd5958bdc65a03cd5ee86708264f93304
EXPECTED_COMMIT=af4c5abdd5958bdc65a03cd5ee86708264f93304

Do not modify authoritative production files to make a property pass.

Do not:

- replace the target implementation;
- stub the target call;
- redefine production behaviour;
- bypass the real implementation;
- silently alter constants or build flags;
- remove difficult execution paths;
- or change the implementation to match the assertion.

Experimental modifications are permitted only in clearly separated disposable
copies for diagnostics or mutation testing.

Preserve enough source, dependency, configuration and hash information to
demonstrate which production implementation and build model were analysed.


9. VERIFICATION EXPECTATIONS

Determine the verification approach independently.

The selected property must be grounded in the actual implementation and must
not be introduced only because a generic property category exists.

Where relevant, investigate:

- specification-to-code correspondence;
- arithmetic domains and representation assumptions;
- signed and unsigned conversion behaviour;
- modular and canonical representations;
- memory safety;
- array and pointer bounds;
- functional relationships;
- sequential composition;
- round-trip behaviour;
- frame and non-interference properties;
- target-call reachability;
- assertion reachability;
- non-vacuity;
- mutation sensitivity;
- exact source and build binding.

These are considerations, not a mandatory checklist.

Assumptions must be:

- explicit;
- individually inspectable;
- connected to specification, caller contract, representation invariant or
  clearly declared experiment scope;
- and no stronger than reasonably required for the selected claim.

Do not add an assumption solely to remove an inconvenient counterexample.

When a counterexample is excluded by a new assumption, explain why the
excluded state is outside the intended verification domain. Otherwise retain
the counterexample, revise the theorem or classify the result as failed or
limited.

Do not treat any of the following as verification of the selected property:

- an unreachable assertion;
- an infeasible target path;
- an `assume(false)`-equivalent condition;
- a tautological assertion;
- a property unrelated to the target call;
- successful compilation alone;
- successful CBMC execution without selected-claim coverage;
- or unrelated emitted properties passing.


10. ARTEFACT CONSTRUCTION AND CBMC EXECUTION

Create the artefacts required by the selected verification strategy.

These may include:

- a standard bounded harness;
- a relational or two-call harness;
- a sequential or round-trip harness;
- a loop or function contract;
- support code;
- deterministic build scripts;
- diagnostic scripts;
- property mappings;
- or other technically justified CBMC-compatible material.

Preserve the real production target call.

Run the relevant compiler, preprocessing and CBMC commands.

Record:

- exact working directory;
- exact command line;
- include paths;
- macros and parameter-set definitions;
- source files;
- unwind and object-bit settings;
- CBMC and compiler versions;
- exit status;
- raw standard output;
- raw standard error;
- structured output when available;
- emitted property identifiers;
- selected-property mapping;
- timeout or resource-limit status.

When execution fails:

1. determine whether the cause is the theorem, harness, assumption set,
   assertion, build context, unsupported construct, command configuration,
   resource limit or production implementation;
2. preserve the failed attempt;
3. perform autonomous repair when technically justified;
4. rerun the relevant checks;
5. document what changed and why.

Do not silently overwrite the meaningful history of failed attempts.


11. NON-VACUITY AND SUPPORTING EVIDENCE

A successful CBMC status is not sufficient on its own.

Where technically appropriate, produce supporting evidence concerning:

- feasibility of the assumption set;
- reachability of the production target;
- reachability of the selected assertion;
- execution of the intended path;
- selected-claim coverage;
- sensitivity to a caller-designed mutation;
- preservation of authoritative production files.

Design any substantive mutation yourself. A helper may apply and execute the
mutation mechanically, but the mutation rationale and expected evidential
effect remain your responsibility.

Clearly distinguish supporting evidence from theorem evidence.

For example:

- reachability supports non-vacuity but does not prove the theorem;
- mutation sensitivity supports usefulness but does not prove completeness;
- a clean structural audit identifies some red flags but does not validate
  mathematical assumptions.


12. EVIDENCE PRESERVATION

Inside the designated clean-room location, preserve enough material to
reconstruct and assess the experiment.

Preserve at minimum:

- the initial theorem-discovery plan;
- every candidate theorem family considered;
- the reason for the selected candidate count;
- the primary property selected;
- the specification and code grounding;
- the verification obligations;
- substantive assumptions and their justification;
- assertions and contracts;
- harnesses;
- supporting scripts and run-local utilities;
- exact commands;
- tool and environment versions;
- source and build identity;
- raw compiler and CBMC outputs;
- emitted and selected-property mappings;
- failed attempts;
- counterexamples;
- autonomous diagnosis and repair history;
- reachability or non-vacuity evidence;
- mutation design and results when used;
- external resources intentionally consulted;
- utility or skill use when observable;
- the final bounded result;
- limitations and unresolved questions.

Do not delete or hide failed attempts because a later attempt performed
better.

Preserve the meaningful development history while avoiding needless copies of
identical files.


13. RESULT INTERPRETATION

Distinguish clearly between:

1. command execution completed;
2. compilation or model construction completed;
3. CBMC emitted properties;
4. all emitted properties passed;
5. the selected claim was represented by one or more emitted properties;
6. selected-property coverage was complete;
7. target and assertion paths were reachable;
8. the selected property passed under the exact recorded bounded model;
9. supporting non-vacuity or mutation evidence was obtained;
10. broader implementation correctness.

Do not claim that a bounded CBMC result proves complete ML-KEM correctness.

Do not call CBMC itself the source of the theorem. The theorem is an
AI-generated candidate; CBMC supplies formal-tool evidence for the encoded
bounded claim.

Do not treat a successful result as evidence of global novelty.


14. COMPLETION AND STOPPING CONDITIONS

Continue autonomously until one of the following conditions applies:

A. VERIFIED CANDIDATE

A primary property has:

- a precise statement;
- explicit assumptions;
- executable CBMC artefacts;
- an exact recorded command;
- selected-claim mapping;
- a supported bounded result;
- and sufficient evidence to assess reachability and non-vacuity where
  relevant.

B. MEANINGFUL NEGATIVE RESULT

The investigation produced a technically informative failure, counterexample,
unsupported assumption, invalid candidate, build limitation or tool
limitation whose cause and evidence are preserved.

C. INCONCLUSIVE OR UNRESOLVED RESULT

Reasonable independent investigation did not resolve a genuine blocker, and
the blocker, attempted remedies and missing evidence are documented precisely.

D. RESOURCE OR ENVIRONMENT TERMINATION

The declared experiment budget, timeout or environment boundary was reached.
Preserve the current state and classify the result without manufacturing a
conclusion.

An honest failed, negative or inconclusive result is preferable to an
unsupported success claim.


15. FINAL ACCOUNT

At completion, provide a concise final account containing:

- target and build configuration;
- candidate theorem count and justification;
- candidate theorem families considered;
- selected primary theorem or property;
- why it is meaningful;
- specification and code grounding;
- verification obligations;
- important assumptions;
- generated artefacts;
- exact CBMC outcome;
- selected-claim coverage;
- autonomous diagnoses and repairs;
- non-vacuity or mutation evidence when produced;
- external sources intentionally consulted;
- possible contamination encounters;
- remaining validity risks;
- unresolved limitations;
- and the final result classification.

Do not claim repository distinctness or novelty as established within this
account. Mark those as pending external post-run evaluation.