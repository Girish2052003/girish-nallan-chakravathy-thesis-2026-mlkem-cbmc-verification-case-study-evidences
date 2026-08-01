# PBCODEC-CV1 Verification Intent

## Classification

This campaign is a direct production-to-production composition validation.

It is not counted as:
- a new implementation function;
- a new mathematical encoding theorem;
- a fifth PBYTES theorem;
- a fifth PFB theorem;
- a worldwide-first mathematical result.

## Source binding

- Commit: af4c5abdd5958bdc65a03cd5ee86708264f93304
- Source tree: 54805daff6a91a010c05467ea678117c42a71559
- Public encoder: mlk_poly_tobytes
- Portable encoder body: mlk_poly_tobytes_c
- Public decoder: mlk_poly_frombytes
- Portable decoder body: mlk_poly_frombytes_c

## CV1.P1

For every polynomial p whose coefficients satisfy:

    0 <= p[i] < MLKEM_Q

executing the real public mlk_poly_tobytes wrapper followed by the real
public mlk_poly_frombytes wrapper recovers p coefficient-wise.

## CV1.P2

For every 384-byte input whose 256 decoded 12-bit fields are all below
MLKEM_Q, executing the real public mlk_poly_frombytes wrapper followed
by the real public mlk_poly_tobytes wrapper reproduces the input bytes.

## Required execution conditions

- Both public wrappers must be directly called by each positive harness.
- Both portable C bodies must remain present and reachable.
- Function-contract replacement is prohibited.
- Loop-contract application is prohibited.
- Production source modification is prohibited.
- The P2 domain predicate may establish canonicality only.
- No independent encoder or decoder may replace either production call.
- All relevant loops must be completely unwound.

## Prior-result relationship

CV1 corroborates the previously accepted independent PBYTES and PFB
refinement campaigns. It is not presented as a logically independent
mathematical theorem.
