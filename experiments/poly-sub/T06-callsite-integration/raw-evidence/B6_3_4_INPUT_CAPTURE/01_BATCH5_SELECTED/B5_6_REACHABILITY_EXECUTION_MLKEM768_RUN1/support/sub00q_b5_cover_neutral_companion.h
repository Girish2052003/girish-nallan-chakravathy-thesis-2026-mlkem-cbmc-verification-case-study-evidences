#ifndef SUB00Q_B5_COVER_NEUTRAL_COMPANION_H
#define SUB00Q_B5_COVER_NEUTRAL_COMPANION_H

/*
 * B5.6 proof-only companion transformation.
 *
 * __CPROVER_cover is observational and must not affect program state.
 * It is neutralised only in separately named companion GOTO binaries so
 * ordinary CBMC proof execution can retain --unwinding-assertions.
 *
 * The original frozen harnesses and original B5.4 GOTO models are unchanged
 * and are used for the actual --cover cover reachability runs.
 */
#define __CPROVER_cover(condition) ((void)0)

#endif
