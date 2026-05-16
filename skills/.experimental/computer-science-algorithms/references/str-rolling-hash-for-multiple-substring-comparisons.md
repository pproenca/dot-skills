---
title: Use Rolling Hashes For Many Substring Comparisons
impact: MEDIUM
impactDescription: O(m) per equality check to O(1) — enables O(n) algorithms for hard string problems
tags: str, rolling-hash, rabin-karp, polynomial-hash
---

## Use Rolling Hashes For Many Substring Comparisons

If you compare many same-length substrings of a string for equality, a polynomial hash (Rabin-Karp style) precomputes prefix hashes in O(n) and answers "is `s[i..i+m]` equal to `s[j..j+m]`?" in O(1) per query. This unlocks linear algorithms for problems where DP and direct comparison would be O(n·m): longest common substring, longest palindromic substring (Manacher is better, but rolling hash is simpler), comparing many overlapping windows.

Two practical cautions: **(1) use two independent hashes** (two different bases or two different moduli) — single-hash collisions are common enough to fail random adversarial test cases. **(2) Pick moduli ≥ 10⁹** for cryptographic-style safety from accidental collisions; mod 1e9+7 alone is OK for non-adversarial inputs.

**Incorrect (direct comparison inside a loop — O(n·m)):**

```python
def count_equal_substring_pairs(s: str, m: int) -> int:
    # All same-length substrings. Compare every pair → O(n²·m).
    n = len(s)
    return sum(
        1
        for i in range(n - m + 1)
        for j in range(i + 1, n - m + 1)
        if s[i:i+m] == s[j:j+m]
    )
```

**Correct (rolling hash — O(n) preprocessing, O(1) per check):**

```python
def count_equal_substring_pairs(s: str, m: int) -> int:
    # Two independent hashes to avoid collisions.
    MOD1, BASE1 = (10**9 + 7, 131)
    MOD2, BASE2 = (10**9 + 9, 137)
    n = len(s)
    h1 = [0]*(n+1); p1 = [1]*(n+1)
    h2 = [0]*(n+1); p2 = [1]*(n+1)
    for i, c in enumerate(s):
        v = ord(c)
        h1[i+1] = (h1[i]*BASE1 + v) % MOD1; p1[i+1] = p1[i]*BASE1 % MOD1
        h2[i+1] = (h2[i]*BASE2 + v) % MOD2; p2[i+1] = p2[i]*BASE2 % MOD2

    def get(h, p, mod, lo, hi):  # hash of s[lo:hi]
        return (h[hi] - h[lo]*p[hi-lo]) % mod

    from collections import Counter
    buckets: Counter[tuple[int, int]] = Counter()
    for i in range(n - m + 1):
        key = (get(h1, p1, MOD1, i, i+m), get(h2, p2, MOD2, i, i+m))
        buckets[key] += 1
    return sum(c * (c - 1) // 2 for c in buckets.values())
```

**Birthday-paradox warning:** with a single mod-1e9+7 hash and 10⁴ comparisons, collision probability is ~10⁻⁵ — fine for non-adversarial inputs, fatal for competitive-programming judges. Always double-hash.

**Use rolling hash for:** longest common substring of two strings, finding all distinct substrings (count distinct hashes), pattern matching with wildcards, and "Z-function via rolling hash."

Reference: [cp-algorithms — String hashing](https://cp-algorithms.com/string/string-hashing.html)
