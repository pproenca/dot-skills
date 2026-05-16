---
title: Avoid Linear `in` Checks Inside Loops
impact: CRITICAL
impactDescription: O(n²) to O(n) — common 100-1000x speedup
tags: comp, membership, set, hash-table
---

## Avoid Linear `in` Checks Inside Loops

A `value in some_list` check is O(n). When that check sits inside a loop over n items, the whole structure is O(n²) — and it's invisible because each line *looks* like a single operation. This is the most common accidental quadratic algorithm in code review, and it scales catastrophically: at n = 10⁴ it's tolerable, at n = 10⁵ it's a 10-second pause, at n = 10⁶ it never finishes.

Whenever you check membership repeatedly, the container holding the items must be a `set` or `dict`, not a `list` or `tuple`.

**Incorrect (membership in a list — O(n²) total):**

```python
def common_elements(a: list[int], b: list[int]) -> list[int]:
    # `x in b` is O(|b|), called |a| times → O(|a|·|b|)
    return [x for x in a if x in b]
```

**Correct (membership in a set — O(n) total):**

```python
def common_elements(a: list[int], b: list[int]) -> list[int]:
    # Build set once: O(|b|). Each `x in b_set` is O(1) average.
    # Total: O(|a| + |b|).
    b_set = set(b)
    return [x for x in a if x in b_set]
```

**Watch for hidden variants:**

- `if item not in already_processed:` where `already_processed` is a list
- `list.index(x)` inside a loop (same O(n) cost as `in`)
- `for x in unique_so_far: ...` to dedupe — use a `set` instead
- `df['col'].isin(small_list)` is fine; `df['col'].apply(lambda v: v in small_list)` is not (the latter loses vectorization)

Reference: [Python Wiki — TimeComplexity](https://wiki.python.org/moin/TimeComplexity)
