# SUB-00H execution boundary

This run executes the unchanged SUB-T1 theorem from the accepted SUB-00G-R2
pragma-scoped GOTO model.

The run does not:

- rebuild the GOTO model;
- edit the frozen theorem harness;
- edit production poly.c;
- use the target function contract as an abstraction;
- apply source loop contracts;
- establish novelty by itself.

A zero CBMC exit code remains subject to independent result review.
