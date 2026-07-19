# VC-SR1 classifier-v1 false-negative record

Classifier v1 required a separate returned unwinding property for every
reachable source loop.

That requirement was invalid. The frozen CBMC command explicitly enabled
unwinding assertions and supplied exact bounds for all ten reachable loops.
The completed run returned the exact frozen 89-property set, with all 89
properties successful, exit status zero, empty stderr, and the CBMC
VERIFICATION SUCCESSFUL message.

No property or solver failure occurred. Classifier v1 is retained as rejected
analysis evidence and is superseded by classifier v2.

Rejected classification:
FAIL_UNEXPECTED

Correction category:
CLASSIFIER_FALSE_NEGATIVE_UNWIND_REPORTING_ASSUMPTION
