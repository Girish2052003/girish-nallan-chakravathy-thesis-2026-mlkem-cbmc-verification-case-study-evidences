# Repository-level comparison note

The tracked dedicated repository harness at the frozen commit contains one
call to `mlk_poly_sub(r, b)`. Its Makefile checks the existing
`mlk_poly_sub` function contract and applies loop contracts.

It does not call `mlk_poly_reduce`, does not compute an independent modular
oracle, and does not state the relational equation
`N(A-B) = N(N(A)-N(B))`.

This supports only a repository-level distinction. It is not, by itself, a
worldwide novelty finding. Public-code and literature equivalence review
remain separate.
