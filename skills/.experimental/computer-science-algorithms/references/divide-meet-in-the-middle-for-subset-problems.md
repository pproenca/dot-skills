---
title: Use Meet-In-The-Middle When 2ⁿ Is Too Big But 2^(n/2) Fits
impact: MEDIUM
impactDescription: O(2ⁿ) to O(2^(n/2) · n) — n = 40 becomes feasible
tags: divide, meet-in-the-middle, subset-sum, exponential
---

## Use Meet-In-The-Middle When 2ⁿ Is Too Big But 2^(n/2) Fits

For NP-hard problems where bitmask DP is too expensive (n > ~20) but the search is naturally exponential, **meet-in-the-middle** halves the exponent: split the input into two halves of n/2 each, enumerate the 2^(n/2) subsets of each, then combine them via sort + binary search or hash table in O(2^(n/2) · n) time. This makes n = 40 routinely solvable where n = 20 was the ceiling.

Canonical use cases: subset sum on large weights (cannot use O(n·W) DP because W is huge), knapsack with n ≤ 40, finding a tuple of k elements that sum to a target.

**Incorrect (full 2ⁿ subset enumeration — n = 40 means 10¹² subsets):**

```python
def has_subset_with_sum(arr: list[int], target: int) -> bool:
    # 2ⁿ subsets. For n = 40 this is 10¹² — infeasible.
    n = len(arr)
    for mask in range(1 << n):
        s = sum(arr[i] for i in range(n) if mask >> i & 1)
        if s == target:
            return True
    return False
```

**Correct (meet in the middle — 2^(n/2) work per side, then combine):**

```python
def has_subset_with_sum(arr: list[int], target: int) -> bool:
    n = len(arr)
    half = n // 2
    left, right = arr[:half], arr[half:]

    def subset_sums(part: list[int]) -> list[int]:
        sums = [0]
        for x in part:
            sums += [s + x for s in sums]
        return sums

    left_sums = subset_sums(left)            # 2^(n/2) values
    right_sums = sorted(subset_sums(right))  # 2^(n/2) values, sorted
    # For each left sum L, search for `target - L` in right_sums via binary search.
    from bisect import bisect_left
    for L in left_sums:
        idx = bisect_left(right_sums, target - L)
        if idx < len(right_sums) and right_sums[idx] == target - L:
            return True
    return False
```

**Memory cost:** 2^(n/2) entries per side. At n = 40 that's ~10⁶ per side — fine. At n = 50, 2²⁵ ≈ 3·10⁷ per side, ~250 MB combined. Push further only if entries are small (e.g. 32-bit ints).

**Variants:**

- Find the closest subset sum to target → keep both halves sorted, two-pointer sweep
- Knapsack with values → store `(weight, max_value)` per side and prune dominated entries

Reference: [USACO Guide — Meet in the Middle](https://usaco.guide/gold/meet-in-the-middle)
