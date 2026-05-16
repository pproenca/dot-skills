---
title: Use The Standard-Library Sort, Not A Hand-Rolled One
impact: HIGH
impactDescription: prevents O(n²) bugs and ~3-10x slower implementations
tags: srch, sorting, stdlib, timsort
---

## Use The Standard-Library Sort, Not A Hand-Rolled One

Production-grade sort algorithms (Timsort in Python/Java, introsort in C++ STL, pdqsort in Rust) are O(n log n) worst case, branch-predictor friendly, cache-aware, and stable where promised. They also exploit existing order in real-world inputs (Timsort runs in O(n) on already-sorted data). A hand-rolled quicksort tutorial implementation is at least 3-10x slower in practice, and naive pivot choices give O(n²) on adversarial inputs.

The stdlib sort is also where you set the comparator/key — never reach for sort by reimplementing it.

**Incorrect (hand-rolled quicksort with leftmost pivot — O(n²) on sorted input):**

```python
def quicksort(a):
    # Leftmost pivot on already-sorted data degrades to O(n²).
    # Plus: function call overhead and slice allocation per recursion.
    if len(a) <= 1:
        return a
    pivot = a[0]
    return quicksort([x for x in a[1:] if x < pivot]) + [pivot] + \
           quicksort([x for x in a[1:] if x >= pivot])
```

**Correct (stdlib sort with a key):**

```python
def sort_users_by_signup_then_email(users):
    # Timsort: O(n log n) worst case, O(n) on sorted/nearly-sorted input.
    # `key=` avoids re-computing the tuple per comparison.
    return sorted(users, key=lambda u: (u.signup_at, u.email))
```

**When to hand-roll:**

- You need a non-comparison sort: counting sort, radix sort, bucket sort for integer-valued keys in a known range can beat O(n log n). For n = 10⁸ integers in [0, 10⁶], radix sort is ~5x faster than Timsort.
- You're sorting in a constrained environment (embedded, no stdlib).
- The data is so structured that a one-pass merge / k-way merge beats general sort.

**Language equivalents:**

- Python: `sorted(it, key=...)`, `list.sort(key=...)` (Timsort, stable)
- C++: `std::sort` (introsort, not stable), `std::stable_sort`
- Java: `Arrays.sort` (Dual-Pivot Quicksort for primitives, Timsort for objects)
- Rust: `slice.sort()` (Timsort, stable), `slice.sort_unstable()` (pdqsort)

Reference: [Wikipedia — Timsort](https://en.wikipedia.org/wiki/Timsort)
