---
title: Binary Search Sorted Data Instead Of Linear Scan
impact: HIGH
impactDescription: O(n) per query to O(log n) — 1000x at n = 10⁶
tags: srch, binary-search, bisect, sorted-array
---

## Binary Search Sorted Data Instead Of Linear Scan

If the data is sorted, every "find this value" or "find the smallest value ≥ x" query is O(log n) via binary search. For n = 10⁶, that's ~20 comparisons vs. ~10⁶ for a linear scan — a 50000x reduction. The stdlib `bisect` / `lower_bound` modules implement this correctly; rolling your own is a known bug-magnet (off-by-one on mid calculation, infinite loop on `lo` updates).

Three idioms cover almost every use case: `bisect_left` (first index ≥ target), `bisect_right` (first index > target), and "binary search on the answer" (search the space of possible answers rather than the input array).

**Incorrect (linear scan inside a query loop — O(n·q)):**

```python
def positions(sorted_arr: list[int], queries: list[int]) -> list[int]:
    # For each query, walk the array. q queries → O(n·q).
    out = []
    for q in queries:
        for i, v in enumerate(sorted_arr):
            if v == q:
                out.append(i)
                break
        else:
            out.append(-1)
    return out
```

**Correct (binary search — O(q log n)):**

```python
from bisect import bisect_left

def positions(sorted_arr: list[int], queries: list[int]) -> list[int]:
    out = []
    for q in queries:
        i = bisect_left(sorted_arr, q)
        out.append(i if i < len(sorted_arr) and sorted_arr[i] == q else -1)
    return out
```

**Binary search on the answer** (when the answer space is monotonic but the input isn't sorted):

```python
def min_capacity_to_ship_within_d_days(weights: list[int], days: int) -> int:
    # Predicate: can we ship in `days` days with capacity `cap`?
    # Predicate is monotonic in `cap` → binary-search the smallest cap that works.
    def feasible(cap: int) -> bool:
        used, count = 0, 1
        for w in weights:
            if w > cap: return False
            if used + w > cap:
                count += 1
                used = w
            else:
                used += w
        return count <= days

    lo, hi = max(weights), sum(weights)
    while lo < hi:
        mid = (lo + hi) // 2
        if feasible(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo
```

**Always use the stdlib for plain searches** — don't reimplement `bisect_left`. Reserve hand-written binary search for "binary search on the answer," where the predicate is custom.

Reference: [Python docs — bisect](https://docs.python.org/3/library/bisect.html)
