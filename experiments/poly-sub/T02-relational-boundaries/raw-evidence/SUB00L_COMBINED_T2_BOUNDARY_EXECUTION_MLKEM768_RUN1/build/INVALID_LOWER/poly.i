typedef long int ptrdiff_t;
typedef long unsigned int size_t;
typedef int wchar_t;
static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;
  __CPROVER_assert(
      0,
      "SUB00E_R1_ADAPTER: mlk_zeroize must be unreachable from the selected harness");
}
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
  MLK_SYS_CAP_SHA3
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

extern volatile uint64_t mlk_sub00l_low_ct_opt_blocker_u64;
static __attribute__((unused)) uint64_t mlk_ct_get_optblocker_u64(void)
 { return mlk_sub00l_low_ct_opt_blocker_u64; }
static __attribute__((unused)) uint8_t mlk_ct_get_optblocker_u8(void)
 { return (uint8_t)mlk_ct_get_optblocker_u64(); }
static __attribute__((unused)) uint32_t mlk_ct_get_optblocker_u32(void)
 { return (uint32_t)mlk_ct_get_optblocker_u64(); }
static __attribute__((unused)) int32_t mlk_ct_get_optblocker_i32(void)
 { return (int32_t)mlk_ct_get_optblocker_u64(); }
static __attribute__((unused)) uint32_t mlk_value_barrier_u32(uint32_t b)
 { return (b ^ mlk_ct_get_optblocker_u32()); }
static __attribute__((unused)) int32_t mlk_value_barrier_i32(int32_t b)
 { return (b ^ mlk_ct_get_optblocker_i32()); }
static __attribute__((unused)) uint8_t mlk_value_barrier_u8(uint8_t b)
 { return (b ^ mlk_ct_get_optblocker_u8()); }
#pragma CPROVER check push
#pragma CPROVER check disable "conversion"
static __attribute__((unused)) int16_t mlk_cast_uint16_to_int16(uint16_t x)
{
  return (int16_t)x;
}
#pragma CPROVER check pop
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
typedef struct
{
  int16_t coeffs[256];
} __attribute__((aligned(32))) mlk_poly;
typedef struct
{
  int16_t coeffs[256 >> 1];
} __attribute__((aligned(32))) mlk_poly_mulcache;
static __attribute__((unused)) int16_t mlk_montgomery_reduce(int32_t a)

{
  const uint32_t QINV = 62209;
  const uint16_t a_reduced = mlk_cast_int32_to_uint16(a);
  const uint16_t a_inverted = (a_reduced * QINV) & (65535);
  const int16_t t = mlk_cast_uint16_to_int16(a_inverted);
  int32_t r;
  do { } while (0);
  r = a - ((int32_t)t * 3329);
  r = r >> 16;
  return (int16_t)r;
}

void mlk_sub00l_low_poly_tomont(mlk_poly *r)
;

void mlk_sub00l_low_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
;

void mlk_sub00l_low_poly_reduce(mlk_poly *r)
;

void mlk_sub00l_low_poly_add(mlk_poly *r, const mlk_poly *b)
;

void mlk_sub00l_low_poly_sub(mlk_poly *r, const mlk_poly *b)
;

void mlk_sub00l_low_poly_ntt(mlk_poly *r)
;

void mlk_sub00l_low_poly_invntt_tomont(mlk_poly *r)
;

void mlk_sub00l_low_poly_cbd2(mlk_poly *r, const uint8_t buf[2 * 256 / 4]);

void mlk_sub00l_low_poly_rej_uniform_x4(mlk_poly *vec0, mlk_poly *vec1, mlk_poly *vec2,
                             mlk_poly *vec3,
                             uint8_t seed[4][((((32 + 2) + (32 - 1)) / 32) * 32)])
;

void mlk_sub00l_low_poly_rej_uniform(mlk_poly *entry, uint8_t seed[32 + 2])
;
typedef struct
{
  uint64_t ctx[25];
} __attribute__((aligned(32))) mlk_shake128ctx;
void mlk_sub00l_low_shake128_absorb_once(mlk_shake128ctx *state, const uint8_t *input,
                              size_t inlen)
;
void mlk_sub00l_low_shake128_squeezeblocks(uint8_t *output, size_t nblocks,
                                mlk_shake128ctx *state)
;
void mlk_sub00l_low_shake128_init(mlk_shake128ctx *state);
void mlk_sub00l_low_shake128_release(mlk_shake128ctx *state);
void mlk_sub00l_low_shake256(uint8_t *output, size_t outlen, const uint8_t *input,
                  size_t inlen)
;
void mlk_sub00l_low_sha3_256(uint8_t *output, const uint8_t *input, size_t inlen)
;
void mlk_sub00l_low_sha3_512(uint8_t *output, const uint8_t *input, size_t inlen)
;
void mlk_sub00l_low_keccakf1600_extract_bytes(uint64_t *state, unsigned char *data,
                                   unsigned offset, unsigned length)
;
void mlk_sub00l_low_keccakf1600_xor_bytes(uint64_t *state, const unsigned char *data,
                               unsigned offset, unsigned length)
;
void mlk_sub00l_low_keccakf1600x4_extract_bytes(uint64_t *state, unsigned char *data0,
                                     unsigned char *data1, unsigned char *data2,
                                     unsigned char *data3, unsigned offset,
                                     unsigned length)
;
void mlk_sub00l_low_keccakf1600x4_xor_bytes(uint64_t *state, const unsigned char *data0,
                                 const unsigned char *data1,
                                 const unsigned char *data2,
                                 const unsigned char *data3, unsigned offset,
                                 unsigned length)
;
void mlk_sub00l_low_keccakf1600x4_permute(uint64_t *state)
;
void mlk_sub00l_low_keccakf1600_permute(uint64_t *state)
;
typedef struct
{
  uint64_t ctx[25 *
               4];
} __attribute__((aligned(32))) mlk_shake128x4ctx;
void mlk_sub00l_low_shake128x4_absorb_once(mlk_shake128x4ctx *state, const uint8_t *in0,
                                const uint8_t *in1, const uint8_t *in2,
                                const uint8_t *in3, size_t inlen)
;
void mlk_sub00l_low_shake128x4_squeezeblocks(uint8_t *out0, uint8_t *out1, uint8_t *out2,
                                  uint8_t *out3, size_t nblocks,
                                  mlk_shake128x4ctx *state)
;
void mlk_sub00l_low_shake128x4_init(mlk_shake128x4ctx *state);
void mlk_sub00l_low_shake128x4_release(mlk_shake128x4ctx *state);
void mlk_sub00l_low_shake256x4(uint8_t *out0, uint8_t *out1, uint8_t *out2, uint8_t *out3,
                    size_t outlen, const uint8_t *in0, const uint8_t *in1,
                    const uint8_t *in2, const uint8_t *in3, size_t inlen)
;
static __attribute__((unused)) int16_t mlk_fqmul(int16_t a, int16_t b)

{
  int16_t res;
  do { } while (0);
  res = mlk_montgomery_reduce((int32_t)a * (int32_t)b);
  do { } while (0);
  return res;
}
static __attribute__((unused)) int16_t mlk_barrett_reduce(int16_t a)

{
  const int32_t magic = 20159;
  const int32_t t = (magic * a + ((int32_t)1 << 25)) >> 26;
  int16_t res = (int16_t)(a - t * 3329);
  do { } while (0);
  return res;
}
static void mlk_poly_tomont_c(mlk_poly *r)

{
  unsigned i;
  const int16_t f = 1353;
  for (i = 0; i < 256; i++)
 
  {
    r->coeffs[i] = mlk_fqmul(r->coeffs[i], f);
  }
  do { } while (0);
}

void mlk_sub00l_low_poly_tomont(mlk_poly *r)
{
  mlk_poly_tomont_c(r);
}
static __attribute__((unused)) int16_t mlk_scalar_signed_to_unsigned_q(int16_t c)

{
  do { } while (0);
  c = mlk_ct_sel_int16((int16_t)(c + 3329), c, mlk_ct_cmask_neg_i16(c));
  do { } while (0);
  return c;
}
static void mlk_poly_reduce_c(mlk_poly *r)

{
  unsigned i;
  for (i = 0; i < 256; i++)
 
  {
    int16_t t = mlk_barrett_reduce(r->coeffs[i]);
    r->coeffs[i] = mlk_scalar_signed_to_unsigned_q(t);
  }
  do { } while (0);
}

void mlk_sub00l_low_poly_reduce(mlk_poly *r)
{
  mlk_poly_reduce_c(r);
}

void mlk_sub00l_low_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < 256; i++)
 
  {
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}

void mlk_sub00l_low_poly_sub(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < 256; i++)
 
  {
    r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }
}
static __attribute__((aligned(32))) const int16_t mlk_zetas[128] = {
    -1044, -758, -359, -1517, 1493, 1422, 287, 202, -171, 622, 1577,
    182, 962, -1202, -1474, 1468, 573, -1325, 264, 383, -829, 1458,
    -1602, -130, -681, 1017, 732, 608, -1542, 411, -205, -1571, 1223,
    652, -552, 1015, -1293, 1491, -282, -1544, 516, -8, -320, -666,
    -1618, -1162, 126, 1469, -853, -90, -271, 830, 107, -1421, -247,
    -951, -398, 961, -1508, -725, 448, -1065, 677, -1275, -1103, 430,
    555, 843, -1251, 871, 1550, 105, 422, 587, 177, -235, -291,
    -460, 1574, 1653, -246, 778, 1159, -147, -777, 1483, -602, 1119,
    -1590, 644, -872, 349, 418, 329, -156, -75, 817, 1097, 603,
    610, 1322, -1285, -1465, 384, -1215, -136, 1218, -1335, -874, 220,
    -1187, -1659, -1185, -1530, -1278, 794, -1510, -854, -870, 478, -108,
    -308, 996, 991, 958, -1460, 1522, 1628,
};
static void mlk_poly_mulcache_compute_c(mlk_poly_mulcache *x,
                                                     const mlk_poly *a)

{
  unsigned i;
  for (i = 0; i < 256 / 4; i++)
 
  {
    x->coeffs[2 * i + 0] = mlk_fqmul(a->coeffs[4 * i + 1], mlk_zetas[64 + i]);
    x->coeffs[2 * i + 1] =
        mlk_fqmul(a->coeffs[4 * i + 3], (int16_t)(-mlk_zetas[64 + i]));
  }
  do { } while (0);
}

void mlk_sub00l_low_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
{
  mlk_poly_mulcache_compute_c(x, a);
}
static void mlk_ntt_butterfly_block(int16_t r[256], int16_t zeta,
                                    unsigned start, unsigned len,
                                    unsigned bound)

{
  unsigned j;
  ((void)bound);
  for (j = start; j < start + len; j++)
 
  {
    int16_t t;
    t = mlk_fqmul(r[j + len], zeta);
    r[j + len] = (int16_t)(r[j] - t);
    r[j] = (int16_t)(r[j] + t);
  }
}
static void mlk_ntt_layer(int16_t r[256], unsigned layer)

{
  unsigned start, k, len;
  k = 1u << (layer - 1);
  len = (unsigned)256 >> layer;
  for (start = 0; start < 256; start += 2 * len)
 
  {
    int16_t zeta = mlk_zetas[k++];
    mlk_ntt_butterfly_block(r, zeta, start, len, layer * 3329);
  }
}
static void mlk_poly_ntt_c(mlk_poly *p)

{
  unsigned layer;
  int16_t *r;
  do { } while (0);
  r = p->coeffs;
  for (layer = 1; layer <= 7; layer++)
 
  {
    mlk_ntt_layer(r, layer);
  }
  do { } while (0);
}

void mlk_sub00l_low_poly_ntt(mlk_poly *r)
{
  mlk_poly_ntt_c(r);
}
static void mlk_invntt_layer(int16_t *r, unsigned layer)

{
  unsigned start, k, len;
  len = (unsigned)256 >> layer;
  k = (1u << layer) - 1;
  for (start = 0; start < 256; start += 2 * len)
 
  {
    unsigned j;
    int16_t zeta = mlk_zetas[k--];
    for (j = start; j < start + len; j++)
   
    {
      int16_t t = r[j];
      r[j] = mlk_barrett_reduce((int16_t)(t + r[j + len]));
      r[j + len] = (int16_t)(r[j + len] - t);
      r[j + len] = mlk_fqmul(r[j + len], zeta);
    }
  }
}
static void mlk_poly_invntt_tomont_c(mlk_poly *p)

{
  unsigned j, layer;
  const int16_t f = 1441;
  int16_t *r = p->coeffs;
  for (j = 0; j < 256; j++)
 
  {
    r[j] = mlk_fqmul(r[j], f);
  }
  for (layer = 7; layer > 0; layer--)
 
  {
    mlk_invntt_layer(r, layer);
  }
  do { } while (0);
}

void mlk_sub00l_low_poly_invntt_tomont(mlk_poly *r)
{
  mlk_poly_invntt_tomont_c(r);
}
