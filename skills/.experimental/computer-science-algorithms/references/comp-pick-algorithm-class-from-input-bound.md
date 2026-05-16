---
title: Pick Algorithm Class From The Input Bound, Not From Familiarity
impact: CRITICAL
impactDescription: O(n²) → O(n log n) or better — orders of magnitude on n ≥ 10⁴
tags: comp, complexity, algorithm-selection, big-o
---

## Pick Algorithm Class From The Input Bound, Not From Familiarity

The largest performance wins come from matching the algorithm's asymptotic class to the input size *before* writing code. A rough rule of thumb for a 1-second budget on commodity hardware: O(n²) is fine up to n ≈ 10⁴, O(n log n) up to n ≈ 10⁶, O(n) up to n ≈ 10⁸. Writing a nested-loop solution when n is 10⁶ produces 10¹² operations — no constant-factor or language optimization recovers that.

Decide the target class from the bound first, then pick a concrete algorithm in that class.

**Incorrect (nested loop on a 10⁶ input — will time out):**

```python
def has_duplicate(nums: list[int]) -> bool:
    # O(n²) — for n = 10⁶ this is 10¹² comparisons
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] == nums[j]:
                return True
    return False
```

**Correct (O(n) via hash set, chosen because n is large):**

```python
def has_duplicate(nums: list[int]) -> bool:
    # O(n) average — single pass with a hash set
    seen: set[int] = set()
    for x in nums:
        if x in seen:
            return True
        seen.add(x)
    return False
```

**When to stay with O(n²):**

- n is provably small and bounded (e.g. ≤ 100)
- Constant factors of the O(n²) solution are dramatically lower (cache-friendly contiguous scan) AND inputs are tiny
- The O(n log n) / O(n) variant requires data structures with worse cache behavior on your actual size

Reference: [Competitive Programmer's Handbook — Time complexity](https://cses.fi/book/book.pdf)
