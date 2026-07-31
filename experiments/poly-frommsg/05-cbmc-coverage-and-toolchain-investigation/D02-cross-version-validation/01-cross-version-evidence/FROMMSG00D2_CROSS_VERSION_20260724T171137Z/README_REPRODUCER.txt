Finding under investigation:

CBMC may internally abort when the built-in __CPROVER_cover function is
manually redeclared using an incompatible parameter type and coverage
instrumentation is requested.

Canonical control:
  int main(void)
  {
    __CPROVER_cover(1);
    return 0;
  }

Candidate reproducer:
  void __CPROVER_cover(_Bool condition);

  int main(void)
  {
    __CPROVER_cover((_Bool)1);
    return 0;
  }

Failing command under affected versions:
  cbmc 02_wrong_bool.c --function main --cover cover

Expected:
  A controlled diagnostic rejecting the incompatible built-in declaration.

Candidate actual behaviour:
  Exit status 134 and an internal invariant failure in not_exprt.
