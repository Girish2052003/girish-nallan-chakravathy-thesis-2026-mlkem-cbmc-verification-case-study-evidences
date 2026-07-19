# PA-05 `mlk_poly_add` Production Call-Site Context Bundle

## 1. Collection Identity

- Repository root: `/home/girish/THESIS-2026/mlkem-native`
- Commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Parameter-set analysis target: `ML-KEM-768`
- Production calls found: `3`
- Production source modified: `No`

## 2. Git Status

```text
?? .cleanroom_mlk_poly_add_fips_relational_harness.c.swp
?? cleanroom_mlk_poly_add_fips_relational_harness.c
?? cleanroom_mlk_poly_add_fips_relational_harness_v2.c
?? cleanroom_results/
?? collect_pa05_mlk_poly_add_callsite_context.py
?? pa02_mlk_poly_add_full_signed_contract_valid_harness.c
?? pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c
?? pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c
?? pa02b_terminal_run.log
?? pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c
?? pa02c_terminal_run.log
?? pa02d_mlk_poly_add_commutativity_contract_valid_harness.c
?? pa02d_terminal_run.log
?? pa02e_mlk_poly_add_additive_identity_full_signed_harness.c
?? pa02e_terminal_run.log
?? pa03_mlk_poly_add_unrestricted_negative_control_harness.c
?? pa04a_mlk_poly_add_alias_safe_doubling_harness.c
?? pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c
?? run_cleanroom_mlk_poly_add_cbmc.sh
?? run_cleanroom_mlk_poly_add_cbmc_v2.sh
?? run_pa02_mlk_poly_add_full_signed_cbmc.sh
?? run_pa02a_mlk_poly_add_exact_signed_cbmc.sh
?? run_pa02b_mlk_poly_add_modq_refinement_cbmc.sh
?? run_pa02c_mlk_poly_add_readonly_frame_cbmc.sh
?? run_pa02d_mlk_poly_add_commutativity_cbmc.sh
?? run_pa02e_mlk_poly_add_additive_identity_cbmc.sh
?? run_pa03_mlk_poly_add_unrestricted_negative_control.sh
?? run_pa04_mlk_poly_add_aliasing_campaign.sh
```

## 3. All `mlk_poly_add` References

```text
mlkem/src/indcpa.c:571:  mlk_poly_add(v, epp);
mlkem/src/indcpa.c:572:  mlk_poly_add(v, k);
mlkem/src/poly.c:229:void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.h:181:#define mlk_poly_add MLK_NAMESPACE(poly_add)
mlkem/src/poly.h:196: * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
mlkem/src/poly.h:200:void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly_k.c:278:    mlk_poly_add(&r->vec[i], &b->vec[i]);
```

## 4.1. Call Site 1: `mlkem/src/indcpa.c:571`

### Exact call

```c
mlk_poly_add(v, epp);
```

### Enclosing production function

```c
511 | 
512 | /* Reference: `indcpa_enc()` in the reference implementation @[REF].
513 |  *            - We use x4-batched versions of `poly_getnoise` to leverage
514 |  *              batched x4-batched Keccak-f1600.
515 |  *            - We use a different implementation of `gen_matrix()` which
516 |  *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
517 |  *            - We use a mulcache to speed up matrix-vector multiplication.
518 |  *            - We include buffer zeroization.
519 |  */
520 | MLK_INTERNAL_API
521 | int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
522 |                    const uint8_t m[MLKEM_INDCPA_MSGBYTES],
523 |                    const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
524 |                    const uint8_t coins[MLKEM_SYMBYTES],
525 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
526 | {
527 |   int ret = 0;
528 |   MLK_ALLOC(seed, uint8_t, MLKEM_SYMBYTES, context);
529 |   MLK_ALLOC(at, mlk_polymat, 1, context);
530 |   MLK_ALLOC(sp, mlk_polyvec, 1, context);
531 |   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
532 |   MLK_ALLOC(ep, mlk_polyvec, 1, context);
533 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
534 |   MLK_ALLOC(v, mlk_poly, 1, context);
535 |   MLK_ALLOC(k, mlk_poly, 1, context);
536 |   MLK_ALLOC(epp, mlk_poly, 1, context);
537 |   MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);
538 | 
539 |   if (seed == NULL || at == NULL || sp == NULL || pkpv == NULL || ep == NULL ||
540 |       b == NULL || v == NULL || k == NULL || epp == NULL || sp_cache == NULL)
541 |   {
542 |     ret = MLK_ERR_OUT_OF_MEMORY;
543 |     goto cleanup;
544 |   }
545 | 
546 |   mlk_unpack_pk(pkpv, seed, pk);
547 |   mlk_poly_frommsg(k, m);
548 | 
549 |   /*
550 |    * Declassify the public seed.
551 |    * Required to use it in conditional-branches in rejection sampling.
552 |    * This is needed because in re-encryption the publicseed originated from sk
553 |    * which is marked undefined.
554 |    */
555 |   MLK_CT_TESTING_DECLASSIFY(seed, MLKEM_SYMBYTES);
556 | 
557 |   mlk_gen_matrix(at, seed, 1 /* transpose */);
558 | 
559 |   mlk_enc_getnoise_eta1_eta2(sp, ep, epp, coins);
560 | 
561 |   mlk_polyvec_ntt(sp);
562 | 
563 |   mlk_polyvec_mulcache_compute(sp_cache, sp);
564 |   mlk_matvec_mul(b, at, sp, sp_cache);
565 |   mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);
566 | 
567 |   mlk_polyvec_invntt_tomont(b);
568 |   mlk_poly_invntt_tomont(v);
569 | 
570 |   mlk_polyvec_add(b, ep);
571 |   mlk_poly_add(v, epp);
572 |   mlk_poly_add(v, k);
573 | 
574 |   mlk_polyvec_reduce(b);
575 |   mlk_poly_reduce(v);
576 | 
577 |   mlk_pack_ciphertext(c, b, v);
578 | 
579 | cleanup:
580 |   /* Specification: Partially implements
581 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
582 |   MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
583 |   MLK_FREE(epp, mlk_poly, 1, context);
584 |   MLK_FREE(k, mlk_poly, 1, context);
585 |   MLK_FREE(v, mlk_poly, 1, context);
586 |   MLK_FREE(b, mlk_polyvec, 1, context);
587 |   MLK_FREE(ep, mlk_polyvec, 1, context);
588 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
589 |   MLK_FREE(sp, mlk_polyvec, 1, context);
590 |   MLK_FREE(at, mlk_polymat, 1, context);
591 |   MLK_FREE(seed, uint8_t, MLKEM_SYMBYTES, context);
592 |   return ret;
593 | }
```

### Local context window

```c
491 | 
492 |   mlk_polyvec_add(pkpv, e);
493 |   mlk_polyvec_reduce(pkpv);
494 |   mlk_polyvec_reduce(skpv);
495 | 
496 |   mlk_pack_sk(sk, skpv);
497 |   mlk_pack_pk(pk, pkpv, publicseed);
498 | 
499 | cleanup:
500 |   /* Specification: Partially implements
501 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
502 |   MLK_FREE(skpv_cache, mlk_polyvec_mulcache, 1, context);
503 |   MLK_FREE(skpv, mlk_polyvec, 1, context);
504 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
505 |   MLK_FREE(e, mlk_polyvec, 1, context);
506 |   MLK_FREE(a, mlk_polymat, 1, context);
507 |   MLK_FREE(coins_with_domain_separator, uint8_t, MLKEM_SYMBYTES + 1, context);
508 |   MLK_FREE(buf, uint8_t, 2 * MLKEM_SYMBYTES, context);
509 |   return ret;
510 | }
511 | 
512 | /* Reference: `indcpa_enc()` in the reference implementation @[REF].
513 |  *            - We use x4-batched versions of `poly_getnoise` to leverage
514 |  *              batched x4-batched Keccak-f1600.
515 |  *            - We use a different implementation of `gen_matrix()` which
516 |  *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
517 |  *            - We use a mulcache to speed up matrix-vector multiplication.
518 |  *            - We include buffer zeroization.
519 |  */
520 | MLK_INTERNAL_API
521 | int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
522 |                    const uint8_t m[MLKEM_INDCPA_MSGBYTES],
523 |                    const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
524 |                    const uint8_t coins[MLKEM_SYMBYTES],
525 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
526 | {
527 |   int ret = 0;
528 |   MLK_ALLOC(seed, uint8_t, MLKEM_SYMBYTES, context);
529 |   MLK_ALLOC(at, mlk_polymat, 1, context);
530 |   MLK_ALLOC(sp, mlk_polyvec, 1, context);
531 |   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
532 |   MLK_ALLOC(ep, mlk_polyvec, 1, context);
533 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
534 |   MLK_ALLOC(v, mlk_poly, 1, context);
535 |   MLK_ALLOC(k, mlk_poly, 1, context);
536 |   MLK_ALLOC(epp, mlk_poly, 1, context);
537 |   MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);
538 | 
539 |   if (seed == NULL || at == NULL || sp == NULL || pkpv == NULL || ep == NULL ||
540 |       b == NULL || v == NULL || k == NULL || epp == NULL || sp_cache == NULL)
541 |   {
542 |     ret = MLK_ERR_OUT_OF_MEMORY;
543 |     goto cleanup;
544 |   }
545 | 
546 |   mlk_unpack_pk(pkpv, seed, pk);
547 |   mlk_poly_frommsg(k, m);
548 | 
549 |   /*
550 |    * Declassify the public seed.
551 |    * Required to use it in conditional-branches in rejection sampling.
552 |    * This is needed because in re-encryption the publicseed originated from sk
553 |    * which is marked undefined.
554 |    */
555 |   MLK_CT_TESTING_DECLASSIFY(seed, MLKEM_SYMBYTES);
556 | 
557 |   mlk_gen_matrix(at, seed, 1 /* transpose */);
558 | 
559 |   mlk_enc_getnoise_eta1_eta2(sp, ep, epp, coins);
560 | 
561 |   mlk_polyvec_ntt(sp);
562 | 
563 |   mlk_polyvec_mulcache_compute(sp_cache, sp);
564 |   mlk_matvec_mul(b, at, sp, sp_cache);
565 |   mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);
566 | 
567 |   mlk_polyvec_invntt_tomont(b);
568 |   mlk_poly_invntt_tomont(v);
569 | 
570 |   mlk_polyvec_add(b, ep);
571 |   mlk_poly_add(v, epp);
572 |   mlk_poly_add(v, k);
573 | 
574 |   mlk_polyvec_reduce(b);
575 |   mlk_poly_reduce(v);
576 | 
577 |   mlk_pack_ciphertext(c, b, v);
578 | 
579 | cleanup:
580 |   /* Specification: Partially implements
581 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
582 |   MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
583 |   MLK_FREE(epp, mlk_poly, 1, context);
584 |   MLK_FREE(k, mlk_poly, 1, context);
585 |   MLK_FREE(v, mlk_poly, 1, context);
586 |   MLK_FREE(b, mlk_polyvec, 1, context);
587 |   MLK_FREE(ep, mlk_polyvec, 1, context);
588 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
589 |   MLK_FREE(sp, mlk_polyvec, 1, context);
590 |   MLK_FREE(at, mlk_polymat, 1, context);
591 |   MLK_FREE(seed, uint8_t, MLKEM_SYMBYTES, context);
592 |   return ret;
593 | }
594 | 
595 | /* Reference: `indcpa_dec()` in the reference implementation @[REF].
596 |  *            - We use a mulcache for the scalar product.
597 |  *            - We include buffer zeroization. */
598 | MLK_INTERNAL_API
599 | int mlk_indcpa_dec(uint8_t m[MLKEM_INDCPA_MSGBYTES],
600 |                    const uint8_t c[MLKEM_INDCPA_BYTES],
601 |                    const uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
602 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
603 | {
604 |   int ret = 0;
605 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
606 |   MLK_ALLOC(skpv, mlk_polyvec, 1, context);
607 |   MLK_ALLOC(v, mlk_poly, 1, context);
608 |   MLK_ALLOC(sb, mlk_poly, 1, context);
609 |   MLK_ALLOC(b_cache, mlk_polyvec_mulcache, 1, context);
610 | 
611 |   if (b == NULL || skpv == NULL || v == NULL || sb == NULL || b_cache == NULL)
612 |   {
613 |     ret = MLK_ERR_OUT_OF_MEMORY;
614 |     goto cleanup;
615 |   }
616 | 
617 |   mlk_unpack_ciphertext(b, v, c);
618 |   mlk_unpack_sk(skpv, sk);
619 | 
620 |   mlk_polyvec_ntt(b);
621 |   mlk_polyvec_mulcache_compute(b_cache, b);
622 |   mlk_polyvec_basemul_acc_montgomery_cached(sb, skpv, b, b_cache);
623 |   mlk_poly_invntt_tomont(sb);
624 | 
625 |   mlk_poly_sub(v, sb);
626 |   mlk_poly_reduce(v);
627 | 
628 |   mlk_poly_tomsg(m, v);
629 | 
630 | cleanup:
631 |   /* Specification: Partially implements
632 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
633 |   MLK_FREE(b_cache, mlk_polyvec_mulcache, 1, context);
634 |   MLK_FREE(sb, mlk_poly, 1, context);
635 |   MLK_FREE(v, mlk_poly, 1, context);
636 |   MLK_FREE(skpv, mlk_polyvec, 1, context);
637 |   MLK_FREE(b, mlk_polyvec, 1, context);
638 |   return ret;
639 | }
640 | 
641 | /* To facilitate single-compilation-unit (SCU) builds, undefine all macros.
642 |  * Don't modify by hand -- this is auto-generated by scripts/autogen. */
643 | #undef mlk_pack_pk
644 | #undef mlk_unpack_pk
645 | #undef mlk_pack_sk
646 | #undef mlk_unpack_sk
647 | #undef mlk_pack_ciphertext
648 | #undef mlk_unpack_ciphertext
649 | #undef mlk_matvec_mul
650 | #undef mlk_polyvec_permute_bitrev_to_custom
651 | #undef mlk_polymat_permute_bitrev_to_custom
```

## 4.2. Call Site 2: `mlkem/src/indcpa.c:572`

### Exact call

```c
mlk_poly_add(v, k);
```

### Enclosing production function

```c
511 | 
512 | /* Reference: `indcpa_enc()` in the reference implementation @[REF].
513 |  *            - We use x4-batched versions of `poly_getnoise` to leverage
514 |  *              batched x4-batched Keccak-f1600.
515 |  *            - We use a different implementation of `gen_matrix()` which
516 |  *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
517 |  *            - We use a mulcache to speed up matrix-vector multiplication.
518 |  *            - We include buffer zeroization.
519 |  */
520 | MLK_INTERNAL_API
521 | int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
522 |                    const uint8_t m[MLKEM_INDCPA_MSGBYTES],
523 |                    const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
524 |                    const uint8_t coins[MLKEM_SYMBYTES],
525 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
526 | {
527 |   int ret = 0;
528 |   MLK_ALLOC(seed, uint8_t, MLKEM_SYMBYTES, context);
529 |   MLK_ALLOC(at, mlk_polymat, 1, context);
530 |   MLK_ALLOC(sp, mlk_polyvec, 1, context);
531 |   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
532 |   MLK_ALLOC(ep, mlk_polyvec, 1, context);
533 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
534 |   MLK_ALLOC(v, mlk_poly, 1, context);
535 |   MLK_ALLOC(k, mlk_poly, 1, context);
536 |   MLK_ALLOC(epp, mlk_poly, 1, context);
537 |   MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);
538 | 
539 |   if (seed == NULL || at == NULL || sp == NULL || pkpv == NULL || ep == NULL ||
540 |       b == NULL || v == NULL || k == NULL || epp == NULL || sp_cache == NULL)
541 |   {
542 |     ret = MLK_ERR_OUT_OF_MEMORY;
543 |     goto cleanup;
544 |   }
545 | 
546 |   mlk_unpack_pk(pkpv, seed, pk);
547 |   mlk_poly_frommsg(k, m);
548 | 
549 |   /*
550 |    * Declassify the public seed.
551 |    * Required to use it in conditional-branches in rejection sampling.
552 |    * This is needed because in re-encryption the publicseed originated from sk
553 |    * which is marked undefined.
554 |    */
555 |   MLK_CT_TESTING_DECLASSIFY(seed, MLKEM_SYMBYTES);
556 | 
557 |   mlk_gen_matrix(at, seed, 1 /* transpose */);
558 | 
559 |   mlk_enc_getnoise_eta1_eta2(sp, ep, epp, coins);
560 | 
561 |   mlk_polyvec_ntt(sp);
562 | 
563 |   mlk_polyvec_mulcache_compute(sp_cache, sp);
564 |   mlk_matvec_mul(b, at, sp, sp_cache);
565 |   mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);
566 | 
567 |   mlk_polyvec_invntt_tomont(b);
568 |   mlk_poly_invntt_tomont(v);
569 | 
570 |   mlk_polyvec_add(b, ep);
571 |   mlk_poly_add(v, epp);
572 |   mlk_poly_add(v, k);
573 | 
574 |   mlk_polyvec_reduce(b);
575 |   mlk_poly_reduce(v);
576 | 
577 |   mlk_pack_ciphertext(c, b, v);
578 | 
579 | cleanup:
580 |   /* Specification: Partially implements
581 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
582 |   MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
583 |   MLK_FREE(epp, mlk_poly, 1, context);
584 |   MLK_FREE(k, mlk_poly, 1, context);
585 |   MLK_FREE(v, mlk_poly, 1, context);
586 |   MLK_FREE(b, mlk_polyvec, 1, context);
587 |   MLK_FREE(ep, mlk_polyvec, 1, context);
588 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
589 |   MLK_FREE(sp, mlk_polyvec, 1, context);
590 |   MLK_FREE(at, mlk_polymat, 1, context);
591 |   MLK_FREE(seed, uint8_t, MLKEM_SYMBYTES, context);
592 |   return ret;
593 | }
```

### Local context window

```c
492 |   mlk_polyvec_add(pkpv, e);
493 |   mlk_polyvec_reduce(pkpv);
494 |   mlk_polyvec_reduce(skpv);
495 | 
496 |   mlk_pack_sk(sk, skpv);
497 |   mlk_pack_pk(pk, pkpv, publicseed);
498 | 
499 | cleanup:
500 |   /* Specification: Partially implements
501 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
502 |   MLK_FREE(skpv_cache, mlk_polyvec_mulcache, 1, context);
503 |   MLK_FREE(skpv, mlk_polyvec, 1, context);
504 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
505 |   MLK_FREE(e, mlk_polyvec, 1, context);
506 |   MLK_FREE(a, mlk_polymat, 1, context);
507 |   MLK_FREE(coins_with_domain_separator, uint8_t, MLKEM_SYMBYTES + 1, context);
508 |   MLK_FREE(buf, uint8_t, 2 * MLKEM_SYMBYTES, context);
509 |   return ret;
510 | }
511 | 
512 | /* Reference: `indcpa_enc()` in the reference implementation @[REF].
513 |  *            - We use x4-batched versions of `poly_getnoise` to leverage
514 |  *              batched x4-batched Keccak-f1600.
515 |  *            - We use a different implementation of `gen_matrix()` which
516 |  *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
517 |  *            - We use a mulcache to speed up matrix-vector multiplication.
518 |  *            - We include buffer zeroization.
519 |  */
520 | MLK_INTERNAL_API
521 | int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
522 |                    const uint8_t m[MLKEM_INDCPA_MSGBYTES],
523 |                    const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
524 |                    const uint8_t coins[MLKEM_SYMBYTES],
525 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
526 | {
527 |   int ret = 0;
528 |   MLK_ALLOC(seed, uint8_t, MLKEM_SYMBYTES, context);
529 |   MLK_ALLOC(at, mlk_polymat, 1, context);
530 |   MLK_ALLOC(sp, mlk_polyvec, 1, context);
531 |   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
532 |   MLK_ALLOC(ep, mlk_polyvec, 1, context);
533 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
534 |   MLK_ALLOC(v, mlk_poly, 1, context);
535 |   MLK_ALLOC(k, mlk_poly, 1, context);
536 |   MLK_ALLOC(epp, mlk_poly, 1, context);
537 |   MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);
538 | 
539 |   if (seed == NULL || at == NULL || sp == NULL || pkpv == NULL || ep == NULL ||
540 |       b == NULL || v == NULL || k == NULL || epp == NULL || sp_cache == NULL)
541 |   {
542 |     ret = MLK_ERR_OUT_OF_MEMORY;
543 |     goto cleanup;
544 |   }
545 | 
546 |   mlk_unpack_pk(pkpv, seed, pk);
547 |   mlk_poly_frommsg(k, m);
548 | 
549 |   /*
550 |    * Declassify the public seed.
551 |    * Required to use it in conditional-branches in rejection sampling.
552 |    * This is needed because in re-encryption the publicseed originated from sk
553 |    * which is marked undefined.
554 |    */
555 |   MLK_CT_TESTING_DECLASSIFY(seed, MLKEM_SYMBYTES);
556 | 
557 |   mlk_gen_matrix(at, seed, 1 /* transpose */);
558 | 
559 |   mlk_enc_getnoise_eta1_eta2(sp, ep, epp, coins);
560 | 
561 |   mlk_polyvec_ntt(sp);
562 | 
563 |   mlk_polyvec_mulcache_compute(sp_cache, sp);
564 |   mlk_matvec_mul(b, at, sp, sp_cache);
565 |   mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);
566 | 
567 |   mlk_polyvec_invntt_tomont(b);
568 |   mlk_poly_invntt_tomont(v);
569 | 
570 |   mlk_polyvec_add(b, ep);
571 |   mlk_poly_add(v, epp);
572 |   mlk_poly_add(v, k);
573 | 
574 |   mlk_polyvec_reduce(b);
575 |   mlk_poly_reduce(v);
576 | 
577 |   mlk_pack_ciphertext(c, b, v);
578 | 
579 | cleanup:
580 |   /* Specification: Partially implements
581 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
582 |   MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
583 |   MLK_FREE(epp, mlk_poly, 1, context);
584 |   MLK_FREE(k, mlk_poly, 1, context);
585 |   MLK_FREE(v, mlk_poly, 1, context);
586 |   MLK_FREE(b, mlk_polyvec, 1, context);
587 |   MLK_FREE(ep, mlk_polyvec, 1, context);
588 |   MLK_FREE(pkpv, mlk_polyvec, 1, context);
589 |   MLK_FREE(sp, mlk_polyvec, 1, context);
590 |   MLK_FREE(at, mlk_polymat, 1, context);
591 |   MLK_FREE(seed, uint8_t, MLKEM_SYMBYTES, context);
592 |   return ret;
593 | }
594 | 
595 | /* Reference: `indcpa_dec()` in the reference implementation @[REF].
596 |  *            - We use a mulcache for the scalar product.
597 |  *            - We include buffer zeroization. */
598 | MLK_INTERNAL_API
599 | int mlk_indcpa_dec(uint8_t m[MLKEM_INDCPA_MSGBYTES],
600 |                    const uint8_t c[MLKEM_INDCPA_BYTES],
601 |                    const uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
602 |                    MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
603 | {
604 |   int ret = 0;
605 |   MLK_ALLOC(b, mlk_polyvec, 1, context);
606 |   MLK_ALLOC(skpv, mlk_polyvec, 1, context);
607 |   MLK_ALLOC(v, mlk_poly, 1, context);
608 |   MLK_ALLOC(sb, mlk_poly, 1, context);
609 |   MLK_ALLOC(b_cache, mlk_polyvec_mulcache, 1, context);
610 | 
611 |   if (b == NULL || skpv == NULL || v == NULL || sb == NULL || b_cache == NULL)
612 |   {
613 |     ret = MLK_ERR_OUT_OF_MEMORY;
614 |     goto cleanup;
615 |   }
616 | 
617 |   mlk_unpack_ciphertext(b, v, c);
618 |   mlk_unpack_sk(skpv, sk);
619 | 
620 |   mlk_polyvec_ntt(b);
621 |   mlk_polyvec_mulcache_compute(b_cache, b);
622 |   mlk_polyvec_basemul_acc_montgomery_cached(sb, skpv, b, b_cache);
623 |   mlk_poly_invntt_tomont(sb);
624 | 
625 |   mlk_poly_sub(v, sb);
626 |   mlk_poly_reduce(v);
627 | 
628 |   mlk_poly_tomsg(m, v);
629 | 
630 | cleanup:
631 |   /* Specification: Partially implements
632 |    * @[FIPS203, Section 3.3, Destruction of intermediate values] */
633 |   MLK_FREE(b_cache, mlk_polyvec_mulcache, 1, context);
634 |   MLK_FREE(sb, mlk_poly, 1, context);
635 |   MLK_FREE(v, mlk_poly, 1, context);
636 |   MLK_FREE(skpv, mlk_polyvec, 1, context);
637 |   MLK_FREE(b, mlk_polyvec, 1, context);
638 |   return ret;
639 | }
640 | 
641 | /* To facilitate single-compilation-unit (SCU) builds, undefine all macros.
642 |  * Don't modify by hand -- this is auto-generated by scripts/autogen. */
643 | #undef mlk_pack_pk
644 | #undef mlk_unpack_pk
645 | #undef mlk_pack_sk
646 | #undef mlk_unpack_sk
647 | #undef mlk_pack_ciphertext
648 | #undef mlk_unpack_ciphertext
649 | #undef mlk_matvec_mul
650 | #undef mlk_polyvec_permute_bitrev_to_custom
651 | #undef mlk_polymat_permute_bitrev_to_custom
652 | #undef mlk_keypair_getnoise_eta1
```

## 4.3. Call Site 3: `mlkem/src/poly_k.c:278`

### Exact call

```c
mlk_poly_add(&r->vec[i], &b->vec[i]);
```

### Enclosing production function

```c
255 | 
256 | /* Reference: `polyvec_add()` in the reference implementation @[REF].
257 |  *            - We use destructive version (output=first input) to avoid
258 |  *              reasoning about aliasing in the CBMC specification */
259 | MLK_INTERNAL_API
260 | void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
261 | {
262 |   unsigned i;
263 |   for (i = 0; i < MLKEM_K; i++)
264 |   __loop__(
265 |     assigns(i, memory_slice(r, sizeof(mlk_polyvec)))
266 |     invariant(i <= MLKEM_K)
267 |     invariant(forall(j0, i, MLKEM_K,
268 |                 forall(k0, 0, MLKEM_N,
269 |                        ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] <= INT16_MAX) &&
270 |                        ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] >= INT16_MIN))))
271 |     invariant(forall(j2, 0, i,
272 |                 forall(k2, 0, MLKEM_N,
273 |                        (r->vec[j2].coeffs[k2] <= INT16_MAX) &&
274 |                        (r->vec[j2].coeffs[k2] >= INT16_MIN))))
275 |     decreases(MLKEM_K - i)
276 |   )
277 |   {
278 |     mlk_poly_add(&r->vec[i], &b->vec[i]);
279 |   }
280 | }
```

### Local context window

```c
198 |     int ret;
199 |     mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
200 | #if MLKEM_K == 2
201 |     ret = mlk_polyvec_basemul_acc_montgomery_cached_k2_native(
202 |         r->coeffs, (const int16_t *)a, (const int16_t *)b,
203 |         (const int16_t *)b_cache);
204 | #elif MLKEM_K == 3
205 |     ret = mlk_polyvec_basemul_acc_montgomery_cached_k3_native(
206 |         r->coeffs, (const int16_t *)a, (const int16_t *)b,
207 |         (const int16_t *)b_cache);
208 | #elif MLKEM_K == 4
209 |     ret = mlk_polyvec_basemul_acc_montgomery_cached_k4_native(
210 |         r->coeffs, (const int16_t *)a, (const int16_t *)b,
211 |         (const int16_t *)b_cache);
212 | #endif
213 |     if (ret == MLK_NATIVE_FUNC_SUCCESS)
214 |     {
215 |       return;
216 |     }
217 |   }
218 | #endif /* MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED */
219 | 
220 |   mlk_polyvec_basemul_acc_montgomery_cached_c(r, a, b, b_cache);
221 | }
222 | 
223 | /* Reference: Does not exist in the reference implementation @[REF].
224 |  *            - The reference implementation does not use a
225 |  *              multiplication cache ('mulcache'). This idea originates
226 |  *              from @[NeonNTT] and is used at the C level here. */
227 | MLK_INTERNAL_API
228 | void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
229 | {
230 |   unsigned i;
231 |   for (i = 0; i < MLKEM_K; i++)
232 |   {
233 |     mlk_poly_mulcache_compute(&x->vec[i], &a->vec[i]);
234 |   }
235 | }
236 | 
237 | /* Reference: `polyvec_reduce()` in the reference implementation @[REF].
238 |  *            - We use _unsigned_ canonical outputs, while the reference
239 |  *              implementation uses _signed_ canonical outputs.
240 |  *              Accordingly, we need a conditional addition of MLKEM_Q
241 |  *              here to go from signed to unsigned representatives.
242 |  *              This conditional addition is then dropped from all
243 |  *              polynomial compression functions instead (see `compress.c`). */
244 | MLK_INTERNAL_API
245 | void mlk_polyvec_reduce(mlk_polyvec *r)
246 | {
247 |   unsigned i;
248 |   for (i = 0; i < MLKEM_K; i++)
249 |   {
250 |     mlk_poly_reduce(&r->vec[i]);
251 |   }
252 | 
253 |   mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
254 | }
255 | 
256 | /* Reference: `polyvec_add()` in the reference implementation @[REF].
257 |  *            - We use destructive version (output=first input) to avoid
258 |  *              reasoning about aliasing in the CBMC specification */
259 | MLK_INTERNAL_API
260 | void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
261 | {
262 |   unsigned i;
263 |   for (i = 0; i < MLKEM_K; i++)
264 |   __loop__(
265 |     assigns(i, memory_slice(r, sizeof(mlk_polyvec)))
266 |     invariant(i <= MLKEM_K)
267 |     invariant(forall(j0, i, MLKEM_K,
268 |                 forall(k0, 0, MLKEM_N,
269 |                        ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] <= INT16_MAX) &&
270 |                        ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] >= INT16_MIN))))
271 |     invariant(forall(j2, 0, i,
272 |                 forall(k2, 0, MLKEM_N,
273 |                        (r->vec[j2].coeffs[k2] <= INT16_MAX) &&
274 |                        (r->vec[j2].coeffs[k2] >= INT16_MIN))))
275 |     decreases(MLKEM_K - i)
276 |   )
277 |   {
278 |     mlk_poly_add(&r->vec[i], &b->vec[i]);
279 |   }
280 | }
281 | 
282 | /* Reference: `polyvec_tomont()` in the reference implementation @[REF]. */
283 | MLK_INTERNAL_API
284 | void mlk_polyvec_tomont(mlk_polyvec *r)
285 | {
286 |   unsigned i;
287 |   for (i = 0; i < MLKEM_K; i++)
288 |   {
289 |     mlk_poly_tomont(&r->vec[i]);
290 |   }
291 | 
292 |   mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLKEM_Q);
293 | }
294 | 
295 | 
296 | /**
297 |  * Given an array of uniformly random bytes, compute a polynomial with
298 |  * coefficients distributed according to a centered binomial distribution
299 |  * with parameter MLKEM_ETA1.
300 |  *
301 |  * @spec{Implements @[FIPS203, Algorithm 8, SamplePolyCBD_eta1], where eta1
302 |  * is specified per parameter set in @[FIPS203, Table 2] and represented as
303 |  * MLKEM_ETA1 here.}
304 |  *
305 |  * @reference{`poly_cbd_eta1` in the reference implementation @[REF].}
306 |  *
307 |  * @param[out] r   Output polynomial.
308 |  * @param[in]  buf Input byte array.
309 |  */
310 | static MLK_INLINE void mlk_poly_cbd_eta1(
311 |     mlk_poly *r, const uint8_t buf[MLKEM_ETA1 * MLKEM_N / 4])
312 | __contract__(
313 |   requires(memory_no_alias(r, sizeof(mlk_poly)))
314 |   requires(memory_no_alias(buf, MLKEM_ETA1 * MLKEM_N / 4))
315 |   assigns(memory_slice(r, sizeof(mlk_poly)))
316 |   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1))
317 | )
318 | {
319 | #if MLKEM_ETA1 == 2
320 |   mlk_poly_cbd2(r, buf);
321 | #elif MLKEM_ETA1 == 3
322 |   mlk_poly_cbd3(r, buf);
323 | #else
324 | #error "Invalid value of MLKEM_ETA1"
325 | #endif
326 | }
327 | 
328 | /* Reference: Does not exist in the reference implementation @[REF].
329 |  *            - This implements a x4-batched version of `poly_getnoise_eta1()`
330 |  *              from the reference implementation, to leverage
331 |  *              batched Keccak-f1600.*/
332 | MLK_INTERNAL_API
333 | void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
334 |                                mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
335 |                                uint8_t nonce0, uint8_t nonce1, uint8_t nonce2,
336 |                                uint8_t nonce3)
337 | {
338 |   MLK_ALIGN uint8_t buf[4][MLK_ALIGN_UP(MLKEM_ETA1 * MLKEM_N / 4)];
339 |   MLK_ALIGN uint8_t extkey[4][MLK_ALIGN_UP(MLKEM_SYMBYTES + 1)];
340 |   mlk_memcpy(extkey[0], seed, MLKEM_SYMBYTES);
341 |   mlk_memcpy(extkey[1], seed, MLKEM_SYMBYTES);
342 |   mlk_memcpy(extkey[2], seed, MLKEM_SYMBYTES);
343 |   mlk_memcpy(extkey[3], seed, MLKEM_SYMBYTES);
344 |   extkey[0][MLKEM_SYMBYTES] = nonce0;
345 |   extkey[1][MLKEM_SYMBYTES] = nonce1;
346 |   extkey[2][MLKEM_SYMBYTES] = nonce2;
347 |   extkey[3][MLKEM_SYMBYTES] = nonce3;
348 | 
349 | #if !defined(FIPS202_X4_DEFAULT_IMPLEMENTATION) && \
350 |     !defined(MLK_CONFIG_SERIAL_FIPS202_ONLY)
351 |   mlk_prf_eta1_x4(buf, extkey);
352 | #else
353 |   mlk_prf_eta1(buf[0], extkey[0]);
354 |   mlk_prf_eta1(buf[1], extkey[1]);
355 |   mlk_prf_eta1(buf[2], extkey[2]);
356 |   if (r3 != NULL)
357 |   {
358 |     mlk_prf_eta1(buf[3], extkey[3]);
```

## 5. Relevant Type, Parameter, and Contract Lines

```text
mlkem/src/poly.h:25: #define MLK_INVNTT_BOUND (8 * MLKEM_Q)
mlkem/src/poly.h:28: #define MLK_NTT_BOUND (8 * MLKEM_Q)
mlkem/src/poly.h:34: typedef struct
mlkem/src/poly.h:36:   int16_t coeffs[MLKEM_N]; /**< Polynomial coefficients. */
mlkem/src/poly.h:37: } MLK_ALIGN mlk_poly;
mlkem/src/poly.h:43: typedef struct
mlkem/src/poly.h:45:   int16_t coeffs[MLKEM_N >> 1]; /**< Cached coefficients. */
mlkem/src/poly.h:46: } MLK_ALIGN mlk_poly_mulcache;
mlkem/src/poly.h:50:  * integer congruent to a * R^-1 mod MLKEM_Q, where R=2^16.
mlkem/src/poly.h:53:  *          to INT32_MAX - 2^15 * MLKEM_Q.
mlkem/src/poly.h:55:  * @return Integer congruent to a * R^-1 modulo MLKEM_Q, with absolute value
mlkem/src/poly.h:56:  *         <= ceil(|a| / 2^16) + (MLKEM_Q + 1)/2.
mlkem/src/poly.h:59: __contract__(
mlkem/src/poly.h:60:     requires(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
mlkem/src/poly.h:61:              a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)))
mlkem/src/poly.h:70:   /* check-magic: 62209 == unsigned_mod(pow(MLKEM_Q, -1, 2^16), 2^16) */
mlkem/src/poly.h:82:   mlk_assert(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
mlkem/src/poly.h:83:              a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)));
mlkem/src/poly.h:85:   r = a - ((int32_t)t * MLKEM_Q);
mlkem/src/poly.h:94:    *                   <= ceil(|a| / 2^16 + MLKEM_Q / 2)
mlkem/src/poly.h:95:    *                   <= ceil(|a| / 2^16) + (MLKEM_Q + 1) / 2
mlkem/src/poly.h:102: #define mlk_poly_tomont MLK_NAMESPACE(poly_tomont)
mlkem/src/poly.h:107:  * Bounds: output < MLKEM_Q in absolute value.
mlkem/src/poly.h:116: void mlk_poly_tomont(mlk_poly *r)
mlkem/src/poly.h:117: __contract__(
mlkem/src/poly.h:118:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:119:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:120:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.h:123: #define mlk_poly_mulcache_compute MLK_NAMESPACE(poly_mulcache_compute)
mlkem/src/poly.h:147: void mlk_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
mlkem/src/poly.h:148: __contract__(
mlkem/src/poly.h:149:   requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
mlkem/src/poly.h:150:   requires(memory_no_alias(a, sizeof(mlk_poly)))
mlkem/src/poly.h:151:   assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
mlkem/src/poly.h:154: #define mlk_poly_reduce MLK_NAMESPACE(poly_reduce)
mlkem/src/poly.h:159:  * coefficients are in [0,1,..,MLKEM_Q-1].
mlkem/src/poly.h:167:  * NOTE: The semantics of mlk_poly_reduce() is different in
mlkem/src/poly.h:171:  * use of mlk_poly_reduce() in the context of (de)serialization.
mlkem/src/poly.h:174: void mlk_poly_reduce(mlk_poly *r)
mlkem/src/poly.h:175: __contract__(
mlkem/src/poly.h:176:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:177:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:178:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
mlkem/src/poly.h:181: #define mlk_poly_add MLK_NAMESPACE(poly_add)
mlkem/src/poly.h:196:  * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
mlkem/src/poly.h:200: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.h:201: __contract__(
mlkem/src/poly.h:202:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:203:   requires(memory_no_alias(b, sizeof(mlk_poly)))
mlkem/src/poly.h:204:   requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
mlkem/src/poly.h:205:   requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
mlkem/src/poly.h:206:   ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
mlkem/src/poly.h:207:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:210: #define mlk_poly_sub MLK_NAMESPACE(poly_sub)
mlkem/src/poly.h:221:  * NOTE: The reference implementation uses a 3-argument mlk_poly_sub.
mlkem/src/poly.h:225: void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.h:226: __contract__(
mlkem/src/poly.h:227:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:228:   requires(memory_no_alias(b, sizeof(mlk_poly)))
mlkem/src/poly.h:229:   requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] - b->coeffs[k0] <= INT16_MAX))
mlkem/src/poly.h:230:   requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] - b->coeffs[k1] >= INT16_MIN))
mlkem/src/poly.h:231:   ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] - b->coeffs[k]))
mlkem/src/poly.h:232:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:235: #define mlk_poly_ntt MLK_NAMESPACE(poly_ntt)
mlkem/src/poly.h:241:  * MLKEM_Q in absolute value.
mlkem/src/poly.h:255: void mlk_poly_ntt(mlk_poly *r)
mlkem/src/poly.h:256: __contract__(
mlkem/src/poly.h:257:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:258:   requires(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.h:259:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:260:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
mlkem/src/poly.h:263: #define mlk_poly_invntt_tomont MLK_NAMESPACE(poly_invntt_tomont)
mlkem/src/poly.h:283: void mlk_poly_invntt_tomont(mlk_poly *r)
mlkem/src/poly.h:284: __contract__(
mlkem/src/poly.h:285:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.h:286:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.h:287:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
mlkem/src/poly_k.h:26: #define mlk_polyvec MLK_ADD_PARAM_SET(mlk_polyvec)
mlkem/src/poly_k.h:27: #define mlk_polymat MLK_ADD_PARAM_SET(mlk_polymat)
mlkem/src/poly_k.h:28: #define mlk_polyvec_mulcache MLK_ADD_PARAM_SET(mlk_polyvec_mulcache)
mlkem/src/poly_k.h:31: /** Vector of MLKEM_K polynomials. */
mlkem/src/poly_k.h:32: typedef struct
mlkem/src/poly_k.h:34:   mlk_poly vec[MLKEM_K]; /**< Component polynomials. */
mlkem/src/poly_k.h:35: } MLK_ALIGN mlk_polyvec;
mlkem/src/poly_k.h:37: /** MLKEM_K x MLKEM_K matrix of polynomials. */
mlkem/src/poly_k.h:38: typedef struct
mlkem/src/poly_k.h:40:   mlk_polyvec vec[MLKEM_K]; /**< Rows of the matrix. */
mlkem/src/poly_k.h:41: } MLK_ALIGN mlk_polymat;
mlkem/src/poly_k.h:43: /** Vector of MLKEM_K mlk_poly_mulcache entries. */
mlkem/src/poly_k.h:44: typedef struct
mlkem/src/poly_k.h:46:   mlk_poly_mulcache vec[MLKEM_K]; /**< Per-component caches. */
mlkem/src/poly_k.h:47: } MLK_ALIGN mlk_polyvec_mulcache;
mlkem/src/poly_k.h:49: #define mlk_poly_compress_du MLK_NAMESPACE_K(poly_compress_du)
mlkem/src/poly_k.h:60:  *               i.e. in [0,1,..,MLKEM_Q-1].
mlkem/src/poly_k.h:62: static MLK_INLINE void mlk_poly_compress_du(
mlkem/src/poly_k.h:63:     uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DU], const mlk_poly *a)
mlkem/src/poly_k.h:64: __contract__(
mlkem/src/poly_k.h:65:   requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DU))
mlkem/src/poly_k.h:66:   requires(memory_no_alias(a, sizeof(mlk_poly)))
mlkem/src/poly_k.h:67:   requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
mlkem/src/poly_k.h:68:   assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DU)))
mlkem/src/poly_k.h:71:   mlk_poly_compress_d10(r, a);
mlkem/src/poly_k.h:73:   mlk_poly_compress_d11(r, a);
mlkem/src/poly_k.h:79: #define mlk_poly_decompress_du MLK_NAMESPACE_K(poly_decompress_du)
mlkem/src/poly_k.h:82:  * approximate inverse of mlk_poly_compress_du.
mlkem/src/poly_k.h:85:  * unsigned-canonical (non-negative and smaller than MLKEM_Q).
mlkem/src/poly_k.h:95: static MLK_INLINE void mlk_poly_decompress_du(
mlkem/src/poly_k.h:96:     mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DU])
mlkem/src/poly_k.h:97: __contract__(
mlkem/src/poly_k.h:98:   requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DU))
mlkem/src/poly_k.h:99:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:100:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:101:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:104:   mlk_poly_decompress_d10(r, a);
mlkem/src/poly_k.h:106:   mlk_poly_decompress_d11(r, a);
mlkem/src/poly_k.h:112: #define mlk_poly_compress_dv MLK_NAMESPACE_K(poly_compress_dv)
mlkem/src/poly_k.h:123:  *               i.e. in [0,1,..,MLKEM_Q-1].
mlkem/src/poly_k.h:125: static MLK_INLINE void mlk_poly_compress_dv(
mlkem/src/poly_k.h:126:     uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DV], const mlk_poly *a)
mlkem/src/poly_k.h:127: __contract__(
mlkem/src/poly_k.h:128:   requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DV))
mlkem/src/poly_k.h:129:   requires(memory_no_alias(a, sizeof(mlk_poly)))
mlkem/src/poly_k.h:130:   requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
mlkem/src/poly_k.h:131:   assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DV)))
mlkem/src/poly_k.h:134:   mlk_poly_compress_d4(r, a);
mlkem/src/poly_k.h:136:   mlk_poly_compress_d5(r, a);
mlkem/src/poly_k.h:143: #define mlk_poly_decompress_dv MLK_NAMESPACE_K(poly_decompress_dv)
mlkem/src/poly_k.h:146:  * approximate inverse of mlk_poly_compress_dv.
mlkem/src/poly_k.h:149:  * unsigned-canonical (non-negative and smaller than MLKEM_Q).
mlkem/src/poly_k.h:159: static MLK_INLINE void mlk_poly_decompress_dv(
mlkem/src/poly_k.h:160:     mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DV])
mlkem/src/poly_k.h:161: __contract__(
mlkem/src/poly_k.h:162:   requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DV))
mlkem/src/poly_k.h:163:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:164:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:165:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:168:   mlk_poly_decompress_d4(r, a);
mlkem/src/poly_k.h:170:   mlk_poly_decompress_d5(r, a);
mlkem/src/poly_k.h:176: #define mlk_polyvec_compress_du MLK_NAMESPACE_K(polyvec_compress_du)
mlkem/src/poly_k.h:187:  *               canonical, i.e. in [0,1,..,MLKEM_Q-1].
mlkem/src/poly_k.h:190: void mlk_polyvec_compress_du(uint8_t r[MLKEM_POLYVECCOMPRESSEDBYTES_DU],
mlkem/src/poly_k.h:191:                              const mlk_polyvec *a)
mlkem/src/poly_k.h:192: __contract__(
mlkem/src/poly_k.h:193:   requires(memory_no_alias(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
mlkem/src/poly_k.h:194:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:195:   requires(forall(k0, 0, MLKEM_K,
mlkem/src/poly_k.h:196:          array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:197:   assigns(memory_slice(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
mlkem/src/poly_k.h:200: #define mlk_polyvec_decompress_du MLK_NAMESPACE_K(polyvec_decompress_du)
mlkem/src/poly_k.h:203:  * of mlk_polyvec_compress_du.
mlkem/src/poly_k.h:210:  *               to [0,1,..,MLKEM_Q-1].
mlkem/src/poly_k.h:215: void mlk_polyvec_decompress_du(mlk_polyvec *r,
mlkem/src/poly_k.h:217: __contract__(
mlkem/src/poly_k.h:218:   requires(memory_no_alias(a, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
mlkem/src/poly_k.h:219:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:220:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:221:   ensures(forall(k0, 0, MLKEM_K,
mlkem/src/poly_k.h:222:          array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:225: #define mlk_polyvec_tobytes MLK_NAMESPACE_K(polyvec_tobytes)
mlkem/src/poly_k.h:235:  *               coefficients in [0,1,..,MLKEM_Q-1].
mlkem/src/poly_k.h:238: void mlk_polyvec_tobytes(uint8_t r[MLKEM_POLYVECBYTES], const mlk_polyvec *a)
mlkem/src/poly_k.h:239: __contract__(
mlkem/src/poly_k.h:240:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:241:   requires(memory_no_alias(r, MLKEM_POLYVECBYTES))
mlkem/src/poly_k.h:242:   requires(forall(k0, 0, MLKEM_K,
mlkem/src/poly_k.h:243:          array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:244:   assigns(memory_slice(r, MLKEM_POLYVECBYTES))
mlkem/src/poly_k.h:247: #define mlk_polyvec_frombytes MLK_NAMESPACE_K(polyvec_frombytes)
mlkem/src/poly_k.h:249:  * De-serialize a vector of polynomials; inverse of mlk_polyvec_tobytes.
mlkem/src/poly_k.h:260: void mlk_polyvec_frombytes(mlk_polyvec *r, const uint8_t a[MLKEM_POLYVECBYTES])
mlkem/src/poly_k.h:261: __contract__(
mlkem/src/poly_k.h:262:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:263:   requires(memory_no_alias(a, MLKEM_POLYVECBYTES))
mlkem/src/poly_k.h:264:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:265:   ensures(forall(k0, 0, MLKEM_K,
mlkem/src/poly_k.h:266:         array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
mlkem/src/poly_k.h:269: #define mlk_polyvec_ntt MLK_NAMESPACE_K(polyvec_ntt)
mlkem/src/poly_k.h:274:  * MLKEM_Q in absolute value.
mlkem/src/poly_k.h:285: void mlk_polyvec_ntt(mlk_polyvec *r)
mlkem/src/poly_k.h:286: __contract__(
mlkem/src/poly_k.h:287:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:288:   requires(forall(j, 0, MLKEM_K,
mlkem/src/poly_k.h:289:   array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
mlkem/src/poly_k.h:290:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:291:   ensures(forall(j, 0, MLKEM_K,
mlkem/src/poly_k.h:292:   array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_NTT_BOUND)))
mlkem/src/poly_k.h:295: #define mlk_polyvec_invntt_tomont MLK_NAMESPACE_K(polyvec_invntt_tomont)
mlkem/src/poly_k.h:312: void mlk_polyvec_invntt_tomont(mlk_polyvec *r)
mlkem/src/poly_k.h:313: __contract__(
mlkem/src/poly_k.h:314:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:315:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:316:   ensures(forall(j, 0, MLKEM_K,
mlkem/src/poly_k.h:317:   array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND)))
mlkem/src/poly_k.h:320: #define mlk_polyvec_basemul_acc_montgomery_cached \
mlkem/src/poly_k.h:337:  *                     be computed via mlk_polyvec_mulcache_compute().
mlkem/src/poly_k.h:340: void mlk_polyvec_basemul_acc_montgomery_cached(
mlkem/src/poly_k.h:341:     mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
mlkem/src/poly_k.h:342:     const mlk_polyvec_mulcache *b_cache)
mlkem/src/poly_k.h:343: __contract__(
mlkem/src/poly_k.h:344:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:345:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:346:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:347:   requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
mlkem/src/poly_k.h:348:   requires(forall(k1, 0, MLKEM_K,
mlkem/src/poly_k.h:349:      array_bound(a->vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
mlkem/src/poly_k.h:350:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:353: #define mlk_polyvec_mulcache_compute MLK_NAMESPACE_K(polyvec_mulcache_compute)
mlkem/src/poly_k.h:380: void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
mlkem/src/poly_k.h:381: __contract__(
mlkem/src/poly_k.h:382:   requires(memory_no_alias(x, sizeof(mlk_polyvec_mulcache)))
mlkem/src/poly_k.h:383:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:384:   assigns(memory_slice(x, sizeof(mlk_polyvec_mulcache)))
mlkem/src/poly_k.h:387: #define mlk_polyvec_reduce MLK_NAMESPACE_K(polyvec_reduce)
mlkem/src/poly_k.h:399:  * NOTE: The semantics of mlk_polyvec_reduce() is different in
mlkem/src/poly_k.h:403:  *       use of mlk_poly_reduce() in the context of (de)serialization.
mlkem/src/poly_k.h:406: void mlk_polyvec_reduce(mlk_polyvec *r)
mlkem/src/poly_k.h:407: __contract__(
mlkem/src/poly_k.h:408:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:409:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:410:   ensures(forall(k0, 0, MLKEM_K,
mlkem/src/poly_k.h:411:     array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/poly_k.h:414: #define mlk_polyvec_add MLK_NAMESPACE_K(polyvec_add)
mlkem/src/poly_k.h:432: void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
mlkem/src/poly_k.h:433: __contract__(
mlkem/src/poly_k.h:434:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:435:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:436:   requires(forall(j0, 0, MLKEM_K,
mlkem/src/poly_k.h:437:           forall(k0, 0, MLKEM_N,
mlkem/src/poly_k.h:439:   requires(forall(j1, 0, MLKEM_K,
mlkem/src/poly_k.h:440:           forall(k1, 0, MLKEM_N,
mlkem/src/poly_k.h:442:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:445: #define mlk_polyvec_tomont MLK_NAMESPACE_K(polyvec_tomont)
mlkem/src/poly_k.h:450:  * Bounds: output < MLKEM_Q in absolute value.
mlkem/src/poly_k.h:459: void mlk_polyvec_tomont(mlk_polyvec *r)
mlkem/src/poly_k.h:460: __contract__(
mlkem/src/poly_k.h:461:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:462:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.h:463:   ensures(forall(j, 0, MLKEM_K,
mlkem/src/poly_k.h:464:     array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
mlkem/src/poly_k.h:467: #define mlk_poly_getnoise_eta1_4x MLK_NAMESPACE_K(poly_getnoise_eta1_4x)
mlkem/src/poly_k.h:490: void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
mlkem/src/poly_k.h:491:                                mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/poly_k.h:494: __contract__(
mlkem/src/poly_k.h:495:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
mlkem/src/poly_k.h:496:   requires(memory_no_alias(r0, sizeof(mlk_poly)))
mlkem/src/poly_k.h:497:   requires(memory_no_alias(r1, sizeof(mlk_poly)))
mlkem/src/poly_k.h:498:   requires(memory_no_alias(r2, sizeof(mlk_poly)))
mlkem/src/poly_k.h:499:   requires(r3 == NULL || memory_no_alias(r3, sizeof(mlk_poly)))
mlkem/src/poly_k.h:500:   assigns(memory_slice(r0, sizeof(mlk_poly)))
mlkem/src/poly_k.h:501:   assigns(memory_slice(r1, sizeof(mlk_poly)))
mlkem/src/poly_k.h:502:   assigns(memory_slice(r2, sizeof(mlk_poly)))
mlkem/src/poly_k.h:503:   assigns(r3 != NULL: memory_slice(r3, sizeof(mlk_poly)))
mlkem/src/poly_k.h:504:   ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
mlkem/src/poly_k.h:505:   ensures(array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
mlkem/src/poly_k.h:506:   ensures(array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
mlkem/src/poly_k.h:507:   ensures(r3 != NULL ==> array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
mlkem/src/poly_k.h:512:  * We only require mlk_poly_getnoise_eta2_4x for ml-kem-768 and ml-kem-1024
mlkem/src/poly_k.h:514:  * For ml-kem-512, mlk_poly_getnoise_eta1122_4x is used instead.
mlkem/src/poly_k.h:516: #define mlk_poly_getnoise_eta2_4x mlk_poly_getnoise_eta1_4x
mlkem/src/poly_k.h:519: #if MLKEM_K == 2 || MLKEM_K == 4
mlkem/src/poly_k.h:520: #define mlk_poly_getnoise_eta2 MLK_NAMESPACE_K(poly_getnoise_eta2)
mlkem/src/poly_k.h:536: void mlk_poly_getnoise_eta2(mlk_poly *r, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/poly_k.h:538: __contract__(
mlkem/src/poly_k.h:539:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:540:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
mlkem/src/poly_k.h:541:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.h:542:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
mlkem/src/poly_k.h:544: #endif /* MLKEM_K == 2 || MLKEM_K == 4 */
mlkem/src/poly_k.h:546: #if MLKEM_K == 2
mlkem/src/poly_k.h:547: #define mlk_poly_getnoise_eta1122_4x MLK_NAMESPACE_K(poly_getnoise_eta1122_4x)
mlkem/src/poly_k.h:571: void mlk_poly_getnoise_eta1122_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
mlkem/src/poly_k.h:572:                                   mlk_poly *r3,
mlkem/src/poly_k.h:576: __contract__(
mlkem/src/poly_k.h:577:   requires(memory_no_alias(r0, sizeof(mlk_poly)))
mlkem/src/poly_k.h:578:   requires(memory_no_alias(r1, sizeof(mlk_poly)))
mlkem/src/poly_k.h:579:   requires(memory_no_alias(r2, sizeof(mlk_poly)))
mlkem/src/poly_k.h:580:   requires(memory_no_alias(r3, sizeof(mlk_poly)))
mlkem/src/poly_k.h:581:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
mlkem/src/poly_k.h:582:   assigns(memory_slice(r0, sizeof(mlk_poly)))
mlkem/src/poly_k.h:583:   assigns(memory_slice(r1, sizeof(mlk_poly)))
mlkem/src/poly_k.h:584:   assigns(memory_slice(r2, sizeof(mlk_poly)))
mlkem/src/poly_k.h:585:   assigns(memory_slice(r3, sizeof(mlk_poly)))
mlkem/src/poly_k.h:586:   ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
mlkem/src/poly_k.h:587:        && array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
mlkem/src/poly_k.h:588:        && array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1)
mlkem/src/poly_k.h:589:        && array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1))
mlkem/src/poly_k.h:591: #endif /* MLKEM_K == 2 */
mlkem/src/params.h:13: #define MLKEM_K 2
mlkem/src/params.h:15: #define MLKEM_K 3
mlkem/src/params.h:17: #define MLKEM_K 4
mlkem/src/params.h:22: #define MLKEM_N 256
mlkem/src/params.h:23: #define MLKEM_Q 3329
mlkem/src/params.h:24: #define MLKEM_Q_HALF ((MLKEM_Q + 1) / 2) /* 1665 */
mlkem/src/params.h:31: #define MLKEM_POLYVECBYTES (MLKEM_K * MLKEM_POLYBYTES)
mlkem/src/params.h:38: #if MLKEM_K == 2
mlkem/src/params.h:44: #define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
mlkem/src/params.h:45: #elif MLKEM_K == 3
mlkem/src/params.h:51: #define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
mlkem/src/params.h:52: #elif MLKEM_K == 4
mlkem/src/params.h:58: #define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
mlkem/src/params.h:59: #endif /* MLKEM_K == 4 */
mlkem/src/indcpa.h:37: void mlk_gen_matrix(mlk_polymat *a, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/indcpa.h:39: __contract__(
mlkem/src/indcpa.h:40:   requires(memory_no_alias(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.h:41:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
mlkem/src/indcpa.h:42:   requires(transposed == 0 || transposed == 1)
mlkem/src/indcpa.h:43:   assigns(memory_slice(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.h:44:   ensures(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
mlkem/src/indcpa.h:45:   array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
mlkem/src/indcpa.h:77: __contract__(
mlkem/src/indcpa.h:78:   requires(memory_no_alias(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
mlkem/src/indcpa.h:79:   requires(memory_no_alias(sk, MLKEM_INDCPA_SECRETKEYBYTES))
mlkem/src/indcpa.h:80:   requires(memory_no_alias(coins, MLKEM_SYMBYTES))
mlkem/src/indcpa.h:81:   assigns(memory_slice(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
mlkem/src/indcpa.h:82:   assigns(memory_slice(sk, MLKEM_INDCPA_SECRETKEYBYTES))
mlkem/src/indcpa.h:83:   ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
mlkem/src/indcpa.h:117: __contract__(
mlkem/src/indcpa.h:118:   requires(memory_no_alias(c, MLKEM_INDCPA_BYTES))
mlkem/src/indcpa.h:119:   requires(memory_no_alias(m, MLKEM_INDCPA_MSGBYTES))
mlkem/src/indcpa.h:120:   requires(memory_no_alias(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
mlkem/src/indcpa.h:121:   requires(memory_no_alias(coins, MLKEM_SYMBYTES))
mlkem/src/indcpa.h:122:   assigns(memory_slice(c, MLKEM_INDCPA_BYTES))
mlkem/src/indcpa.h:123:   ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
mlkem/src/indcpa.h:154: __contract__(
mlkem/src/indcpa.h:155:   requires(memory_no_alias(c, MLKEM_INDCPA_BYTES))
mlkem/src/indcpa.h:156:   requires(memory_no_alias(m, MLKEM_INDCPA_MSGBYTES))
mlkem/src/indcpa.h:157:   requires(memory_no_alias(sk, MLKEM_INDCPA_SECRETKEYBYTES))
mlkem/src/indcpa.h:158:   assigns(memory_slice(m, MLKEM_INDCPA_MSGBYTES))
mlkem/src/indcpa.h:159:   ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
mlkem/src/poly.c:32:  * Montgomery multiplication modulo MLKEM_Q.
mlkem/src/poly.c:38:  *          (abs value < (MLKEM_Q+1)/2).
mlkem/src/poly.c:40:  * @return 16-bit integer congruent to a*b*R^{-1} mod MLKEM_Q, and
mlkem/src/poly.c:41:  *         smaller than MLKEM_Q in absolute value.
mlkem/src/poly.c:44: __contract__(
mlkem/src/poly.c:45:   requires(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF)
mlkem/src/poly.c:46:   ensures(return_value > -MLKEM_Q && return_value < MLKEM_Q)
mlkem/src/poly.c:50:   mlk_assert_abs_bound(&b, 1, MLKEM_Q_HALF);
mlkem/src/poly.c:54:    * |res| <= ceil(|a| * |b| / 2^16) + (MLKEM_Q + 1) / 2
mlkem/src/poly.c:55:    *       <= ceil(2^15 * ((MLKEM_Q - 1)/2) / 2^16) + (MLKEM_Q + 1) / 2
mlkem/src/poly.c:56:    *       <= ceil((MLKEM_Q - 1) / 4) + (MLKEM_Q + 1) / 2
mlkem/src/poly.c:57:    *        < MLKEM_Q
mlkem/src/poly.c:60:   mlk_assert_abs_bound(&res, 1, MLKEM_Q);
mlkem/src/poly.c:66:  * representative congruent to a mod MLKEM_Q in [-(MLKEM_Q-1)/2, (MLKEM_Q-1)/2].
mlkem/src/poly.c:72:  * @return Integer in [-(MLKEM_Q-1)/2, (MLKEM_Q-1)/2] congruent to @p a modulo
mlkem/src/poly.c:73:  *         MLKEM_Q.
mlkem/src/poly.c:76: __contract__(
mlkem/src/poly.c:77:   ensures(return_value > -MLKEM_Q_HALF && return_value < MLKEM_Q_HALF)
mlkem/src/poly.c:82:    *     round(a/MLKEM_Q)
mlkem/src/poly.c:83:    *   = round(a*(2^N/MLKEM_Q))/2^N)
mlkem/src/poly.c:84:    *  ~= round(a*round(2^N/MLKEM_Q)/2^N)
mlkem/src/poly.c:88:   const int32_t magic = 20159; /* check-magic: 20159 == round(2^26 / MLKEM_Q) */
mlkem/src/poly.c:100:    * evaluate t * MLKEM_Q and the subsequent subtraction
mlkem/src/poly.c:102:   int16_t res = (int16_t)(a - t * MLKEM_Q);
mlkem/src/poly.c:104:   mlk_assert_abs_bound(&res, 1, MLKEM_Q_HALF);
mlkem/src/poly.c:109: MLK_STATIC_TESTABLE void mlk_poly_tomont_c(mlk_poly *r)
mlkem/src/poly.c:110: __contract__(
mlkem/src/poly.c:111:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.c:112:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.c:113:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:117:   const int16_t f = 1353; /* check-magic: 1353 == signed_mod(2^32, MLKEM_Q) */
mlkem/src/poly.c:118:   for (i = 0; i < MLKEM_N; i++)
mlkem/src/poly.c:119:   __loop__(
mlkem/src/poly.c:120:     invariant(i <= MLKEM_N)
mlkem/src/poly.c:121:     invariant(array_abs_bound(r->coeffs, 0, i, MLKEM_Q))
mlkem/src/poly.c:122:     decreases(MLKEM_N - i))
mlkem/src/poly.c:127:   mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
mlkem/src/poly.c:131: void mlk_poly_tomont(mlk_poly *r)
mlkem/src/poly.c:135:   ret = mlk_poly_tomont_native(r->coeffs);
mlkem/src/poly.c:138:     mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
mlkem/src/poly.c:143:   mlk_poly_tomont_c(r);
mlkem/src/poly.c:147:  * Constant-time conversion of signed representatives modulo MLKEM_Q within
mlkem/src/poly.c:148:  * range [-(MLKEM_Q-1), MLKEM_Q-1] into unsigned representatives within
mlkem/src/poly.c:149:  * range [0, MLKEM_Q-1].
mlkem/src/poly.c:158:  * @return Unsigned representative in [0, MLKEM_Q).
mlkem/src/poly.c:161: __contract__(
mlkem/src/poly.c:162:   requires(c > -MLKEM_Q && c < MLKEM_Q)
mlkem/src/poly.c:163:   ensures(return_value >= 0 && return_value < MLKEM_Q)
mlkem/src/poly.c:164:   ensures(return_value == (int32_t)c + (((int32_t)c < 0) * MLKEM_Q)))
mlkem/src/poly.c:166:   mlk_assert_abs_bound(&c, 1, MLKEM_Q);
mlkem/src/poly.c:168:   /* Add MLKEM_Q if c is negative, but in constant time.
mlkem/src/poly.c:170:    * Note that c + MLKEM_Q does not overflow in int16_t,
mlkem/src/poly.c:172:   c = mlk_ct_sel_int16((int16_t)(c + MLKEM_Q), c, mlk_ct_cmask_neg_i16(c));
mlkem/src/poly.c:174:   mlk_assert_bound(&c, 1, 0, MLKEM_Q);
mlkem/src/poly.c:181:  *              Accordingly, we need a conditional addition of MLKEM_Q
mlkem/src/poly.c:185: MLK_STATIC_TESTABLE void mlk_poly_reduce_c(mlk_poly *r)
mlkem/src/poly.c:186: __contract__(
mlkem/src/poly.c:187:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly.c:188:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly.c:189:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
mlkem/src/poly.c:194:   for (i = 0; i < MLKEM_N; i++)
mlkem/src/poly.c:195:   __loop__(
mlkem/src/poly.c:196:     invariant(i <= MLKEM_N)
mlkem/src/poly.c:197:     invariant(array_bound(r->coeffs, 0, i, 0, MLKEM_Q))
mlkem/src/poly.c:198:     decreases(MLKEM_N - i))
mlkem/src/poly.c:206:   mlk_assert_bound(r, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly.c:210: void mlk_poly_reduce(mlk_poly *r)
mlkem/src/poly.c:214:   ret = mlk_poly_reduce_native(r->coeffs);
mlkem/src/poly.c:217:     mlk_assert_bound(r, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly.c:222:   mlk_poly_reduce_c(r);
mlkem/src/poly.c:229: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.c:232:   for (i = 0; i < MLKEM_N; i++)
mlkem/src/poly.c:233:   __loop__(
mlkem/src/poly.c:234:     invariant(i <= MLKEM_N)
mlkem/src/poly.c:235:     invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
mlkem/src/poly.c:236:     invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] + b->coeffs[k1]))
mlkem/src/poly.c:237:     decreases(MLKEM_N - i))
mlkem/src/poly.c:248: void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.c:251:   for (i = 0; i < MLKEM_N; i++)
mlkem/src/poly.c:252:   __loop__(
mlkem/src/poly.c:253:     invariant(i <= MLKEM_N)
mlkem/src/poly.c:254:     invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
mlkem/src/poly.c:255:     invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] - b->coeffs[k1]))
mlkem/src/poly.c:256:     decreases(MLKEM_N - i))
mlkem/src/poly.c:269: MLK_STATIC_TESTABLE void mlk_poly_mulcache_compute_c(mlk_poly_mulcache *x,
mlkem/src/poly.c:270:                                                      const mlk_poly *a)
mlkem/src/poly.c:271: __contract__(
mlkem/src/poly.c:272:   requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
mlkem/src/poly.c:273:   requires(memory_no_alias(a, sizeof(mlk_poly)))
mlkem/src/poly.c:274:   assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
mlkem/src/poly.c:278:   for (i = 0; i < MLKEM_N / 4; i++)
mlkem/src/poly.c:279:   __loop__(
mlkem/src/poly.c:280:     invariant(i <= MLKEM_N / 4)
mlkem/src/poly.c:281:     invariant(array_abs_bound(x->coeffs, 0, 2 * i, MLKEM_Q))
mlkem/src/poly.c:282:     decreases(MLKEM_N / 4 - i))
mlkem/src/poly.c:285:     /* The values in zeta table are <= MLKEM_Q in absolute value,
mlkem/src/poly.c:297:   mlk_assert_abs_bound(x, MLKEM_N / 2, MLKEM_Q);
mlkem/src/poly.c:301: void mlk_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
mlkem/src/poly.c:305:   ret = mlk_poly_mulcache_compute_native(x->coeffs, a->coeffs);
mlkem/src/poly.c:312:   mlk_poly_mulcache_compute_c(x, a);
mlkem/src/poly.c:325:  *          coefficients must be bound by `bound + MLKEM_Q`. Post `start`,
mlkem/src/poly.c:328:  * [start, start+2*len) have bound bumped to `bound + MLKEM_Q`.
mlkem/src/poly.c:343: static void mlk_ntt_butterfly_block(int16_t r[MLKEM_N], int16_t zeta,
mlkem/src/poly.c:346: __contract__(
mlkem/src/poly.c:347:   requires(start < MLKEM_N)
mlkem/src/poly.c:348:   requires(1 <= len && len <= MLKEM_N / 2 && start + 2 * len <= MLKEM_N)
mlkem/src/poly.c:349:   requires(0 <= bound && bound < INT16_MAX - MLKEM_Q)
mlkem/src/poly.c:350:   requires(-MLKEM_Q_HALF < zeta && zeta < MLKEM_Q_HALF)
mlkem/src/poly.c:351:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:352:   requires(array_abs_bound(r, 0, start, bound + MLKEM_Q))
mlkem/src/poly.c:353:   requires(array_abs_bound(r, start, MLKEM_N, bound))
mlkem/src/poly.c:354:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:355:   ensures(array_abs_bound(r, 0, start + 2*len, bound + MLKEM_Q))
mlkem/src/poly.c:356:   ensures(array_abs_bound(r, start + 2 * len, MLKEM_N, bound)))
mlkem/src/poly.c:362:   __loop__(
mlkem/src/poly.c:363:     invariant(start <= j && j <= start + len)
mlkem/src/poly.c:368:     invariant(array_abs_bound(r, 0,           j,           bound + MLKEM_Q))
mlkem/src/poly.c:369:     invariant(array_abs_bound(r, j,           start + len, bound))
mlkem/src/poly.c:370:     invariant(array_abs_bound(r, start + len, j + len,     bound + MLKEM_Q))
mlkem/src/poly.c:371:     invariant(array_abs_bound(r, j + len,     MLKEM_N,     bound))
mlkem/src/poly.c:390: static void mlk_ntt_layer(int16_t r[MLKEM_N], unsigned layer)
mlkem/src/poly.c:391: __contract__(
mlkem/src/poly.c:392:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:393:   requires(1 <= layer && layer <= 7)
mlkem/src/poly.c:394:   requires(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
mlkem/src/poly.c:395:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:396:   ensures(array_abs_bound(r, 0, MLKEM_N, (layer + 1) * MLKEM_Q)))
mlkem/src/poly.c:401:   len = (unsigned)MLKEM_N >> layer;
mlkem/src/poly.c:402:   for (start = 0; start < MLKEM_N; start += 2 * len)
mlkem/src/poly.c:403:   __loop__(
mlkem/src/poly.c:404:     invariant(start < MLKEM_N + 2 * len)
mlkem/src/poly.c:405:     invariant(k <= MLKEM_N / 2 && 2 * len * k == start + MLKEM_N)
mlkem/src/poly.c:406:     invariant(array_abs_bound(r, 0, start, layer * MLKEM_Q + MLKEM_Q))
mlkem/src/poly.c:407:     invariant(array_abs_bound(r, start, MLKEM_N, layer * MLKEM_Q))
mlkem/src/poly.c:408:     decreases(MLKEM_N - start))
mlkem/src/poly.c:411:     mlk_ntt_butterfly_block(r, zeta, start, len, layer * MLKEM_Q);
mlkem/src/poly.c:427: MLK_STATIC_TESTABLE void mlk_poly_ntt_c(mlk_poly *p)
mlkem/src/poly.c:428: __contract__(
mlkem/src/poly.c:429:   requires(memory_no_alias(p, sizeof(mlk_poly)))
mlkem/src/poly.c:430:   requires(array_abs_bound(p->coeffs, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:431:   assigns(memory_slice(p, sizeof(mlk_poly)))
mlkem/src/poly.c:432:   ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
mlkem/src/poly.c:438:   mlk_assert_abs_bound(p, MLKEM_N, MLKEM_Q);
mlkem/src/poly.c:443:   __loop__(
mlkem/src/poly.c:444:     invariant(1 <= layer && layer <= 8)
mlkem/src/poly.c:445:     invariant(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
mlkem/src/poly.c:452:   mlk_assert_abs_bound(p, MLKEM_N, MLK_NTT_BOUND);
mlkem/src/poly.c:456: void mlk_poly_ntt(mlk_poly *r)
mlkem/src/poly.c:460:   mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
mlkem/src/poly.c:464:     mlk_assert_abs_bound(r, MLKEM_N, MLK_NTT_BOUND);
mlkem/src/poly.c:469:   mlk_poly_ntt_c(r);
mlkem/src/poly.c:477: __contract__(
mlkem/src/poly.c:478:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:479:   requires(1 <= layer && layer <= 7)
mlkem/src/poly.c:480:   requires(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:481:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
mlkem/src/poly.c:482:   ensures(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q)))
mlkem/src/poly.c:485:   len = (unsigned)MLKEM_N >> layer;
mlkem/src/poly.c:487:   for (start = 0; start < MLKEM_N; start += 2 * len)
mlkem/src/poly.c:488:   __loop__(
mlkem/src/poly.c:489:     invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:490:     invariant(start <= MLKEM_N && k <= 127)
mlkem/src/poly.c:491:     /* Normalised form of k == MLKEM_N / len - 1 - start / (2 * len) */
mlkem/src/poly.c:492:     invariant(2 * len * k + start == 2 * MLKEM_N - 2 * len)
mlkem/src/poly.c:493:     decreases(MLKEM_N - start))
mlkem/src/poly.c:498:     __loop__(
mlkem/src/poly.c:499:       invariant(start <= j && j <= start + len)
mlkem/src/poly.c:500:       invariant(start <= MLKEM_N && k <= 127)
mlkem/src/poly.c:501:       invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:518: MLK_STATIC_TESTABLE void mlk_poly_invntt_tomont_c(mlk_poly *p)
mlkem/src/poly.c:519: __contract__(
mlkem/src/poly.c:520:   requires(memory_no_alias(p, sizeof(mlk_poly)))
mlkem/src/poly.c:521:   assigns(memory_slice(p, sizeof(mlk_poly)))
mlkem/src/poly.c:522:   ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
mlkem/src/poly.c:526:   const int16_t f = 1441; /* check-magic: 1441 == pow(2,32 - 7,MLKEM_Q) */
mlkem/src/poly.c:532:    * absolute value < MLKEM_Q.
mlkem/src/poly.c:534:   for (j = 0; j < MLKEM_N; j++)
mlkem/src/poly.c:535:   __loop__(
mlkem/src/poly.c:536:     invariant(j <= MLKEM_N)
mlkem/src/poly.c:537:     invariant(array_abs_bound(r, 0, j, MLKEM_Q))
mlkem/src/poly.c:538:     decreases(MLKEM_N - j))
mlkem/src/poly.c:545:   __loop__(
mlkem/src/poly.c:546:     invariant(0 <= layer && layer < 8)
mlkem/src/poly.c:547:     invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
mlkem/src/poly.c:553:   mlk_assert_abs_bound(p, MLKEM_N, MLK_INVNTT_BOUND);
mlkem/src/poly.c:557: void mlk_poly_invntt_tomont(mlk_poly *r)
mlkem/src/poly.c:564:     mlk_assert_abs_bound(r, MLKEM_N, MLK_INVNTT_BOUND);
mlkem/src/poly.c:569:   mlk_poly_invntt_tomont_c(r);
mlkem/src/poly.c:574: MLK_EMPTY_CU(mlk_poly)
mlkem/src/poly_k.c:36: #define mlk_poly_cbd_eta1 MLK_ADD_PARAM_SET(mlk_poly_cbd_eta1)
mlkem/src/poly_k.c:37: #define mlk_poly_cbd_eta2 MLK_ADD_PARAM_SET(mlk_poly_cbd_eta2)
mlkem/src/poly_k.c:38: #define mlk_polyvec_basemul_acc_montgomery_cached_c \
mlkem/src/poly_k.c:39:   MLK_ADD_PARAM_SET(mlk_polyvec_basemul_acc_montgomery_cached_c)
mlkem/src/poly_k.c:46:  *              in the range [-(MLKEM_Q-1), MLKEM_Q-1]. */
mlkem/src/poly_k.c:48: void mlk_polyvec_compress_du(uint8_t r[MLKEM_POLYVECCOMPRESSEDBYTES_DU],
mlkem/src/poly_k.c:49:                              const mlk_polyvec *a)
mlkem/src/poly_k.c:52:   mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly_k.c:54:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:56:     mlk_poly_compress_du(r + i * MLKEM_POLYCOMPRESSEDBYTES_DU, &a->vec[i]);
mlkem/src/poly_k.c:62: void mlk_polyvec_decompress_du(mlk_polyvec *r,
mlkem/src/poly_k.c:66:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:68:     mlk_poly_decompress_du(&r->vec[i], a + i * MLKEM_POLYCOMPRESSEDBYTES_DU);
mlkem/src/poly_k.c:71:   mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly_k.c:78:  *              in the range [-(MLKEM_Q-1), MLKEM_Q-1]. */
mlkem/src/poly_k.c:80: void mlk_polyvec_tobytes(uint8_t r[MLKEM_POLYVECBYTES], const mlk_polyvec *a)
mlkem/src/poly_k.c:83:   mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly_k.c:85:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:86:   __loop__(
mlkem/src/poly_k.c:87:     assigns(i, memory_slice(r, MLKEM_POLYVECBYTES))
mlkem/src/poly_k.c:88:     invariant(i <= MLKEM_K)
mlkem/src/poly_k.c:89:     decreases(MLKEM_K - i)
mlkem/src/poly_k.c:92:     mlk_poly_tobytes(&r[i * MLKEM_POLYBYTES], &a->vec[i]);
mlkem/src/poly_k.c:98: void mlk_polyvec_frombytes(mlk_polyvec *r, const uint8_t a[MLKEM_POLYVECBYTES])
mlkem/src/poly_k.c:101:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:103:     mlk_poly_frombytes(&r->vec[i], a + i * MLKEM_POLYBYTES);
mlkem/src/poly_k.c:106:   mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
mlkem/src/poly_k.c:111: void mlk_polyvec_ntt(mlk_polyvec *r)
mlkem/src/poly_k.c:114:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:116:     mlk_poly_ntt(&r->vec[i]);
mlkem/src/poly_k.c:119:   mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLK_NTT_BOUND);
mlkem/src/poly_k.c:128: void mlk_polyvec_invntt_tomont(mlk_polyvec *r)
mlkem/src/poly_k.c:131:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:133:     mlk_poly_invntt_tomont(&r->vec[i]);
mlkem/src/poly_k.c:136:   mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLK_INVNTT_BOUND);
mlkem/src/poly_k.c:147:  *              at the end. The reference implementation uses 2 * MLKEM_K
mlkem/src/poly_k.c:150: MLK_STATIC_TESTABLE void mlk_polyvec_basemul_acc_montgomery_cached_c(
mlkem/src/poly_k.c:151:     mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
mlkem/src/poly_k.c:152:     const mlk_polyvec_mulcache *b_cache)
mlkem/src/poly_k.c:153: __contract__(
mlkem/src/poly_k.c:154:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:155:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
mlkem/src/poly_k.c:156:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
mlkem/src/poly_k.c:157:   requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
mlkem/src/poly_k.c:158:   requires(forall(k1, 0, MLKEM_K,
mlkem/src/poly_k.c:159:      array_bound(a->vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
mlkem/src/poly_k.c:160:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:164:   mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
mlkem/src/poly_k.c:166:   for (i = 0; i < MLKEM_N / 2; i++)
mlkem/src/poly_k.c:167:   __loop__(invariant(i <= MLKEM_N / 2)
mlkem/src/poly_k.c:168:            decreases(MLKEM_N / 2 - i))
mlkem/src/poly_k.c:172:     for (k = 0; k < MLKEM_K; k++)
mlkem/src/poly_k.c:173:     __loop__(
mlkem/src/poly_k.c:174:       invariant(k <= MLKEM_K &&
mlkem/src/poly_k.c:179:       decreases(MLKEM_K - k))
mlkem/src/poly_k.c:192: void mlk_polyvec_basemul_acc_montgomery_cached(
mlkem/src/poly_k.c:193:     mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
mlkem/src/poly_k.c:194:     const mlk_polyvec_mulcache *b_cache)
mlkem/src/poly_k.c:199:     mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
mlkem/src/poly_k.c:200: #if MLKEM_K == 2
mlkem/src/poly_k.c:201:     ret = mlk_polyvec_basemul_acc_montgomery_cached_k2_native(
mlkem/src/poly_k.c:204: #elif MLKEM_K == 3
mlkem/src/poly_k.c:205:     ret = mlk_polyvec_basemul_acc_montgomery_cached_k3_native(
mlkem/src/poly_k.c:208: #elif MLKEM_K == 4
mlkem/src/poly_k.c:209:     ret = mlk_polyvec_basemul_acc_montgomery_cached_k4_native(
mlkem/src/poly_k.c:220:   mlk_polyvec_basemul_acc_montgomery_cached_c(r, a, b, b_cache);
mlkem/src/poly_k.c:228: void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
mlkem/src/poly_k.c:231:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:233:     mlk_poly_mulcache_compute(&x->vec[i], &a->vec[i]);
mlkem/src/poly_k.c:240:  *              Accordingly, we need a conditional addition of MLKEM_Q
mlkem/src/poly_k.c:245: void mlk_polyvec_reduce(mlk_polyvec *r)
mlkem/src/poly_k.c:248:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:250:     mlk_poly_reduce(&r->vec[i]);
mlkem/src/poly_k.c:253:   mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/poly_k.c:260: void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
mlkem/src/poly_k.c:263:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:264:   __loop__(
mlkem/src/poly_k.c:265:     assigns(i, memory_slice(r, sizeof(mlk_polyvec)))
mlkem/src/poly_k.c:266:     invariant(i <= MLKEM_K)
mlkem/src/poly_k.c:267:     invariant(forall(j0, i, MLKEM_K,
mlkem/src/poly_k.c:268:                 forall(k0, 0, MLKEM_N,
mlkem/src/poly_k.c:271:     invariant(forall(j2, 0, i,
mlkem/src/poly_k.c:272:                 forall(k2, 0, MLKEM_N,
mlkem/src/poly_k.c:275:     decreases(MLKEM_K - i)
mlkem/src/poly_k.c:278:     mlk_poly_add(&r->vec[i], &b->vec[i]);
mlkem/src/poly_k.c:284: void mlk_polyvec_tomont(mlk_polyvec *r)
mlkem/src/poly_k.c:287:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/poly_k.c:289:     mlk_poly_tomont(&r->vec[i]);
mlkem/src/poly_k.c:292:   mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLKEM_Q);
mlkem/src/poly_k.c:310: static MLK_INLINE void mlk_poly_cbd_eta1(
mlkem/src/poly_k.c:311:     mlk_poly *r, const uint8_t buf[MLKEM_ETA1 * MLKEM_N / 4])
mlkem/src/poly_k.c:312: __contract__(
mlkem/src/poly_k.c:313:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:314:   requires(memory_no_alias(buf, MLKEM_ETA1 * MLKEM_N / 4))
mlkem/src/poly_k.c:315:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:316:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1))
mlkem/src/poly_k.c:320:   mlk_poly_cbd2(r, buf);
mlkem/src/poly_k.c:322:   mlk_poly_cbd3(r, buf);
mlkem/src/poly_k.c:333: void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
mlkem/src/poly_k.c:334:                                mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/poly_k.c:338:   MLK_ALIGN uint8_t buf[4][MLK_ALIGN_UP(MLKEM_ETA1 * MLKEM_N / 4)];
mlkem/src/poly_k.c:363:   mlk_poly_cbd_eta1(r0, buf[0]);
mlkem/src/poly_k.c:364:   mlk_poly_cbd_eta1(r1, buf[1]);
mlkem/src/poly_k.c:365:   mlk_poly_cbd_eta1(r2, buf[2]);
mlkem/src/poly_k.c:368:     mlk_poly_cbd_eta1(r3, buf[3]);
mlkem/src/poly_k.c:369:     mlk_assert_abs_bound(r3, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:372:   mlk_assert_abs_bound(r0, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:373:   mlk_assert_abs_bound(r1, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:374:   mlk_assert_abs_bound(r2, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:382: #if MLKEM_K == 2 || MLKEM_K == 4
mlkem/src/poly_k.c:397: static MLK_INLINE void mlk_poly_cbd_eta2(
mlkem/src/poly_k.c:398:     mlk_poly *r, const uint8_t buf[MLKEM_ETA2 * MLKEM_N / 4])
mlkem/src/poly_k.c:399: __contract__(
mlkem/src/poly_k.c:400:   requires(memory_no_alias(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:401:   requires(memory_no_alias(buf, MLKEM_ETA2 * MLKEM_N / 4))
mlkem/src/poly_k.c:402:   assigns(memory_slice(r, sizeof(mlk_poly)))
mlkem/src/poly_k.c:403:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
mlkem/src/poly_k.c:406:   mlk_poly_cbd2(r, buf);
mlkem/src/poly_k.c:415: void mlk_poly_getnoise_eta2(mlk_poly *r, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/poly_k.c:418:   MLK_ALIGN uint8_t buf[MLKEM_ETA2 * MLKEM_N / 4];
mlkem/src/poly_k.c:425:   mlk_poly_cbd_eta2(r, buf);
mlkem/src/poly_k.c:427:   mlk_assert_abs_bound(r, MLKEM_N, MLKEM_ETA2 + 1);
mlkem/src/poly_k.c:434: #endif /* MLKEM_K == 2 || MLKEM_K == 4 */
mlkem/src/poly_k.c:436: #if MLKEM_K == 2
mlkem/src/poly_k.c:445: void mlk_poly_getnoise_eta1122_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
mlkem/src/poly_k.c:446:                                   mlk_poly *r3,
mlkem/src/poly_k.c:452: #error mlk_poly_getnoise_eta1122_4x assumes MLKEM_ETA1 > MLKEM_ETA2
mlkem/src/poly_k.c:454:   MLK_ALIGN uint8_t buf[4][MLK_ALIGN_UP(MLKEM_ETA1 * MLKEM_N / 4)];
mlkem/src/poly_k.c:480:   mlk_poly_cbd_eta1(r0, buf[0]);
mlkem/src/poly_k.c:481:   mlk_poly_cbd_eta1(r1, buf[1]);
mlkem/src/poly_k.c:482:   mlk_poly_cbd_eta2(r2, buf[2]);
mlkem/src/poly_k.c:483:   mlk_poly_cbd_eta2(r3, buf[3]);
mlkem/src/poly_k.c:485:   mlk_assert_abs_bound(r0, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:486:   mlk_assert_abs_bound(r1, MLKEM_N, MLKEM_ETA1 + 1);
mlkem/src/poly_k.c:487:   mlk_assert_abs_bound(r2, MLKEM_N, MLKEM_ETA2 + 1);
mlkem/src/poly_k.c:488:   mlk_assert_abs_bound(r3, MLKEM_N, MLKEM_ETA2 + 1);
mlkem/src/poly_k.c:495: #endif /* MLKEM_K == 2 */
mlkem/src/poly_k.c:499: #undef mlk_poly_cbd_eta1
mlkem/src/poly_k.c:500: #undef mlk_poly_cbd_eta2
mlkem/src/poly_k.c:501: #undef mlk_polyvec_basemul_acc_montgomery_cached_c
mlkem/src/indcpa.c:39: #define mlk_polyvec_permute_bitrev_to_custom \
mlkem/src/indcpa.c:40:   MLK_ADD_PARAM_SET(mlk_polyvec_permute_bitrev_to_custom)
mlkem/src/indcpa.c:41: #define mlk_polymat_permute_bitrev_to_custom \
mlkem/src/indcpa.c:42:   MLK_ADD_PARAM_SET(mlk_polymat_permute_bitrev_to_custom)
mlkem/src/indcpa.c:55:  *                  [0,..,MLKEM_Q-1].
mlkem/src/indcpa.c:59:                         const mlk_polyvec *pk,
mlkem/src/indcpa.c:62:   mlk_assert_bound_2d(pk->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/indcpa.c:63:   mlk_polyvec_tobytes(r, pk);
mlkem/src/indcpa.c:74:  *                      will be normalized to [0,1,..,MLKEM_Q-1].
mlkem/src/indcpa.c:78: static void mlk_unpack_pk(mlk_polyvec *pk, uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/indcpa.c:81:   mlk_polyvec_frombytes(pk, packedpk);
mlkem/src/indcpa.c:99:                         const mlk_polyvec *sk)
mlkem/src/indcpa.c:101:   mlk_assert_bound_2d(sk->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
mlkem/src/indcpa.c:102:   mlk_polyvec_tobytes(r, sk);
mlkem/src/indcpa.c:113: static void mlk_unpack_sk(mlk_polyvec *sk,
mlkem/src/indcpa.c:116:   mlk_polyvec_frombytes(sk, packedsk);
mlkem/src/indcpa.c:131:                                 const mlk_polyvec *b, mlk_poly *v)
mlkem/src/indcpa.c:133:   mlk_polyvec_compress_du(r, b);
mlkem/src/indcpa.c:134:   mlk_poly_compress_dv(r + MLKEM_POLYVECCOMPRESSEDBYTES_DU, v);
mlkem/src/indcpa.c:147: static void mlk_unpack_ciphertext(mlk_polyvec *b, mlk_poly *v,
mlkem/src/indcpa.c:150:   mlk_polyvec_decompress_du(b, c);
mlkem/src/indcpa.c:151:   mlk_poly_decompress_dv(v, c + MLKEM_POLYVECCOMPRESSEDBYTES_DU);
mlkem/src/indcpa.c:160: static void mlk_polyvec_permute_bitrev_to_custom(mlk_polyvec *v)
mlkem/src/indcpa.c:161: __contract__(
mlkem/src/indcpa.c:164:   requires(memory_no_alias(v, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:165:   requires(forall(x, 0, MLKEM_K,
mlkem/src/indcpa.c:166:     array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/indcpa.c:167:   assigns(memory_slice(v, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:168:   ensures(forall(x, 0, MLKEM_K,
mlkem/src/indcpa.c:169:     array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
mlkem/src/indcpa.c:173:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/indcpa.c:174:   __loop__(
mlkem/src/indcpa.c:175:      assigns(i, memory_slice(v, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:176:      invariant(i <= MLKEM_K)
mlkem/src/indcpa.c:177:      invariant(forall(x, 0, MLKEM_K,
mlkem/src/indcpa.c:178:        array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
mlkem/src/indcpa.c:179:      decreases(MLKEM_K - i))
mlkem/src/indcpa.c:181:     mlk_poly_permute_bitrev_to_custom(v->vec[i].coeffs);
mlkem/src/indcpa.c:189: static void mlk_polymat_permute_bitrev_to_custom(mlk_polymat *a)
mlkem/src/indcpa.c:190: __contract__(
mlkem/src/indcpa.c:193:   requires(memory_no_alias(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.c:194:   requires(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
mlkem/src/indcpa.c:195:     array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
mlkem/src/indcpa.c:196:   assigns(memory_slice(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.c:197:   ensures(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
mlkem/src/indcpa.c:198:     array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))))
mlkem/src/indcpa.c:201:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/indcpa.c:202:   __loop__(
mlkem/src/indcpa.c:203:      assigns(i, memory_slice(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.c:204:      invariant(i <= MLKEM_K)
mlkem/src/indcpa.c:205:      invariant(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
mlkem/src/indcpa.c:206:        array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
mlkem/src/indcpa.c:207:      decreases(MLKEM_K - i))
mlkem/src/indcpa.c:209:     mlk_polyvec_permute_bitrev_to_custom(&a->vec[i]);
mlkem/src/indcpa.c:221: void mlk_gen_matrix(mlk_polymat *a, const uint8_t seed[MLKEM_SYMBYTES],
mlkem/src/indcpa.c:234:   for (i = 0; i < (MLKEM_K * MLKEM_K / 4) * 4; i += 4)
mlkem/src/indcpa.c:239:       /* MLKEM_K <= 4, so the values fit in uint8_t. */
mlkem/src/indcpa.c:240:       x = (uint8_t)((i + j) / MLKEM_K);
mlkem/src/indcpa.c:241:       y = (uint8_t)((i + j) % MLKEM_K);
mlkem/src/indcpa.c:254:     mlk_poly_rej_uniform_x4(&a->vec[i / MLKEM_K].vec[i % MLKEM_K],
mlkem/src/indcpa.c:255:                             &a->vec[(i + 1) / MLKEM_K].vec[(i + 1) % MLKEM_K],
mlkem/src/indcpa.c:256:                             &a->vec[(i + 2) / MLKEM_K].vec[(i + 2) % MLKEM_K],
mlkem/src/indcpa.c:257:                             &a->vec[(i + 3) / MLKEM_K].vec[(i + 3) % MLKEM_K],
mlkem/src/indcpa.c:265:   /* For MLKEM_K == 3, sample the last entry individually.
mlkem/src/indcpa.c:268:   for (; i < MLKEM_K * MLKEM_K; i++)
mlkem/src/indcpa.c:271:     /* MLKEM_K <= 4, so the values fit in uint8_t. */
mlkem/src/indcpa.c:272:     x = (uint8_t)(i / MLKEM_K);
mlkem/src/indcpa.c:273:     y = (uint8_t)(i % MLKEM_K);
mlkem/src/indcpa.c:286:     mlk_poly_rej_uniform(&a->vec[i / MLKEM_K].vec[i % MLKEM_K], seed_ext[0]);
mlkem/src/indcpa.c:289:   mlk_assert(i == MLKEM_K * MLKEM_K);
mlkem/src/indcpa.c:295:   mlk_polymat_permute_bitrev_to_custom(a);
mlkem/src/indcpa.c:312:  *                 mlk_polyvec_mulcache_compute().
mlkem/src/indcpa.c:314: static void mlk_matvec_mul(mlk_polyvec *out, const mlk_polymat *a,
mlkem/src/indcpa.c:315:                            const mlk_polyvec *v, const mlk_polyvec_mulcache *vc)
mlkem/src/indcpa.c:316: __contract__(
mlkem/src/indcpa.c:317:   requires(memory_no_alias(out, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:318:   requires(memory_no_alias(a, sizeof(mlk_polymat)))
mlkem/src/indcpa.c:319:   requires(memory_no_alias(v, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:320:   requires(memory_no_alias(vc, sizeof(mlk_polyvec_mulcache)))
mlkem/src/indcpa.c:321:   requires(forall(k0, 0, MLKEM_K,
mlkem/src/indcpa.c:322:     forall(k1, 0, MLKEM_K,
mlkem/src/indcpa.c:323:       array_bound(a->vec[k0].vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT))))
mlkem/src/indcpa.c:324:   assigns(memory_slice(out, sizeof(mlk_polyvec))))
mlkem/src/indcpa.c:327:   for (i = 0; i < MLKEM_K; i++)
mlkem/src/indcpa.c:328:   __loop__(
mlkem/src/indcpa.c:329:     assigns(i, memory_slice(out, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:330:     invariant(i <= MLKEM_K)
mlkem/src/indcpa.c:331:     decreases(MLKEM_K - i))
mlkem/src/indcpa.c:333:     mlk_polyvec_basemul_acc_montgomery_cached(&out->vec[i], &a->vec[i], v, vc);
mlkem/src/indcpa.c:348: static void mlk_keypair_getnoise_eta1(mlk_polyvec *pv, mlk_polyvec *e,
mlkem/src/indcpa.c:350: __contract__(
mlkem/src/indcpa.c:351:   requires(memory_no_alias(pv, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:352:   requires(memory_no_alias(e, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:353:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
mlkem/src/indcpa.c:354:   assigns(memory_slice(pv, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:355:   assigns(memory_slice(e, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:356:   ensures(forall(k0, 0, MLKEM_K, array_abs_bound(pv->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
mlkem/src/indcpa.c:357:   ensures(forall(k1, 0, MLKEM_K, array_abs_bound(e->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
mlkem/src/indcpa.c:360: #if MLKEM_K == 2
mlkem/src/indcpa.c:361:   mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], /* Fill elements of pv */
mlkem/src/indcpa.c:364: #elif MLKEM_K == 3
mlkem/src/indcpa.c:369:   mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], &pv->vec[2], NULL, seed,
mlkem/src/indcpa.c:372:   mlk_poly_getnoise_eta1_4x(&e->vec[0], &e->vec[1], &e->vec[2], NULL, seed, 3,
mlkem/src/indcpa.c:374: #elif MLKEM_K == 4
mlkem/src/indcpa.c:375:   mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], &pv->vec[2], &pv->vec[3],
mlkem/src/indcpa.c:377:   mlk_poly_getnoise_eta1_4x(&e->vec[0], &e->vec[1], &e->vec[2], &e->vec[3],
mlkem/src/indcpa.c:379: #endif /* MLKEM_K == 4 */
mlkem/src/indcpa.c:394: static void mlk_enc_getnoise_eta1_eta2(mlk_polyvec *sp, mlk_polyvec *ep,
mlkem/src/indcpa.c:395:                                        mlk_poly *epp,
mlkem/src/indcpa.c:397: __contract__(
mlkem/src/indcpa.c:398:   requires(memory_no_alias(sp, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:399:   requires(memory_no_alias(ep, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:400:   requires(memory_no_alias(epp, sizeof(mlk_poly)))
mlkem/src/indcpa.c:401:   requires(memory_no_alias(coins, MLKEM_SYMBYTES))
mlkem/src/indcpa.c:402:   assigns(memory_slice(sp, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:403:   assigns(memory_slice(ep, sizeof(mlk_polyvec)))
mlkem/src/indcpa.c:404:   assigns(memory_slice(epp, sizeof(mlk_poly)))
mlkem/src/indcpa.c:405:   ensures(forall(k0, 0, MLKEM_K, array_abs_bound(sp->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
mlkem/src/indcpa.c:406:   ensures(forall(k1, 0, MLKEM_K, array_abs_bound(ep->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
mlkem/src/indcpa.c:407:   ensures(array_abs_bound(epp->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
mlkem/src/indcpa.c:410: #if MLKEM_K == 2
mlkem/src/indcpa.c:411:   mlk_poly_getnoise_eta1122_4x(&sp->vec[0], &sp->vec[1], &ep->vec[0],
mlkem/src/indcpa.c:413:   mlk_poly_getnoise_eta2(epp, coins, 4);
mlkem/src/indcpa.c:414: #elif MLKEM_K == 3
mlkem/src/indcpa.c:419:   mlk_poly_getnoise_eta1_4x(&sp->vec[0], &sp->vec[1], &sp->vec[2], NULL, coins,
mlkem/src/indcpa.c:422:   mlk_poly_getnoise_eta2_4x(&ep->vec[0], &ep->vec[1], &ep->vec[2], epp, coins,
mlkem/src/indcpa.c:424: #elif MLKEM_K == 4
mlkem/src/indcpa.c:425:   mlk_poly_getnoise_eta1_4x(&sp->vec[0], &sp->vec[1], &sp->vec[2], &sp->vec[3],
mlkem/src/indcpa.c:427:   mlk_poly_getnoise_eta2_4x(&ep->vec[0], &ep->vec[1], &ep->vec[2], &ep->vec[3],
mlkem/src/indcpa.c:429:   mlk_poly_getnoise_eta2(epp, coins, 8);
mlkem/src/indcpa.c:430: #endif /* MLKEM_K == 4 */
mlkem/src/indcpa.c:451:   MLK_ALLOC(a, mlk_polymat, 1, context);
mlkem/src/indcpa.c:452:   MLK_ALLOC(e, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:453:   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:454:   MLK_ALLOC(skpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:455:   MLK_ALLOC(skpv_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:467:   /* Concatenate coins with MLKEM_K for domain separation of security levels */
mlkem/src/indcpa.c:469:   coins_with_domain_separator[MLKEM_SYMBYTES] = MLKEM_K;
mlkem/src/indcpa.c:485:   mlk_polyvec_ntt(skpv);
mlkem/src/indcpa.c:486:   mlk_polyvec_ntt(e);
mlkem/src/indcpa.c:488:   mlk_polyvec_mulcache_compute(skpv_cache, skpv);
mlkem/src/indcpa.c:490:   mlk_polyvec_tomont(pkpv);
mlkem/src/indcpa.c:492:   mlk_polyvec_add(pkpv, e);
mlkem/src/indcpa.c:493:   mlk_polyvec_reduce(pkpv);
mlkem/src/indcpa.c:494:   mlk_polyvec_reduce(skpv);
mlkem/src/indcpa.c:502:   MLK_FREE(skpv_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:503:   MLK_FREE(skpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:504:   MLK_FREE(pkpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:505:   MLK_FREE(e, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:506:   MLK_FREE(a, mlk_polymat, 1, context);
mlkem/src/indcpa.c:529:   MLK_ALLOC(at, mlk_polymat, 1, context);
mlkem/src/indcpa.c:530:   MLK_ALLOC(sp, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:531:   MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:532:   MLK_ALLOC(ep, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:533:   MLK_ALLOC(b, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:534:   MLK_ALLOC(v, mlk_poly, 1, context);
mlkem/src/indcpa.c:535:   MLK_ALLOC(k, mlk_poly, 1, context);
mlkem/src/indcpa.c:536:   MLK_ALLOC(epp, mlk_poly, 1, context);
mlkem/src/indcpa.c:537:   MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:547:   mlk_poly_frommsg(k, m);
mlkem/src/indcpa.c:561:   mlk_polyvec_ntt(sp);
mlkem/src/indcpa.c:563:   mlk_polyvec_mulcache_compute(sp_cache, sp);
mlkem/src/indcpa.c:565:   mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);
mlkem/src/indcpa.c:567:   mlk_polyvec_invntt_tomont(b);
mlkem/src/indcpa.c:568:   mlk_poly_invntt_tomont(v);
mlkem/src/indcpa.c:570:   mlk_polyvec_add(b, ep);
mlkem/src/indcpa.c:571:   mlk_poly_add(v, epp);
mlkem/src/indcpa.c:572:   mlk_poly_add(v, k);
mlkem/src/indcpa.c:574:   mlk_polyvec_reduce(b);
mlkem/src/indcpa.c:575:   mlk_poly_reduce(v);
mlkem/src/indcpa.c:582:   MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:583:   MLK_FREE(epp, mlk_poly, 1, context);
mlkem/src/indcpa.c:584:   MLK_FREE(k, mlk_poly, 1, context);
mlkem/src/indcpa.c:585:   MLK_FREE(v, mlk_poly, 1, context);
mlkem/src/indcpa.c:586:   MLK_FREE(b, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:587:   MLK_FREE(ep, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:588:   MLK_FREE(pkpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:589:   MLK_FREE(sp, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:590:   MLK_FREE(at, mlk_polymat, 1, context);
mlkem/src/indcpa.c:605:   MLK_ALLOC(b, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:606:   MLK_ALLOC(skpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:607:   MLK_ALLOC(v, mlk_poly, 1, context);
mlkem/src/indcpa.c:608:   MLK_ALLOC(sb, mlk_poly, 1, context);
mlkem/src/indcpa.c:609:   MLK_ALLOC(b_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:620:   mlk_polyvec_ntt(b);
mlkem/src/indcpa.c:621:   mlk_polyvec_mulcache_compute(b_cache, b);
mlkem/src/indcpa.c:622:   mlk_polyvec_basemul_acc_montgomery_cached(sb, skpv, b, b_cache);
mlkem/src/indcpa.c:623:   mlk_poly_invntt_tomont(sb);
mlkem/src/indcpa.c:625:   mlk_poly_sub(v, sb);
mlkem/src/indcpa.c:626:   mlk_poly_reduce(v);
mlkem/src/indcpa.c:628:   mlk_poly_tomsg(m, v);
mlkem/src/indcpa.c:633:   MLK_FREE(b_cache, mlk_polyvec_mulcache, 1, context);
mlkem/src/indcpa.c:634:   MLK_FREE(sb, mlk_poly, 1, context);
mlkem/src/indcpa.c:635:   MLK_FREE(v, mlk_poly, 1, context);
mlkem/src/indcpa.c:636:   MLK_FREE(skpv, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:637:   MLK_FREE(b, mlk_polyvec, 1, context);
mlkem/src/indcpa.c:650: #undef mlk_polyvec_permute_bitrev_to_custom
mlkem/src/indcpa.c:651: #undef mlk_polymat_permute_bitrev_to_custom
```

## 6. Relevant Header Files

### `mlkem/src/poly.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 */

#ifndef MLK_POLY_H
#define MLK_POLY_H


#include "cbmc.h"
#include "common.h"
#include "debug.h"
#include "verify.h"

/* Absolute exclusive upper bound for the output of the inverse NTT */
#define MLK_INVNTT_BOUND (8 * MLKEM_Q)

/* Absolute exclusive upper bound for the output of the forward NTT */
#define MLK_NTT_BOUND (8 * MLKEM_Q)

/**
 * Element of R_q = Z_q[X]/(X^n + 1). Represents polynomial
 * coeffs[0] + X*coeffs[1] + X^2*coeffs[2] + ... + X^{n-1}*coeffs[n-1].
 */
typedef struct
{
  int16_t coeffs[MLKEM_N]; /**< Polynomial coefficients. */
} MLK_ALIGN mlk_poly;

/**
 * INTERNAL representation of precomputed data speeding up
 * the base multiplication of two polynomials in NTT domain.
 */
typedef struct
{
  int16_t coeffs[MLKEM_N >> 1]; /**< Cached coefficients. */
} MLK_ALIGN mlk_poly_mulcache;

/**
 * Generic Montgomery reduction; given a 32-bit integer a, computes a 16-bit
 * integer congruent to a * R^-1 mod MLKEM_Q, where R=2^16.
 *
 * @param a Input integer to be reduced, of absolute value smaller or equal
 *          to INT32_MAX - 2^15 * MLKEM_Q.
 *
 * @return Integer congruent to a * R^-1 modulo MLKEM_Q, with absolute value
 *         <= ceil(|a| / 2^16) + (MLKEM_Q + 1)/2.
 */
static MLK_ALWAYS_INLINE int16_t mlk_montgomery_reduce(int32_t a)
__contract__(
    requires(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
             a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)))
    /* We don't attempt to express an input-dependent output bound
     * as the post-condition here. There are two call-sites for this
     * function:
     * - The base multiplication: Here, we need no output bound.
     * - mlk_fqmul: Here, we inline this function and prove another spec
     *          for mlk_fqmul which does have a post-condition bound. */
)
{
  /* check-magic: 62209 == unsigned_mod(pow(MLKEM_Q, -1, 2^16), 2^16) */
  const uint32_t QINV = 62209;

  /* Compute a*q^{-1} mod 2^16 in unsigned representatives. */
  const uint16_t a_reduced = mlk_cast_int32_to_uint16(a);
  const uint16_t a_inverted = (a_reduced * QINV) & UINT16_MAX;

  /* Lift to signed canonical representative mod 2^16. */
  const int16_t t = mlk_cast_uint16_to_int16(a_inverted);

  int32_t r;

  mlk_assert(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
             a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)));

  r = a - ((int32_t)t * MLKEM_Q);

  /*
   * PORTABILITY: Right-shift on a signed integer is, strictly-speaking,
   * implementation-defined for negative left argument. Here,
   * we assume it's sign-preserving "arithmetic" shift right. (C99 6.5.7 (5))
   */
  r = r >> 16;
  /* Bounds: |r >> 16| <= ceil(|r| / 2^16)
   *                   <= ceil(|a| / 2^16 + MLKEM_Q / 2)
   *                   <= ceil(|a| / 2^16) + (MLKEM_Q + 1) / 2
   *
   * (Note that |a >> n| = ceil(|a| / 2^16) for negative a)
   */
  return (int16_t)r;
}

#define mlk_poly_tomont MLK_NAMESPACE(poly_tomont)
/**
 * In-place conversion of all coefficients of a polynomial from the normal
 * domain to the Montgomery domain.
 *
 * Bounds: output < MLKEM_Q in absolute value.
 *
 * @spec{Internal normalization required in `mlk_indcpa_keypair_derand` as
 * part of matrix-vector multiplication @[FIPS203, Algorithm 13, K-PKE.KeyGen,
 * L18].}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_tomont(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
);

#define mlk_poly_mulcache_compute MLK_NAMESPACE(poly_mulcache_compute)
/**
 * Compute the mulcache for a polynomial in NTT domain.
 *
 * The mulcache of a degree-2 polynomial b := b0 + b1*X in Fq[X]/(X^2-zeta)
 * is the value b1*zeta, needed when computing products of b in
 * Fq[X]/(X^2-zeta).
 *
 * The mulcache of a polynomial in NTT domain -- which is a 128-tuple of
 * degree-2 polynomials in Fq[X]/(X^2-zeta), for varying zeta, is the
 * 128-tuple of mulcaches of those polynomials.
 *
 * @spec{Caches `b_1 * \gamma` in @[FIPS203, Algorithm 12, BaseCaseMultiply,
 * L1].}
 *
 * @param[out] x Mulcache to be populated.
 * @param[in]  a Input polynomial.
 */
/*
 * NOTE: The default C implementation of this function populates
 * the mulcache with values in (-q,q), but this is not needed for the
 * higher level safety proofs, and thus not part of the spec.
 */
MLK_INTERNAL_API
void mlk_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
__contract__(
  requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
);

#define mlk_poly_reduce MLK_NAMESPACE(poly_reduce)
/**
 * Convert a polynomial to unsigned canonical representatives.
 *
 * The input coefficients can be arbitrary integers in int16_t. The output
 * coefficients are in [0,1,..,MLKEM_Q-1].
 *
 * @spec{Normalizes on unsigned canonical representatives ahead of calling
 * @[FIPS203, Compress_d, Eq (4.7)]. This is not made explicit in FIPS 203.}
 *
 * @param[in,out] r Input/output polynomial.
 */
/*
 * NOTE: The semantics of mlk_poly_reduce() is different in
 * the reference implementation, which requires
 * signed canonical output data. Unsigned canonical
 * outputs are better suited to the only remaining
 * use of mlk_poly_reduce() in the context of (de)serialization.
 */
MLK_INTERNAL_API
void mlk_poly_reduce(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
);

#define mlk_poly_add MLK_NAMESPACE(poly_add)
/**
 * Add two polynomials in place.
 *
 * The coefficients of @p r and @p b must be such that the addition does not
 * overflow. Otherwise, the behaviour of this function is undefined.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L21].}
 *
 * @param[in,out] r Input-output polynomial to be added to.
 * @param[in]     b Input polynomial that should be added to @p r. Must be
 *                  disjoint from @p r.
 */
/*
 * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
 * We specialize to the accumulator form to avoid reasoning about aliasing.
 */
MLK_INTERNAL_API
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_poly_sub MLK_NAMESPACE(poly_sub)
/**
 * Subtract two polynomials; no modular reduction is performed.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 15, K-PKE.Decrypt, L6].}
 *
 * @param[in,out] r Input-output polynomial to be subtracted from.
 * @param[in]     b Second input polynomial.
 */
/*
 * NOTE: The reference implementation uses a 3-argument mlk_poly_sub.
 * We specialize to the accumulator form to avoid reasoning about aliasing.
 */
MLK_INTERNAL_API
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] - b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] - b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] - b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_poly_ntt MLK_NAMESPACE(poly_ntt)
/**
 * Compute the negacyclic number-theoretic transform (NTT) of a polynomial
 * in place.
 *
 * The input is assumed to be in normal order and coefficient-wise bound by
 * MLKEM_Q in absolute value.
 *
 * The output polynomial is in bitreversed order, or of a custom order if
 * MLK_USE_NATIVE_NTT_CUSTOM_ORDER is set, and coefficient-wise bound
 * by MLK_NTT_BOUND in absolute value.
 *
 * (NOTE: Sometimes the input to the NTT is actually smaller, which gives
 * better bounds.)
 *
 * @spec{Implements @[FIPS203, Algorithm 9, NTT].}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_ntt(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
);

#define mlk_poly_invntt_tomont MLK_NAMESPACE(poly_invntt_tomont)
/**
 * Compute the inverse negacyclic number-theoretic transform (NTT) of a
 * polynomial in place; input assumed to be in bitreversed order, output in
 * normal order.
 *
 * The input is assumed to be in bitreversed order, or of a custom order if
 * MLK_USE_NATIVE_NTT_CUSTOM_ORDER is set, and can have arbitrary
 * coefficients in int16_t.
 *
 * The output polynomial is in normal order, and coefficient-wise bound by
 * MLK_INVNTT_BOUND in absolute value.
 *
 * @spec{Implements composition of @[FIPS203, Algorithm 10, NTT^{-1}] and
 * elementwise modular multiplication with a suitable Montgomery factor
 * introduced during the base multiplication.}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_invntt_tomont(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
);

#endif /* !MLK_POLY_H */
```

### `mlkem/src/poly_k.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 */

#ifndef MLK_POLY_K_H
#define MLK_POLY_K_H

#include "common.h"
#include "compress.h"
#include "poly.h"

/* Parameter set namespacing
 * This is to facilitate building multiple instances
 * of mlkem-native (e.g. with varying parameter sets)
 * within a single compilation unit. */
#define mlk_polyvec MLK_ADD_PARAM_SET(mlk_polyvec)
#define mlk_polymat MLK_ADD_PARAM_SET(mlk_polymat)
#define mlk_polyvec_mulcache MLK_ADD_PARAM_SET(mlk_polyvec_mulcache)
/* End of parameter set namespacing */

/** Vector of MLKEM_K polynomials. */
typedef struct
{
  mlk_poly vec[MLKEM_K]; /**< Component polynomials. */
} MLK_ALIGN mlk_polyvec;

/** MLKEM_K x MLKEM_K matrix of polynomials. */
typedef struct
{
  mlk_polyvec vec[MLKEM_K]; /**< Rows of the matrix. */
} MLK_ALIGN mlk_polymat;

/** Vector of MLKEM_K mlk_poly_mulcache entries. */
typedef struct
{
  mlk_poly_mulcache vec[MLKEM_K]; /**< Per-component caches. */
} MLK_ALIGN mlk_polyvec_mulcache;

#define mlk_poly_compress_du MLK_NAMESPACE_K(poly_compress_du)
/**
 * Compression (du bits) and subsequent serialization of a polynomial.
 *
 * @spec{Implements `ByteEncode_{d_u} (Compress_{d_u} (u))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L22], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DU
 *               bytes).
 * @param[in]  a Input polynomial. Coefficients must be unsigned canonical,
 *               i.e. in [0,1,..,MLKEM_Q-1].
 */
static MLK_INLINE void mlk_poly_compress_du(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DU], const mlk_poly *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DU)))
{
#if MLKEM_DU == 10
  mlk_poly_compress_d10(r, a);
#elif MLKEM_DU == 11
  mlk_poly_compress_d11(r, a);
#else
#error "Invalid value of MLKEM_DU"
#endif
}

#define mlk_poly_decompress_du MLK_NAMESPACE_K(poly_decompress_du)
/**
 * De-serialization and subsequent decompression (du bits) of a polynomial;
 * approximate inverse of mlk_poly_compress_du.
 *
 * Upon return, the coefficients of the output polynomial are
 * unsigned-canonical (non-negative and smaller than MLKEM_Q).
 *
 * @spec{Implements `Decompress_{d_u} (ByteDecode_{d_u} (u))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L3], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output polynomial.
 * @param[in]  a Input byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DU
 *               bytes).
 */
static MLK_INLINE void mlk_poly_decompress_du(
    mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DU])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
{
#if MLKEM_DU == 10
  mlk_poly_decompress_d10(r, a);
#elif MLKEM_DU == 11
  mlk_poly_decompress_d11(r, a);
#else
#error "Invalid value of MLKEM_DU"
#endif
}

#define mlk_poly_compress_dv MLK_NAMESPACE_K(poly_compress_dv)
/**
 * Compression (dv bits) and subsequent serialization of a polynomial.
 *
 * @spec{Implements `ByteEncode_{d_v} (Compress_{d_v} (v))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L23], with level-specific d_v defined in
 * @[FIPS203, Table 2], and given by MLKEM_DV here.}
 *
 * @param[out] r Output byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DV
 *               bytes).
 * @param[in]  a Input polynomial. Coefficients must be unsigned canonical,
 *               i.e. in [0,1,..,MLKEM_Q-1].
 */
static MLK_INLINE void mlk_poly_compress_dv(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DV], const mlk_poly *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DV))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DV)))
{
#if MLKEM_DV == 4
  mlk_poly_compress_d4(r, a);
#elif MLKEM_DV == 5
  mlk_poly_compress_d5(r, a);
#else
#error "Invalid value of MLKEM_DV"
#endif
}


#define mlk_poly_decompress_dv MLK_NAMESPACE_K(poly_decompress_dv)
/**
 * De-serialization and subsequent decompression (dv bits) of a polynomial;
 * approximate inverse of mlk_poly_compress_dv.
 *
 * Upon return, the coefficients of the output polynomial are
 * unsigned-canonical (non-negative and smaller than MLKEM_Q).
 *
 * @spec{Implements `Decompress_{d_v} (ByteDecode_{d_v} (v))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L4], with level-specific d_v defined in
 * @[FIPS203, Table 2], and given by MLKEM_DV here.}
 *
 * @param[out] r Output polynomial.
 * @param[in]  a Input byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DV
 *               bytes).
 */
static MLK_INLINE void mlk_poly_decompress_dv(
    mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DV])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DV))
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
{
#if MLKEM_DV == 4
  mlk_poly_decompress_d4(r, a);
#elif MLKEM_DV == 5
  mlk_poly_decompress_d5(r, a);
#else
#error "Invalid value of MLKEM_DV"
#endif
}

#define mlk_polyvec_compress_du MLK_NAMESPACE_K(polyvec_compress_du)
/**
 * Compress and serialize a vector of polynomials.
 *
 * @spec{Implements `ByteEncode_{d_u} (Compress_{d_u} (u))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L22], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output byte array (needs space for
 *               MLKEM_POLYVECCOMPRESSEDBYTES_DU bytes).
 * @param[in]  a Input vector of polynomials. Coefficients must be unsigned
 *               canonical, i.e. in [0,1,..,MLKEM_Q-1].
 */
MLK_INTERNAL_API
void mlk_polyvec_compress_du(uint8_t r[MLKEM_POLYVECCOMPRESSEDBYTES_DU],
                             const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(forall(k0, 0, MLKEM_K,
         array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
  assigns(memory_slice(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
);

#define mlk_polyvec_decompress_du MLK_NAMESPACE_K(polyvec_decompress_du)
/**
 * De-serialize and decompress a vector of polynomials; approximate inverse
 * of mlk_polyvec_compress_du.
 *
 * @spec{Implements `Decompress_{d_u} (ByteDecode_{d_u} (u))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L3], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output vector of polynomials. Coefficients are normalized
 *               to [0,1,..,MLKEM_Q-1].
 * @param[in]  a Input byte array (of length MLKEM_POLYVECCOMPRESSEDBYTES_DU
 *               bytes).
 */
MLK_INTERNAL_API
void mlk_polyvec_decompress_du(mlk_polyvec *r,
                               const uint8_t a[MLKEM_POLYVECCOMPRESSEDBYTES_DU])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
         array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
);

#define mlk_polyvec_tobytes MLK_NAMESPACE_K(polyvec_tobytes)
/**
 * Serialize a vector of polynomials.
 *
 * @spec{Implements ByteEncode_12 @[FIPS203, Algorithm 5]. Extended to
 * vectors as per @[FIPS203, 2.4.8 Applying Algorithms to Arrays] and
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[out] r Output byte array (needs space for MLKEM_POLYVECBYTES bytes).
 * @param[in]  a Input vector of polynomials. Each polynomial must have
 *               coefficients in [0,1,..,MLKEM_Q-1].
 */
MLK_INTERNAL_API
void mlk_polyvec_tobytes(uint8_t r[MLKEM_POLYVECBYTES], const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(memory_no_alias(r, MLKEM_POLYVECBYTES))
  requires(forall(k0, 0, MLKEM_K,
         array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
  assigns(memory_slice(r, MLKEM_POLYVECBYTES))
);

#define mlk_polyvec_frombytes MLK_NAMESPACE_K(polyvec_frombytes)
/**
 * De-serialize a vector of polynomials; inverse of mlk_polyvec_tobytes.
 *
 * @spec{Implements ByteDecode_12 @[FIPS203, Algorithm 6]. Extended to
 * vectors as per @[FIPS203, 2.4.8 Applying Algorithms to Arrays] and
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[out] r Output vector of polynomials. Coefficients will be
 *               normalized in [0,1,..,4095].
 * @param[in]  a Input byte array (of length MLKEM_POLYVECBYTES bytes).
 */
MLK_INTERNAL_API
void mlk_polyvec_frombytes(mlk_polyvec *r, const uint8_t a[MLKEM_POLYVECBYTES])
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(memory_no_alias(a, MLKEM_POLYVECBYTES))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
        array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
);

#define mlk_polyvec_ntt MLK_NAMESPACE_K(polyvec_ntt)
/**
 * Apply forward NTT to all elements of a vector of polynomials.
 *
 * The input is assumed to be in normal order and coefficient-wise bound by
 * MLKEM_Q in absolute value.
 *
 * The output polynomial is in bitreversed order, and coefficient-wise bound
 * by MLK_NTT_BOUND in absolute value.
 *
 * @spec{Implements @[FIPS203, Algorithm 9, NTT]. Extended to vectors as per
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[in,out] r Input/output vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_ntt(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_NTT_BOUND)))
);

#define mlk_polyvec_invntt_tomont MLK_NAMESPACE_K(polyvec_invntt_tomont)
/**
 * Apply inverse NTT to all elements of a vector of polynomials and multiply
 * by Montgomery factor 2^16.
 *
 * The input is assumed to be in bitreversed order, and can have arbitrary
 * coefficients in int16_t.
 *
 * The output polynomial is in normal order, and coefficient-wise bound by
 * MLK_INVNTT_BOUND in absolute value.
 *
 * @spec{Implements @[FIPS203, Algorithm 10, NTT^{-1}]. Extended to vectors
 * as per @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[in,out] r Input/output vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_invntt_tomont(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND)))
);

#define mlk_polyvec_basemul_acc_montgomery_cached \
  MLK_NAMESPACE_K(polyvec_basemul_acc_montgomery_cached)
/**
 * Scalar product of two vectors of polynomials in NTT domain, using
 * mulcache for the second operand.
 *
 * Bounds: every coefficient of @p a is assumed to be in [0,1,..,4095]. No
 * bounds guarantees for the coefficients in the result.
 *
 * @spec{Implements @[FIPS203, Section 2.4.7, Eq (2.14)], @[FIPS203,
 * Algorithm 11, MultiplyNTTs], and @[FIPS203, Algorithm 12,
 * BaseCaseMultiply].}
 *
 * @param[out] r       Output polynomial.
 * @param[in]  a       First input polynomial vector.
 * @param[in]  b       Second input polynomial vector.
 * @param[in]  b_cache Mulcache for the second input polynomial vector. Can
 *                     be computed via mlk_polyvec_mulcache_compute().
 */
MLK_INTERNAL_API
void mlk_polyvec_basemul_acc_montgomery_cached(
    mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
    const mlk_polyvec_mulcache *b_cache)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
  requires(forall(k1, 0, MLKEM_K,
     array_bound(a->vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_polyvec_mulcache_compute MLK_NAMESPACE_K(polyvec_mulcache_compute)
/**
 * Compute the mulcache for a vector of polynomials in NTT domain.
 *
 * The mulcache of a degree-2 polynomial b := b0 + b1*X in Fq[X]/(X^2-zeta)
 * is the value b1*zeta, needed when computing products of b in
 * Fq[X]/(X^2-zeta).
 *
 * The mulcache of a polynomial in NTT domain -- which is a 128-tuple of
 * degree-2 polynomials in Fq[X]/(X^2-zeta), for varying zeta, is the
 * 128-tuple of mulcaches of those polynomials.
 *
 * The mulcache of a vector of polynomials is the vector of mulcaches of
 * its entries.
 *
 * @spec{Caches `b_1 * \gamma` in @[FIPS203, Algorithm 12, BaseCaseMultiply,
 * L1].}
 *
 * @param[out] x Mulcache to be populated.
 * @param[in]  a Input polynomial vector.
 */
/*
 * NOTE: The default C implementation of this function populates
 * the mulcache with values in (-q,q), but this is not needed for the
 * higher level safety proofs, and thus not part of the spec.
 */
MLK_INTERNAL_API
void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(x, sizeof(mlk_polyvec_mulcache)))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  assigns(memory_slice(x, sizeof(mlk_polyvec_mulcache)))
);

#define mlk_polyvec_reduce MLK_NAMESPACE_K(polyvec_reduce)
/**
 * Apply Barrett reduction to each coefficient of each element of a vector
 * of polynomials. For details of the Barrett reduction see comments in
 * poly.c.
 *
 * @spec{Normalizes on unsigned canonical representatives ahead of calling
 * @[FIPS203, Compress_d, Eq (4.7)]. This is not made explicit in FIPS 203.}
 *
 * @param[in,out] r Input/output polynomial vector.
 */
/*
 * NOTE: The semantics of mlk_polyvec_reduce() is different in
 *       the reference implementation, which requires
 *       signed canonical output data. Unsigned canonical
 *       outputs are better suited to the only remaining
 *       use of mlk_poly_reduce() in the context of (de)serialization.
 */
MLK_INTERNAL_API
void mlk_polyvec_reduce(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
    array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
);

#define mlk_polyvec_add MLK_NAMESPACE_K(polyvec_add)
/**
 * Add vectors of polynomials.
 *
 * The coefficients of @p r and @p b must be such that the addition does
 * not overflow. Otherwise, the behaviour of this function is undefined.
 *
 * The coefficients returned in @p *r are in int16_t which is sufficient to
 * prove type-safety of calling units. Therefore, no stronger ensures clause
 * is required on this function.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L19].}
 *
 * @param[in,out] r Input-output vector of polynomials to be added to.
 * @param[in]     b Second input vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b, sizeof(mlk_polyvec)))
  requires(forall(j0, 0, MLKEM_K,
          forall(k0, 0, MLKEM_N,
            (int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] <= INT16_MAX)))
  requires(forall(j1, 0, MLKEM_K,
          forall(k1, 0, MLKEM_N,
            (int32_t)r->vec[j1].coeffs[k1] + b->vec[j1].coeffs[k1] >= INT16_MIN)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
);

#define mlk_polyvec_tomont MLK_NAMESPACE_K(polyvec_tomont)
/**
 * In-place conversion of all coefficients of a polynomial vector from the
 * normal domain to the Montgomery domain.
 *
 * Bounds: output < MLKEM_Q in absolute value.
 *
 * @spec{Internal normalization required in `mlk_indcpa_keypair_derand` as
 * part of matrix-vector multiplication @[FIPS203, Algorithm 13, K-PKE.KeyGen,
 * L18].}
 *
 * @param[in,out] r Input/output polynomial vector.
 */
MLK_INTERNAL_API
void mlk_polyvec_tomont(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
    array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
);

#define mlk_poly_getnoise_eta1_4x MLK_NAMESPACE_K(poly_getnoise_eta1_4x)
/**
 * Batch sample four polynomials deterministically from a seed and nonces,
 * with output polynomials close to centered binomial distribution with
 * parameter MLKEM_ETA1.
 *
 * @spec{Implements 4x `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))` appears in
 * @[FIPS203, Algorithm 13, K-PKE.KeyGen, L{9, 13}] and @[FIPS203,
 * Algorithm 14, K-PKE.Encrypt, L10].}
 *
 * @param[out] r0     Output polynomial.
 * @param[out] r1     Output polynomial.
 * @param[out] r2     Output polynomial.
 * @param[out] r3     Output polynomial. May be NULL.
 * @param[in]  seed   Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce0 One-byte input nonce.
 * @param      nonce1 One-byte input nonce.
 * @param      nonce2 One-byte input nonce.
 * @param      nonce3 One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                               mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
                               uint8_t nonce0, uint8_t nonce1, uint8_t nonce2,
                               uint8_t nonce3)
__contract__(
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  requires(memory_no_alias(r0, sizeof(mlk_poly)))
  requires(memory_no_alias(r1, sizeof(mlk_poly)))
  requires(memory_no_alias(r2, sizeof(mlk_poly)))
  requires(r3 == NULL || memory_no_alias(r3, sizeof(mlk_poly)))
  assigns(memory_slice(r0, sizeof(mlk_poly)))
  assigns(memory_slice(r1, sizeof(mlk_poly)))
  assigns(memory_slice(r2, sizeof(mlk_poly)))
  assigns(r3 != NULL: memory_slice(r3, sizeof(mlk_poly)))
  ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(r3 != NULL ==> array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
);

#if MLKEM_ETA1 == MLKEM_ETA2
/*
 * We only require mlk_poly_getnoise_eta2_4x for ml-kem-768 and ml-kem-1024
 * where MLKEM_ETA2 = MLKEM_ETA1 = 2.
 * For ml-kem-512, mlk_poly_getnoise_eta1122_4x is used instead.
 */
#define mlk_poly_getnoise_eta2_4x mlk_poly_getnoise_eta1_4x
#endif /* MLKEM_ETA1 == MLKEM_ETA2 */

#if MLKEM_K == 2 || MLKEM_K == 4
#define mlk_poly_getnoise_eta2 MLK_NAMESPACE_K(poly_getnoise_eta2)
/**
 * Sample a polynomial deterministically from a seed and a nonce, with
 * output polynomial close to centered binomial distribution with parameter
 * MLKEM_ETA2.
 *
 * @spec{Implements `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))` appears in
 * @[FIPS203, Algorithm 14, K-PKE.Encrypt, L14].}
 *
 * @param[out] r     Output polynomial.
 * @param[in]  seed  Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta2(mlk_poly *r, const uint8_t seed[MLKEM_SYMBYTES],
                            uint8_t nonce)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
);
#endif /* MLKEM_K == 2 || MLKEM_K == 4 */

#if MLKEM_K == 2
#define mlk_poly_getnoise_eta1122_4x MLK_NAMESPACE_K(poly_getnoise_eta1122_4x)
/**
 * Batch sample four polynomials deterministically from a seed and nonces,
 * with output polynomials close to centered binomial distribution with
 * parameter MLKEM_ETA1 and MLKEM_ETA2.
 *
 * @spec{Implements two instances each of
 * `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))` and
 * `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))` appears in
 * @[FIPS203, Algorithm 14, K-PKE.Encrypt, L14].}
 *
 * @param[out] r0     Output polynomial.
 * @param[out] r1     Output polynomial.
 * @param[out] r2     Output polynomial.
 * @param[out] r3     Output polynomial.
 * @param[in]  seed   Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce0 One-byte input nonce.
 * @param      nonce1 One-byte input nonce.
 * @param      nonce2 One-byte input nonce.
 * @param      nonce3 One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1122_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                                  mlk_poly *r3,
                                  const uint8_t seed[MLKEM_SYMBYTES],
                                  uint8_t nonce0, uint8_t nonce1,
                                  uint8_t nonce2, uint8_t nonce3)
__contract__(
  requires(memory_no_alias(r0, sizeof(mlk_poly)))
  requires(memory_no_alias(r1, sizeof(mlk_poly)))
  requires(memory_no_alias(r2, sizeof(mlk_poly)))
  requires(memory_no_alias(r3, sizeof(mlk_poly)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  assigns(memory_slice(r0, sizeof(mlk_poly)))
  assigns(memory_slice(r1, sizeof(mlk_poly)))
  assigns(memory_slice(r2, sizeof(mlk_poly)))
  assigns(memory_slice(r3, sizeof(mlk_poly)))
  ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
       && array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
       && array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1)
       && array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1))
);
#endif /* MLKEM_K == 2 */

#endif /* !MLK_POLY_K_H */
```

### `mlkem/src/params.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */
#ifndef MLK_PARAMS_H
#define MLK_PARAMS_H

#if !defined(MLK_CONFIG_PARAMETER_SET)
#error MLK_CONFIG_PARAMETER_SET is not defined
#endif

#if MLK_CONFIG_PARAMETER_SET == 512
#define MLKEM_K 2
#elif MLK_CONFIG_PARAMETER_SET == 768
#define MLKEM_K 3
#elif MLK_CONFIG_PARAMETER_SET == 1024
#define MLKEM_K 4
#else
#error Invalid value for MLK_CONFIG_PARAMETER_SET. Must be 512, 768, or 1024.
#endif

#define MLKEM_N 256
#define MLKEM_Q 3329
#define MLKEM_Q_HALF ((MLKEM_Q + 1) / 2) /* 1665 */
#define MLKEM_UINT12_LIMIT 4096

#define MLKEM_SYMBYTES 32 /* size in bytes of hashes, and seeds */
#define MLKEM_SSBYTES 32  /* size in bytes of shared key */

#define MLKEM_POLYBYTES 384
#define MLKEM_POLYVECBYTES (MLKEM_K * MLKEM_POLYBYTES)

#define MLKEM_POLYCOMPRESSEDBYTES_D4 128
#define MLKEM_POLYCOMPRESSEDBYTES_D5 160
#define MLKEM_POLYCOMPRESSEDBYTES_D10 320
#define MLKEM_POLYCOMPRESSEDBYTES_D11 352

#if MLKEM_K == 2
#define MLKEM_ETA1 3
#define MLKEM_DU 10
#define MLKEM_DV 4
#define MLKEM_POLYCOMPRESSEDBYTES_DV MLKEM_POLYCOMPRESSEDBYTES_D4
#define MLKEM_POLYCOMPRESSEDBYTES_DU MLKEM_POLYCOMPRESSEDBYTES_D10
#define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
#elif MLKEM_K == 3
#define MLKEM_ETA1 2
#define MLKEM_DU 10
#define MLKEM_DV 4
#define MLKEM_POLYCOMPRESSEDBYTES_DV MLKEM_POLYCOMPRESSEDBYTES_D4
#define MLKEM_POLYCOMPRESSEDBYTES_DU MLKEM_POLYCOMPRESSEDBYTES_D10
#define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
#elif MLKEM_K == 4
#define MLKEM_ETA1 2
#define MLKEM_DU 11
#define MLKEM_DV 5
#define MLKEM_POLYCOMPRESSEDBYTES_DV MLKEM_POLYCOMPRESSEDBYTES_D5
#define MLKEM_POLYCOMPRESSEDBYTES_DU MLKEM_POLYCOMPRESSEDBYTES_D11
#define MLKEM_POLYVECCOMPRESSEDBYTES_DU (MLKEM_K * MLKEM_POLYCOMPRESSEDBYTES_DU)
#endif /* MLKEM_K == 4 */

#define MLKEM_ETA2 2

#define MLKEM_INDCPA_MSGBYTES (MLKEM_SYMBYTES)
#define MLKEM_INDCPA_PUBLICKEYBYTES (MLKEM_POLYVECBYTES + MLKEM_SYMBYTES)
#define MLKEM_INDCPA_SECRETKEYBYTES (MLKEM_POLYVECBYTES)
#define MLKEM_INDCPA_BYTES \
  (MLKEM_POLYVECCOMPRESSEDBYTES_DU + MLKEM_POLYCOMPRESSEDBYTES_DV)

#define MLKEM_INDCCA_PUBLICKEYBYTES (MLKEM_INDCPA_PUBLICKEYBYTES)
/* 32 bytes of additional space to save H(pk) */
#define MLKEM_INDCCA_SECRETKEYBYTES                            \
  (MLKEM_INDCPA_SECRETKEYBYTES + MLKEM_INDCPA_PUBLICKEYBYTES + \
   2 * MLKEM_SYMBYTES)
#define MLKEM_INDCCA_CIPHERTEXTBYTES (MLKEM_INDCPA_BYTES)

#endif /* !MLK_PARAMS_H */
```

### `mlkem/src/common.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */
#ifndef MLK_COMMON_H
#define MLK_COMMON_H

#ifndef __ASSEMBLER__
#include <stdint.h>
#endif

#define MLK_BUILD_INTERNAL

#if defined(MLK_CONFIG_FILE)
#include MLK_CONFIG_FILE
#else
#include "mlkem_native_config.h"
#endif

#include "params.h"
#include "sys.h"

/* Internal and public API have external linkage by default, but
 * this can be overwritten by the user, e.g. for single-CU builds. */
#if !defined(MLK_CONFIG_INTERNAL_API_QUALIFIER)
#define MLK_INTERNAL_API
#define MLK_INTERNAL_DATA_DECLARATION extern
#define MLK_INTERNAL_DATA_DEFINITION
#else
#define MLK_INTERNAL_API MLK_CONFIG_INTERNAL_API_QUALIFIER
#define MLK_INTERNAL_DATA_DECLARATION MLK_CONFIG_INTERNAL_API_QUALIFIER
#define MLK_INTERNAL_DATA_DEFINITION MLK_CONFIG_INTERNAL_API_QUALIFIER
#endif

#if !defined(MLK_CONFIG_EXTERNAL_API_QUALIFIER)
#define MLK_EXTERNAL_API
#else
#define MLK_EXTERNAL_API MLK_CONFIG_EXTERNAL_API_QUALIFIER
#endif

#define MLK_CONCAT_(x1, x2) x1##x2
#define MLK_CONCAT(x1, x2) MLK_CONCAT_(x1, x2)

#if (defined(MLK_CONFIG_MULTILEVEL_WITH_SHARED) || \
     defined(MLK_CONFIG_MULTILEVEL_NO_SHARED))
#define MLK_ADD_PARAM_SET(s) MLK_CONCAT(s, MLK_CONFIG_PARAMETER_SET)
#else
#define MLK_ADD_PARAM_SET(s) s
#endif

#define MLK_NAMESPACE_PREFIX MLK_CONCAT(MLK_CONFIG_NAMESPACE_PREFIX, _)
#define MLK_NAMESPACE_PREFIX_K \
  MLK_CONCAT(MLK_ADD_PARAM_SET(MLK_CONFIG_NAMESPACE_PREFIX), _)

/* Functions are prefixed by MLK_CONFIG_NAMESPACE_PREFIX.
 *
 * If multiple parameter sets are used, functions depending on the parameter
 * set are additionally prefixed with 512/768/1024. See mlkem_native_config.h.
 *
 * Example: If MLK_CONFIG_NAMESPACE_PREFIX is mlkem, then
 * MLK_NAMESPACE_K(enc) becomes mlkem512_enc/mlkem768_enc/mlkem1024_enc.
 */
#define MLK_NAMESPACE(s) MLK_CONCAT(MLK_NAMESPACE_PREFIX, s)
#define MLK_NAMESPACE_K(s) MLK_CONCAT(MLK_NAMESPACE_PREFIX_K, s)

/* On Apple platforms, we need to emit leading underscore
 * in front of assembly symbols. We thus introducee a separate
 * namespace wrapper for ASM symbols. */
#if !defined(__APPLE__)
#define MLK_ASM_NAMESPACE(sym) MLK_NAMESPACE(sym)
#else
#define MLK_ASM_NAMESPACE(sym) MLK_CONCAT(_, MLK_NAMESPACE(sym))
#endif

/*
 * On X86_64 if control-flow protections (CET) are enabled (through
 * -fcf-protection=), we add an endbr64 instruction at every global function
 * label.  See sys.h for more details
 */
#if defined(MLK_SYS_X86_64)
#define MLK_ASM_FN_SYMBOL(sym) MLK_ASM_NAMESPACE(sym) : MLK_CET_ENDBR
#elif defined(MLK_SYS_ARMV81M_MVE)
/* clang-format off */
#define MLK_ASM_FN_SYMBOL(sym) \
  .type MLK_ASM_NAMESPACE(sym), %function; \
  MLK_ASM_NAMESPACE(sym) :
/* clang-format on */
#else /* !MLK_SYS_X86_64 && MLK_SYS_ARMV81M_MVE */
#define MLK_ASM_FN_SYMBOL(sym) MLK_ASM_NAMESPACE(sym) :
#endif /* !MLK_SYS_X86_64 && !MLK_SYS_ARMV81M_MVE */

/*
 * Output the size of an assembly function.
 */
#if defined(__ELF__)
#define MLK_ASM_FN_SIZE(sym) \
  .size MLK_ASM_NAMESPACE(sym), .- MLK_ASM_NAMESPACE(sym)
#else
#define MLK_ASM_FN_SIZE(sym)
#endif

/* We aim to simplify the user's life by supporting builds where
 * all source files are included, even those that are not needed.
 * Those files are appropriately guarded and will be empty when unneeded.
 * The following is to avoid compilers complaining about this. */
#define MLK_EMPTY_CU(s) extern int MLK_NAMESPACE_K(empty_cu_##s);

/* MLK_CONFIG_NO_ASM takes precedence over MLK_USE_NATIVE_XXX */
#if defined(MLK_CONFIG_NO_ASM)
#undef MLK_CONFIG_USE_NATIVE_BACKEND_ARITH
#undef MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202
#endif

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_ARITH) && \
    !defined(MLK_CONFIG_ARITH_BACKEND_FILE)
#error Bad configuration: MLK_CONFIG_USE_NATIVE_BACKEND_ARITH is set, but MLK_CONFIG_ARITH_BACKEND_FILE is not.
#endif

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202) && \
    !defined(MLK_CONFIG_FIPS202_BACKEND_FILE)
#error Bad configuration: MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202 is set, but MLK_CONFIG_FIPS202_BACKEND_FILE is not.
#endif

#if defined(MLK_CONFIG_NO_RANDOMIZED_API) && defined(MLK_CONFIG_KEYGEN_PCT)
#error Bad configuration: MLK_CONFIG_NO_RANDOMIZED_API is incompatible with MLK_CONFIG_KEYGEN_PCT as the current PCT implementation requires crypto_kem_enc()
#endif

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_ARITH)
#include MLK_CONFIG_ARITH_BACKEND_FILE
/* Include to enforce consistency of API and implementation,
 * and conduct sanity checks on the backend.
 *
 * Keep this _after_ the inclusion of the backend; otherwise,
 * the sanity checks won't have an effect. */
#if defined(MLK_CHECK_APIS) && !defined(__ASSEMBLER__)
#include "native/api.h"
#endif
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_ARITH */

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202)
#include MLK_CONFIG_FIPS202_BACKEND_FILE
/* Include to enforce consistency of API and implementation,
 * and conduct sanity checks on the backend.
 *
 * Keep this _after_ the inclusion of the backend; otherwise,
 * the sanity checks won't have an effect. */
#if defined(MLK_CHECK_APIS) && !defined(__ASSEMBLER__)
#include "fips202/native/api.h"
#endif
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202 */

#if !defined(MLK_CONFIG_FIPS202_CUSTOM_HEADER)
#define MLK_FIPS202_HEADER_FILE "fips202/fips202.h"
#else
#define MLK_FIPS202_HEADER_FILE MLK_CONFIG_FIPS202_CUSTOM_HEADER
#endif

#if !defined(MLK_CONFIG_FIPS202X4_CUSTOM_HEADER)
#define MLK_FIPS202X4_HEADER_FILE "fips202/fips202x4.h"
#else
#define MLK_FIPS202X4_HEADER_FILE MLK_CONFIG_FIPS202X4_CUSTOM_HEADER
#endif

/* Standard library function replacements */
#if !defined(__ASSEMBLER__)
#if !defined(MLK_CONFIG_CUSTOM_MEMCPY)
#include <string.h>
#define mlk_memcpy memcpy
#endif

#if !defined(MLK_CONFIG_CUSTOM_MEMSET)
#include <string.h>
#define mlk_memset memset
#endif


/* Allocation macros for large local structures
 *
 * MLK_ALLOC(v, T, N) declares T *v and attempts to point it to an T[N]
 * MLK_FREE(v, T, N) zeroizes and frees the allocation
 *
 * Default implementation uses stack allocation.
 * Can be overridden by setting the config option MLK_CONFIG_CUSTOM_ALLOC_FREE
 * and defining MLK_CUSTOM_ALLOC and MLK_CUSTOM_FREE.
 */
#if defined(MLK_CONFIG_CUSTOM_ALLOC_FREE) != \
    (defined(MLK_CUSTOM_ALLOC) && defined(MLK_CUSTOM_FREE))
#error Bad configuration: MLK_CONFIG_CUSTOM_ALLOC_FREE must be set together with MLK_CUSTOM_ALLOC and MLK_CUSTOM_FREE
#endif

/*
 * If the integration wants to provide a context parameter for use in
 * platform-specific hooks, then it should define this parameter.
 *
 * The MLK_CONTEXT_PARAMETERS_n macros are intended to be used with macros
 * defining the function names and expand to either pass or discard the context
 * argument as required by the current build.  If there is no context parameter
 * requested then these are removed from the prototypes and from all calls.
 */
#ifdef MLK_CONFIG_CONTEXT_PARAMETER
#define MLK_CONTEXT_PARAMETERS_0(context) (context)
#define MLK_CONTEXT_PARAMETERS_1(arg0, context) (arg0, context)
#define MLK_CONTEXT_PARAMETERS_2(arg0, arg1, context) (arg0, arg1, context)
#define MLK_CONTEXT_PARAMETERS_3(arg0, arg1, arg2, context) \
  (arg0, arg1, arg2, context)
#define MLK_CONTEXT_PARAMETERS_4(arg0, arg1, arg2, arg3, context) \
  (arg0, arg1, arg2, arg3, context)
#else /* MLK_CONFIG_CONTEXT_PARAMETER */
#define MLK_CONTEXT_PARAMETERS_0(context) ()
#define MLK_CONTEXT_PARAMETERS_1(arg0, context) (arg0)
#define MLK_CONTEXT_PARAMETERS_2(arg0, arg1, context) (arg0, arg1)
#define MLK_CONTEXT_PARAMETERS_3(arg0, arg1, arg2, context) (arg0, arg1, arg2)
#define MLK_CONTEXT_PARAMETERS_4(arg0, arg1, arg2, arg3, context) \
  (arg0, arg1, arg2, arg3)
#endif /* !MLK_CONFIG_CONTEXT_PARAMETER */

#if defined(MLK_CONFIG_CONTEXT_PARAMETER_TYPE) != \
    defined(MLK_CONFIG_CONTEXT_PARAMETER)
#error MLK_CONFIG_CONTEXT_PARAMETER_TYPE must be defined if and only if MLK_CONFIG_CONTEXT_PARAMETER is defined
#endif

#if !defined(MLK_CONFIG_CUSTOM_ALLOC_FREE)
/* Default: stack allocation */

/* This is a declaration macro, not an expression macro: T is a type and v is
 * a declarator, neither of which can be wrapped in parentheses. The
 * bugprone-macro-parentheses diagnostic is therefore a false positive here. */
#define MLK_ALLOC(v, T, N, context) \
  MLK_ALIGN T mlk_alloc_##v[N];     \
  T *v = mlk_alloc_##v /* NOLINT(bugprone-macro-parentheses) */

/* The MLK_FREE macro body references mlk_zeroize(), which is declared in
 * verify.h. We deliberately do NOT include verify.h here: doing so would
 * create a circular dependency (verify.h includes common.h), and common.h
 * itself never calls mlk_zeroize() -- only the macro expansion does. Each
 * translation unit that uses MLK_FREE therefore includes verify.h directly. */
#define MLK_FREE(v, T, N, context)                     \
  do                                                   \
  {                                                    \
    mlk_zeroize(mlk_alloc_##v, sizeof(mlk_alloc_##v)); \
    (v) = NULL;                                        \
  } while (0)

#else /* !MLK_CONFIG_CUSTOM_ALLOC_FREE */

/* Custom allocation */

/*
 * The indirection here is necessary to use MLK_CONTEXT_PARAMETERS_3 here.
 */
#define MLK_APPLY(f, args) f args

#define MLK_ALLOC(v, T, N, context) \
  MLK_APPLY(MLK_CUSTOM_ALLOC, MLK_CONTEXT_PARAMETERS_3(v, T, N, context))

#define MLK_FREE(v, T, N, context)                                            \
  do                                                                          \
  {                                                                           \
    if (v != NULL)                                                            \
    {                                                                         \
      mlk_zeroize(v, sizeof(T) * (N));                                        \
      MLK_APPLY(MLK_CUSTOM_FREE, MLK_CONTEXT_PARAMETERS_3(v, T, N, context)); \
      v = NULL;                                                               \
    }                                                                         \
  } while (0)

#endif /* MLK_CONFIG_CUSTOM_ALLOC_FREE */

/****************************** Error codes ***********************************/

/* Generic failure condition */
#define MLK_ERR_FAIL (-1)
/* An allocation failed. This can only happen if MLK_CONFIG_CUSTOM_ALLOC_FREE
 * is defined and the provided MLK_CUSTOM_ALLOC can fail. */
#define MLK_ERR_OUT_OF_MEMORY (-2)
/* An rng failure occured. Might be due to insufficient entropy or
 * system misconfiguration. */
#define MLK_ERR_RNG_FAIL (-3)

#endif /* !__ASSEMBLER__ */

#endif /* !MLK_COMMON_H */
```

### `mlkem/src/indcpa.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 */

#ifndef MLK_INDCPA_H
#define MLK_INDCPA_H

#include "cbmc.h"
#include "common.h"
#include "poly_k.h"

#define mlk_gen_matrix MLK_NAMESPACE_K(gen_matrix)
/**
 * Deterministically generate matrix A (or the transpose of A) from a seed.
 * Entries of the matrix are polynomials that look uniformly random.
 * Performs rejection sampling on the output of an XOF.
 *
 * @spec{Implements @[FIPS203, Algorithm 13 (K-PKE.KeyGen), L3-7] and
 * @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L4-8]. The @p transposed
 * parameter only affects internal presentation.}
 *
 * @param[out] a          Output matrix A.
 * @param[in]  seed       Input seed.
 * @param      transposed Boolean deciding whether A or A^T is generated.
 */
MLK_INTERNAL_API
void mlk_gen_matrix(mlk_polymat *a, const uint8_t seed[MLKEM_SYMBYTES],
                    int transposed)
__contract__(
  requires(memory_no_alias(a, sizeof(mlk_polymat)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  requires(transposed == 0 || transposed == 1)
  assigns(memory_slice(a, sizeof(mlk_polymat)))
  ensures(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
  array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
);

#define mlk_indcpa_keypair_derand \
  MLK_NAMESPACE_K(indcpa_keypair_derand) MLK_CONTEXT_PARAMETERS_3
/**
 * Generate public and private key for the CPA-secure public-key encryption
 * scheme underlying ML-KEM.
 *
 * @spec{Implements @[FIPS203, Algorithm 13 (K-PKE.KeyGen)].}
 *
 * @param[out] pk      Output public key
 *                     (length MLKEM_INDCPA_PUBLICKEYBYTES bytes).
 * @param[out] sk      Output private key
 *                     (length MLKEM_INDCPA_SECRETKEYBYTES bytes).
 * @param[in]  coins   Input randomness (length MLKEM_SYMBYTES bytes).
 * @param      context Application context. Only present when
 *                     MLK_CONFIG_CONTEXT_PARAMETER is defined; type set by
 *                     MLK_CONFIG_CONTEXT_PARAMETER_TYPE.
 *
 * @retval 0                     Success.
 * @retval MLK_ERR_FAIL          MLK_CONFIG_KEYGEN_PCT enabled and PCT failed.
 * @retval MLK_ERR_OUT_OF_MEMORY MLK_CONFIG_CUSTOM_ALLOC_FREE was used and
 *                               MLK_CUSTOM_ALLOC returned NULL.
 * @retval MLK_ERR_RNG_FAIL      Random number generation failed.
 */
MLK_INTERNAL_API
MLK_MUST_CHECK_RETURN_VALUE
int mlk_indcpa_keypair_derand(uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
                              uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
                              const uint8_t coins[MLKEM_SYMBYTES],
                              MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
__contract__(
  requires(memory_no_alias(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
  requires(memory_no_alias(sk, MLKEM_INDCPA_SECRETKEYBYTES))
  requires(memory_no_alias(coins, MLKEM_SYMBYTES))
  assigns(memory_slice(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
  assigns(memory_slice(sk, MLKEM_INDCPA_SECRETKEYBYTES))
  ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
          return_value == MLK_ERR_OUT_OF_MEMORY ||
          return_value == MLK_ERR_RNG_FAIL)
);

#define mlk_indcpa_enc MLK_NAMESPACE_K(indcpa_enc) MLK_CONTEXT_PARAMETERS_4
/**
 * Encryption function of the CPA-secure public-key encryption scheme
 * underlying ML-KEM.
 *
 * @spec{Implements @[FIPS203, Algorithm 14 (K-PKE.Encrypt)].}
 *
 * @param[out] c       Output ciphertext (length MLKEM_INDCPA_BYTES bytes).
 * @param[in]  m       Input message (length MLKEM_INDCPA_MSGBYTES bytes).
 * @param[in]  pk      Input public key
 *                     (length MLKEM_INDCPA_PUBLICKEYBYTES bytes).
 * @param[in]  coins   Input random coins used as seed (length MLKEM_SYMBYTES
 *                     bytes) to deterministically generate all randomness.
 * @param      context Application context. Only present when
 *                     MLK_CONFIG_CONTEXT_PARAMETER is defined; type set by
 *                     MLK_CONFIG_CONTEXT_PARAMETER_TYPE.
 *
 * @retval 0                     Success.
 * @retval MLK_ERR_FAIL          Operation failed.
 * @retval MLK_ERR_OUT_OF_MEMORY MLK_CONFIG_CUSTOM_ALLOC_FREE was used and
 *                               MLK_CUSTOM_ALLOC returned NULL.
 */
MLK_INTERNAL_API
MLK_MUST_CHECK_RETURN_VALUE
int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
                   const uint8_t m[MLKEM_INDCPA_MSGBYTES],
                   const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
                   const uint8_t coins[MLKEM_SYMBYTES],
                   MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
__contract__(
  requires(memory_no_alias(c, MLKEM_INDCPA_BYTES))
  requires(memory_no_alias(m, MLKEM_INDCPA_MSGBYTES))
  requires(memory_no_alias(pk, MLKEM_INDCPA_PUBLICKEYBYTES))
  requires(memory_no_alias(coins, MLKEM_SYMBYTES))
  assigns(memory_slice(c, MLKEM_INDCPA_BYTES))
  ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
          return_value == MLK_ERR_OUT_OF_MEMORY)
);

#define mlk_indcpa_dec MLK_NAMESPACE_K(indcpa_dec) MLK_CONTEXT_PARAMETERS_3
/**
 * Decryption function of the CPA-secure public-key encryption scheme
 * underlying ML-KEM.
 *
 * @spec{Implements @[FIPS203, Algorithm 15 (K-PKE.Decrypt)].}
 *
 * @param[out] m       Output decrypted message
 *                     (length MLKEM_INDCPA_MSGBYTES bytes).
 * @param[in]  c       Input ciphertext (length MLKEM_INDCPA_BYTES bytes).
 * @param[in]  sk      Input secret key
 *                     (length MLKEM_INDCPA_SECRETKEYBYTES bytes).
 * @param      context Application context. Only present when
 *                     MLK_CONFIG_CONTEXT_PARAMETER is defined; type set by
 *                     MLK_CONFIG_CONTEXT_PARAMETER_TYPE.
 *
 * @retval 0                     Success.
 * @retval MLK_ERR_FAIL          Operation failed.
 * @retval MLK_ERR_OUT_OF_MEMORY MLK_CONFIG_CUSTOM_ALLOC_FREE was used and
 *                               MLK_CUSTOM_ALLOC returned NULL.
 */
MLK_INTERNAL_API
MLK_MUST_CHECK_RETURN_VALUE
int mlk_indcpa_dec(uint8_t m[MLKEM_INDCPA_MSGBYTES],
                   const uint8_t c[MLKEM_INDCPA_BYTES],
                   const uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
                   MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
__contract__(
  requires(memory_no_alias(c, MLKEM_INDCPA_BYTES))
  requires(memory_no_alias(m, MLKEM_INDCPA_MSGBYTES))
  requires(memory_no_alias(sk, MLKEM_INDCPA_SECRETKEYBYTES))
  assigns(memory_slice(m, MLKEM_INDCPA_MSGBYTES))
  ensures(return_value == 0 || return_value == MLK_ERR_FAIL ||
          return_value == MLK_ERR_OUT_OF_MEMORY)
);

#endif /* !MLK_INDCPA_H */
```

## 7. Source File Hashes

```text
5598905a5655ae8aa5215591d973c79db77dd8978c89bf715c2292f5c9a5be5f  mlkem/src/common.h
ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd  mlkem/src/indcpa.c
25537257adf04a0db9764a1034f0f7af0be25ec0a37c47faff81fb32ee93c5f1  mlkem/src/indcpa.h
450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb  mlkem/src/params.h
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722  mlkem/src/poly.c
f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef  mlkem/src/poly.h
7dea24a0591b0fb033f7a8be214d687fbde11541c274a114ac3067af12b87c32  mlkem/src/poly_k.c
09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0  mlkem/src/poly_k.h
```

## 8. Next Deterministic PA-05 Action

Use this bundle to derive one caller-context verification unit for each production call. No coefficient bound, aliasing condition, or caller precondition should be guessed before analysing these exact functions and their producer operations.
