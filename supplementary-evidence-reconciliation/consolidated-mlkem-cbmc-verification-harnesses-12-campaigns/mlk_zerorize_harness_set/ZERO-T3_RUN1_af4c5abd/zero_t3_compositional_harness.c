#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

#define ZERO_T3_HOST_BYTES 16u

size_t nondet_size_t(void);
uint8_t nondet_uint8_t(void);

void harness(void)
{
  uint8_t id_once[ZERO_T3_HOST_BYTES];
  uint8_t id_twice[ZERO_T3_HOST_BYTES];

  uint8_t adjacent_sequence[ZERO_T3_HOST_BYTES];
  uint8_t adjacent_union[ZERO_T3_HOST_BYTES];

  uint8_t disjoint_ab[ZERO_T3_HOST_BYTES];
  uint8_t disjoint_ba[ZERO_T3_HOST_BYTES];

  uint8_t overlap_sequence[ZERO_T3_HOST_BYTES];
  uint8_t overlap_union[ZERO_T3_HOST_BYTES];

  size_t i;

  size_t id_offset;
  size_t id_length;
  size_t id_end;
  size_t id_witness;

  size_t adj_offset;
  size_t adj_length_1;
  size_t adj_length_2;
  size_t adj_boundary;
  size_t adj_total;
  size_t adj_witness_1;
  size_t adj_witness_2;

  size_t d1_offset;
  size_t d1_length;
  size_t d1_end;
  size_t d1_witness;

  size_t d2_offset;
  size_t d2_length;
  size_t d2_end;
  size_t d2_witness;

  size_t o1_offset;
  size_t o1_length;
  size_t o1_end;
  size_t o1_witness;

  size_t o2_offset;
  size_t o2_length;
  size_t o2_end;
  size_t o2_witness;

  size_t union_offset;
  size_t union_end;
  size_t union_length;

  for (i = 0u; i < ZERO_T3_HOST_BYTES; i++)
  {
    uint8_t id_value = nondet_uint8_t();
    uint8_t adjacent_value = nondet_uint8_t();
    uint8_t disjoint_value = nondet_uint8_t();
    uint8_t overlap_value = nondet_uint8_t();

    id_once[i] = id_value;
    id_twice[i] = id_value;

    adjacent_sequence[i] = adjacent_value;
    adjacent_union[i] = adjacent_value;

    disjoint_ab[i] = disjoint_value;
    disjoint_ba[i] = disjoint_value;

    overlap_sequence[i] = overlap_value;
    overlap_union[i] = overlap_value;
  }

  /*
   * T3.P1 — Idempotence.
   */
  id_offset = nondet_size_t();
  id_length = nondet_size_t();
  id_witness = nondet_size_t();

  __CPROVER_assume(id_offset < ZERO_T3_HOST_BYTES);
  __CPROVER_assume(id_length > 0u);
  __CPROVER_assume(id_length <= ZERO_T3_HOST_BYTES - id_offset);

  id_end = id_offset + id_length;

  __CPROVER_assume(id_witness >= id_offset);
  __CPROVER_assume(id_witness < id_end);
  __CPROVER_assume(id_once[id_witness] != 0u);

  mlk_zeroize(&id_once[id_offset], id_length);

  mlk_zeroize(&id_twice[id_offset], id_length);
  mlk_zeroize(&id_twice[id_offset], id_length);

  for (i = 0u; i < ZERO_T3_HOST_BYTES; i++)
  {
    __CPROVER_assert(
        id_once[i] == id_twice[i],
        "ZERO-T3.P1: repeated zeroization is idempotent");
  }

  __CPROVER_assert(
      id_once[id_witness] == 0u &&
      id_twice[id_witness] == 0u,
      "ZERO-T3.NV1: idempotence comparison includes a wiped nonzero witness");

  /*
   * T3.P2 — Adjacent partition equivalence.
   */
  adj_offset = nondet_size_t();
  adj_length_1 = nondet_size_t();
  adj_length_2 = nondet_size_t();

  adj_witness_1 = nondet_size_t();
  adj_witness_2 = nondet_size_t();

  __CPROVER_assume(adj_offset < ZERO_T3_HOST_BYTES);

  __CPROVER_assume(adj_length_1 > 0u);
  __CPROVER_assume(
      adj_length_1 <= ZERO_T3_HOST_BYTES - adj_offset);

  __CPROVER_assume(adj_length_2 > 0u);
  __CPROVER_assume(
      adj_length_2 <=
      ZERO_T3_HOST_BYTES - adj_offset - adj_length_1);

  adj_boundary = adj_offset + adj_length_1;
  adj_total = adj_length_1 + adj_length_2;

  __CPROVER_assume(adj_witness_1 >= adj_offset);
  __CPROVER_assume(adj_witness_1 < adj_boundary);

  __CPROVER_assume(adj_witness_2 >= adj_boundary);
  __CPROVER_assume(adj_witness_2 < adj_offset + adj_total);

  __CPROVER_assume(adjacent_sequence[adj_witness_1] != 0u);
  __CPROVER_assume(adjacent_sequence[adj_witness_2] != 0u);

  mlk_zeroize(
      &adjacent_sequence[adj_offset],
      adj_length_1);

  mlk_zeroize(
      &adjacent_sequence[adj_boundary],
      adj_length_2);

  mlk_zeroize(
      &adjacent_union[adj_offset],
      adj_total);

  for (i = 0u; i < ZERO_T3_HOST_BYTES; i++)
  {
    __CPROVER_assert(
        adjacent_sequence[i] == adjacent_union[i],
        "ZERO-T3.P2: adjacent partitions equal their combined interval");
  }

  __CPROVER_assert(
      adjacent_sequence[adj_witness_1] == 0u &&
      adjacent_sequence[adj_witness_2] == 0u &&
      adjacent_union[adj_witness_1] == 0u &&
      adjacent_union[adj_witness_2] == 0u,
      "ZERO-T3.NV2: both adjacent nonzero partitions are genuinely wiped");

  /*
   * T3.P3 — Disjoint commutativity.
   */
  d1_offset = nondet_size_t();
  d1_length = nondet_size_t();
  d1_witness = nondet_size_t();

  d2_offset = nondet_size_t();
  d2_length = nondet_size_t();
  d2_witness = nondet_size_t();

  __CPROVER_assume(d1_offset < ZERO_T3_HOST_BYTES);
  __CPROVER_assume(d1_length > 0u);
  __CPROVER_assume(d1_length <= ZERO_T3_HOST_BYTES - d1_offset);

  __CPROVER_assume(d2_offset < ZERO_T3_HOST_BYTES);
  __CPROVER_assume(d2_length > 0u);
  __CPROVER_assume(d2_length <= ZERO_T3_HOST_BYTES - d2_offset);

  d1_end = d1_offset + d1_length;
  d2_end = d2_offset + d2_length;

  __CPROVER_assume(
      d1_end <= d2_offset ||
      d2_end <= d1_offset);

  __CPROVER_assume(d1_witness >= d1_offset);
  __CPROVER_assume(d1_witness < d1_end);

  __CPROVER_assume(d2_witness >= d2_offset);
  __CPROVER_assume(d2_witness < d2_end);

  __CPROVER_assume(disjoint_ab[d1_witness] != 0u);
  __CPROVER_assume(disjoint_ab[d2_witness] != 0u);

  mlk_zeroize(&disjoint_ab[d1_offset], d1_length);
  mlk_zeroize(&disjoint_ab[d2_offset], d2_length);

  mlk_zeroize(&disjoint_ba[d2_offset], d2_length);
  mlk_zeroize(&disjoint_ba[d1_offset], d1_length);

  for (i = 0u; i < ZERO_T3_HOST_BYTES; i++)
  {
    __CPROVER_assert(
        disjoint_ab[i] == disjoint_ba[i],
        "ZERO-T3.P3: disjoint zeroizations commute");
  }

  __CPROVER_assert(
      disjoint_ab[d1_witness] == 0u &&
      disjoint_ab[d2_witness] == 0u &&
      disjoint_ba[d1_witness] == 0u &&
      disjoint_ba[d2_witness] == 0u,
      "ZERO-T3.NV3: both disjoint nonzero intervals are genuinely wiped");

  /*
   * T3.P4 — Overlapping-union equivalence.
   */
  o1_offset = nondet_size_t();
  o1_length = nondet_size_t();
  o1_witness = nondet_size_t();

  o2_offset = nondet_size_t();
  o2_length = nondet_size_t();
  o2_witness = nondet_size_t();

  __CPROVER_assume(o1_offset < ZERO_T3_HOST_BYTES);
  __CPROVER_assume(o1_length > 0u);
  __CPROVER_assume(o1_length <= ZERO_T3_HOST_BYTES - o1_offset);

  __CPROVER_assume(o2_offset < ZERO_T3_HOST_BYTES);
  __CPROVER_assume(o2_length > 0u);
  __CPROVER_assume(o2_length <= ZERO_T3_HOST_BYTES - o2_offset);

  o1_end = o1_offset + o1_length;
  o2_end = o2_offset + o2_length;

  __CPROVER_assume(o1_offset < o2_end);
  __CPROVER_assume(o2_offset < o1_end);

  __CPROVER_assume(o1_witness >= o1_offset);
  __CPROVER_assume(o1_witness < o1_end);

  __CPROVER_assume(o2_witness >= o2_offset);
  __CPROVER_assume(o2_witness < o2_end);

  __CPROVER_assume(overlap_sequence[o1_witness] != 0u);
  __CPROVER_assume(overlap_sequence[o2_witness] != 0u);

  union_offset =
      o1_offset < o2_offset ? o1_offset : o2_offset;

  union_end =
      o1_end > o2_end ? o1_end : o2_end;

  union_length = union_end - union_offset;

  mlk_zeroize(&overlap_sequence[o1_offset], o1_length);
  mlk_zeroize(&overlap_sequence[o2_offset], o2_length);

  mlk_zeroize(&overlap_union[union_offset], union_length);

  for (i = 0u; i < ZERO_T3_HOST_BYTES; i++)
  {
    __CPROVER_assert(
        overlap_sequence[i] == overlap_union[i],
        "ZERO-T3.P4: overlapping intervals equal zeroization of their union");
  }

  __CPROVER_assert(
      overlap_sequence[o1_witness] == 0u &&
      overlap_sequence[o2_witness] == 0u &&
      overlap_union[o1_witness] == 0u &&
      overlap_union[o2_witness] == 0u,
      "ZERO-T3.NV4: overlapping nonzero intervals are genuinely wiped");
}
