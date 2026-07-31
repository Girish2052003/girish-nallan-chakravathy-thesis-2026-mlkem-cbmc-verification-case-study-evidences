# `mlk_poly_frombytes` CBMC campaign evidence

This directory contains preservation-first classified evidence for the portable public `mlk_poly_frombytes` path at mlkem-native commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`.

The scientific sections are:

- `00-campaign-context`: theorem preregistration, scope, source binding, and the retained broken attempt;
- `PFB-T1-exact-raw-decoding`: exact 12-bit raw decoding semantics;
- `PFB-T2-bit-routing-and-block-locality`: exact bit influence and one-block locality;
- `PFB-T3-differential-conservation`: arbitrary differential conservation and injectivity support;
- `PFB-T4-raw-domain-inversion`: two-sided inversion over the complete raw 12-bit domain;
- `90-archive-companions`: original frozen `.tar.gz` packages;
- `98-campaign-closure-and-seal`: accepted combined campaign seal;
- `99-audit`: classification and exact-duplicate ledgers.

Exact duplicates were removed only under the conservative rule “same basename and identical SHA-256”. Every original path remains reconstructible from the mapping ledger.
