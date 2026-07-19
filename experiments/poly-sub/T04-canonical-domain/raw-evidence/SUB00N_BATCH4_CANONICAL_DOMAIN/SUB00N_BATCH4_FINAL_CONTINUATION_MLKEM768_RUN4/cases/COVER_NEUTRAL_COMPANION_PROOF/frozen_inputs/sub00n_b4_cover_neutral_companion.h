#ifndef SUB00N_B4_COVER_NEUTRAL_COMPANION_H
#define SUB00N_B4_COVER_NEUTRAL_COMPANION_H

/*
 * Companion-verification adapter only.
 *
 * The original frozen reachability harness contains five
 * __CPROVER_cover calls. Outside CBMC coverage mode those calls remain
 * unresolved and produce main.no-body.__CPROVER_cover.
 *
 * This header neutralizes only those coverage observations while
 * constructing a separate companion-verification GOTO model.
 *
 * The original frozen harness and original coverage model are unchanged.
 */

#ifdef __CPROVER_cover
#undef __CPROVER_cover
#endif

#define __CPROVER_cover(condition) ((void)0)

#endif
