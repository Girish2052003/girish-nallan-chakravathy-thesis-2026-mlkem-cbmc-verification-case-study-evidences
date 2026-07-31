# MONT-T2A.P3 Compositional Completion

## Original locked theorem

For arbitrary independent inputs a and b in the full source-contract domain:

    (R * (reduce(b) - reduce(a)) - (b - a)) is divisible by q.

Equivalently:

    R * (reduce(b) - reduce(a)) ≡ b - a (mod q).

## Proof architecture

1. Prove universally for one arbitrary full-domain input x that the production
   implementation satisfies the exact decomposition

       R * reduce(x) + q * t(x) = x,

   where t(x) is reconstructed independently from the frozen Montgomery
   inverse constant and the canonical low 16-bit word.

2. Instantiate that universally proved implementation lemma for independent
   arbitrary full-domain a and b.

3. Prove the exact relational identity

       R * (reduce(b) - reduce(a)) - (b - a)
           = q * (t(a) - t(b)).

The right-hand side is an explicit integer multiple of q, so this proves the
original locked arbitrary-pair congruence. No input-domain restriction, sign
partition, strengthened assumption, T1 substitution, or theorem deletion is
used.
