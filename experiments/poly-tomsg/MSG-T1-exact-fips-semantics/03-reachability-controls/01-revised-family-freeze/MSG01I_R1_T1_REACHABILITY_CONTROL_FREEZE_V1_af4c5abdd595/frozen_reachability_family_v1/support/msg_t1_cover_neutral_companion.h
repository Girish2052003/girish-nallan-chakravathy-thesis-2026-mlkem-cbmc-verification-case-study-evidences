#ifndef MSG_T1_COVER_NEUTRAL_COMPANION_H
#define MSG_T1_COVER_NEUTRAL_COMPANION_H

/*
 * Companion-only transformation.
 *
 * The untouched original model retains all cover instructions for explicit
 * --cover cover execution. This separately named companion model neutralises
 * covers so ordinary assertions, safety checks and unwinding assertions can
 * be proved independently.
 */
#define __CPROVER_cover(condition) ((void)0)

#endif
