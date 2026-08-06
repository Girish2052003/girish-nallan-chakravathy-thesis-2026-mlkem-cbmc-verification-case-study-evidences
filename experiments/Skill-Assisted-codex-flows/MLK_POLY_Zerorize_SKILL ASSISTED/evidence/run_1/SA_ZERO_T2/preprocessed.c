typedef long int ptrdiff_t;
typedef long unsigned int size_t;
typedef int wchar_t;
typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;
typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;
typedef signed long int __int64_t;
typedef unsigned long int __uint64_t;
typedef __int8_t __int_least8_t;
typedef __uint8_t __uint_least8_t;
typedef __int16_t __int_least16_t;
typedef __uint16_t __uint_least16_t;
typedef __int32_t __int_least32_t;
typedef __uint32_t __uint_least32_t;
typedef __int64_t __int_least64_t;
typedef __uint64_t __uint_least64_t;
typedef long int __quad_t;
typedef unsigned long int __u_quad_t;
typedef long int __intmax_t;
typedef unsigned long int __uintmax_t;
typedef unsigned long int __dev_t;
typedef unsigned int __uid_t;
typedef unsigned int __gid_t;
typedef unsigned long int __ino_t;
typedef unsigned long int __ino64_t;
typedef unsigned int __mode_t;
typedef unsigned long int __nlink_t;
typedef long int __off_t;
typedef long int __off64_t;
typedef int __pid_t;
typedef struct { int __val[2]; } __fsid_t;
typedef long int __clock_t;
typedef unsigned long int __rlim_t;
typedef unsigned long int __rlim64_t;
typedef unsigned int __id_t;
typedef long int __time_t;
typedef unsigned int __useconds_t;
typedef long int __suseconds_t;
typedef long int __suseconds64_t;
typedef int __daddr_t;
typedef int __key_t;
typedef int __clockid_t;
typedef void * __timer_t;
typedef long int __blksize_t;
typedef long int __blkcnt_t;
typedef long int __blkcnt64_t;
typedef unsigned long int __fsblkcnt_t;
typedef unsigned long int __fsblkcnt64_t;
typedef unsigned long int __fsfilcnt_t;
typedef unsigned long int __fsfilcnt64_t;
typedef long int __fsword_t;
typedef long int __ssize_t;
typedef long int __syscall_slong_t;
typedef unsigned long int __syscall_ulong_t;
typedef __off64_t __loff_t;
typedef char *__caddr_t;
typedef long int __intptr_t;
typedef unsigned int __socklen_t;
typedef int __sig_atomic_t;
typedef __int8_t int8_t;
typedef __int16_t int16_t;
typedef __int32_t int32_t;
typedef __int64_t int64_t;
typedef __uint8_t uint8_t;
typedef __uint16_t uint16_t;
typedef __uint32_t uint32_t;
typedef __uint64_t uint64_t;
typedef __int_least8_t int_least8_t;
typedef __int_least16_t int_least16_t;
typedef __int_least32_t int_least32_t;
typedef __int_least64_t int_least64_t;
typedef __uint_least8_t uint_least8_t;
typedef __uint_least16_t uint_least16_t;
typedef __uint_least32_t uint_least32_t;
typedef __uint_least64_t uint_least64_t;
typedef signed char int_fast8_t;
typedef long int int_fast16_t;
typedef long int int_fast32_t;
typedef long int int_fast64_t;
typedef unsigned char uint_fast8_t;
typedef unsigned long int uint_fast16_t;
typedef unsigned long int uint_fast32_t;
typedef unsigned long int uint_fast64_t;
typedef long int intptr_t;
typedef unsigned long int uintptr_t;
typedef __intmax_t intmax_t;
typedef __uintmax_t uintmax_t;
typedef enum
{
  MLK_SYS_CAP_AVX2,
  MLK_SYS_CAP_SHA3,
  MLK_SYS_CAP_MVE
} mlk_sys_cap;
__attribute__((warn_unused_result))
static __attribute__((unused)) int mlk_sys_check_capability(mlk_sys_cap cap)

{
  (void)cap;
  return 1;
}

extern void *memcpy (void *__restrict __dest, const void *__restrict __src,
       size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern void *memmove (void *__dest, const void *__src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern void *memset (void *__s, int __c, size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
extern int memcmp (const void *__s1, const void *__s2, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int __memcmpeq (const void *__s1, const void *__s2, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern void *memchr (const void *__s, int __c, size_t __n)
      __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern char *strcpy (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strncpy (char *__restrict __dest,
        const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strcat (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strncat (char *__restrict __dest, const char *__restrict __src,
        size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strcmp (const char *__s1, const char *__s2)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strncmp (const char *__s1, const char *__s2, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strcoll (const char *__s1, const char *__s2)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern size_t strxfrm (char *__restrict __dest,
         const char *__restrict __src, size_t __n)
    __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2))) __attribute__ ((__access__ (__write_only__, 1, 3)));
extern char *strchr (const char *__s, int __c)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern char *strrchr (const char *__s, int __c)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern size_t strcspn (const char *__s, const char *__reject)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern size_t strspn (const char *__s, const char *__accept)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strpbrk (const char *__s, const char *__accept)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strstr (const char *__haystack, const char *__needle)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strtok (char *__restrict __s, const char *__restrict __delim)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
extern char *__strtok_r (char *__restrict __s,
    const char *__restrict __delim,
    char **__restrict __save_ptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));
extern size_t strlen (const char *__s)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern char *strerror (int __errnum) __attribute__ ((__nothrow__ , __leaf__));

static __attribute__((unused)) uint32_t mlk_value_barrier_u32(uint32_t b)

{
  __asm__ volatile("" : "+r"(b));
  return b;
}
static __attribute__((unused)) int32_t mlk_value_barrier_i32(int32_t b)

{
  __asm__ volatile("" : "+r"(b));
  return b;
}
static __attribute__((unused)) uint8_t mlk_value_barrier_u8(uint8_t b)

{
  __asm__ volatile("" : "+r"(b));
  return b;
}
static __attribute__((unused)) int16_t mlk_cast_uint16_to_int16(uint16_t x)
{
  return (int16_t)x;
}
static __attribute__((unused)) uint16_t mlk_cast_int32_to_uint16(int32_t x)
{
  return (uint16_t)(x & (int32_t)(65535));
}
static __attribute__((unused)) uint16_t mlk_cast_int16_to_uint16(int32_t x)
{
  return mlk_cast_int32_to_uint16(x);
}
static __attribute__((unused)) uint16_t mlk_ct_cmask_neg_i16(int16_t x)

{
  int32_t tmp = mlk_value_barrier_i32((int32_t)x);
  tmp >>= 16;
  return mlk_cast_int32_to_uint16(tmp);
}
static __attribute__((unused)) uint16_t mlk_ct_cmask_nonzero_u16(uint16_t x)

{
  int32_t tmp = mlk_value_barrier_i32(-((int32_t)x));
  tmp >>= 16;
  return mlk_cast_int32_to_uint16(tmp);
}
static __attribute__((unused)) uint8_t mlk_ct_cmask_nonzero_u8(uint8_t x)

{
  uint16_t mask = mlk_ct_cmask_nonzero_u16((uint16_t)x);
  return (uint8_t)(mask & 0xFF);
}
static __attribute__((unused)) int16_t mlk_ct_sel_int16(int16_t a, int16_t b, uint16_t cond)

{
  uint16_t au = mlk_cast_int16_to_uint16(a);
  uint16_t bu = mlk_cast_int16_to_uint16(b);
  uint16_t res = bu ^ (mlk_ct_cmask_nonzero_u16(cond) & (au ^ bu));
  return mlk_cast_uint16_to_int16(res);
}
static __attribute__((unused)) uint8_t mlk_ct_sel_uint8(uint8_t a, uint8_t b, uint8_t cond)

{
  return b ^ (mlk_ct_cmask_nonzero_u8(cond) & (a ^ b));
}
static __attribute__((unused)) uint8_t mlk_ct_memcmp(const uint8_t *a, const uint8_t *b,
                                        const size_t len)

{
  uint8_t r = 0, s = 0;
  unsigned i;
  for (i = 0; i < len; i++)
 
  {
    r |= a[i] ^ b[i];
    s ^= a[i] ^ b[i];
  }
  return (mlk_value_barrier_u8(mlk_ct_cmask_nonzero_u8(r) ^ s) ^ s);
}
static __attribute__((unused)) void mlk_ct_cmov_zero(uint8_t *r, const uint8_t *x,
                                        size_t len, uint8_t b)

{
  size_t i;
  for (i = 0; i < len; i++)
 
  {
    r[i] = mlk_ct_sel_uint8(r[i], x[i], b);
  }
}
static __attribute__((unused)) void mlk_zeroize(void *ptr, size_t len)

{
  memset(ptr, 0, len);
  __asm__ volatile("" : : "r"(ptr) : "memory");
}
static uint8_t nondet_u8(void) { uint8_t x; return x; }
static size_t nondet_size(void) { size_t x; return x; }
int main(void)
{
  uint8_t host[16U];
  uint8_t original[16U];
  uint8_t before_second[16U];
  size_t outer_offset;
  size_t outer_length;
  size_t outer_end;
  size_t relative_offset;
  size_t repair_length;
  size_t repair_start;
  size_t repair_end;
  unsigned i;
  unsigned target_calls;
  int assumptions_feasible;
  int initial_nonzero;
  int target_1_reached;
  int recontamination_reached;
  int recontamination_nonzero;
  int target_2_reached;
  int assertion_block_reached;
  outer_offset = nondet_size();
  outer_length = nondet_size();
  relative_offset = nondet_size();
  repair_length = nondet_size();
  __CPROVER_assume(outer_offset < 16U);
  __CPROVER_assume(outer_length >= 1U);
  __CPROVER_assume(outer_length <= 16U - outer_offset);
  __CPROVER_assume(relative_offset < outer_length);
  __CPROVER_assume(repair_length >= 1U);
  __CPROVER_assume(repair_length <= outer_length - relative_offset);
  outer_end = outer_offset + outer_length;
  repair_start = outer_offset + relative_offset;
  repair_end = repair_start + repair_length;
  for (i = 0U; i < 16U; i++)
  {
    host[i] = nondet_u8();
    original[i] = host[i];
  }
  __CPROVER_assume(host[outer_offset] != 0U);
  target_calls = 0U;
  assumptions_feasible = 1;
  initial_nonzero = (host[outer_offset] != 0U);
  target_1_reached = 0;
  recontamination_reached = 0;
  recontamination_nonzero = 0;
  target_2_reached = 0;
  assertion_block_reached = 0;
  ((void)(assumptions_feasible));
  ((void)(initial_nonzero));
  mlk_zeroize(host + outer_offset, outer_length);
  target_calls++;
  target_1_reached = (target_calls == 1U);
  ((void)(target_1_reached));
  __CPROVER_assert(host[outer_offset] == 0U, "SA_ZERO_T2_FIRST_ERASURE_WITNESS_ZERO");
  for (i = 0U; i < 16U; i++)
    if (((size_t)i >= repair_start) && ((size_t)i < repair_end))
      host[i] = nondet_u8();
  __CPROVER_assume(host[repair_start] != 0U);
  recontamination_reached = 1;
  recontamination_nonzero = (host[repair_start] != 0U);
  ((void)(recontamination_reached));
  ((void)(recontamination_nonzero));
  for (i = 0U; i < 16U; i++)
    before_second[i] = host[i];
  mlk_zeroize(host + repair_start, repair_length);
  target_calls++;
  target_2_reached = (target_calls == 2U);
  ((void)(target_2_reached));
  assertion_block_reached = 1;
  ((void)(assertion_block_reached));
  __CPROVER_assert(target_calls == 2U, "SA_ZERO_T2_TARGET_CALL_COUNT");
  for (i = 0U; i < 16U; i++)
  {
    if (((size_t)i >= outer_offset) && ((size_t)i < outer_end))
      __CPROVER_assert(host[i] == 0U, "SA_ZERO_T2_OUTER_INTERVAL_FULL_RECOVERY");
    else
      __CPROVER_assert(host[i] == original[i], "SA_ZERO_T2_ORIGINAL_OUTER_FRAME_PRESERVED");
    if (((size_t)i < repair_start) || ((size_t)i >= repair_end))
      __CPROVER_assert(host[i] == before_second[i], "SA_ZERO_T2_SECOND_CALL_FRAME_PRESERVED");
  }
  __CPROVER_assert(before_second[repair_start] != 0U, "SA_ZERO_T2_RECONTAMINATION_WITNESS_WAS_NONZERO");
  __CPROVER_assert(host[repair_start] == 0U, "SA_ZERO_T2_RECONTAMINATION_WITNESS_REERASED");
  return 0;
}
