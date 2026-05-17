---
title: Use Binary Search on Sorted Data
impact: MEDIUM-HIGH
impactDescription: O(n) per lookup to O(log n) — 1,000× speedup at n=1,000,000
tags: search, binary-search, bisect, sorted, logarithmic
---

## Use Binary Search on Sorted Data

If the underlying data is already sorted (or you'll sort it once and query many times), linear scanning to find a value, a boundary, or a range is leaving log-factor speedup on the table. Binary search is O(log n): 1,000,000 elements → 20 comparisons versus 1,000,000. The standard library exposes it directly — `bisect_left`/`bisect_right` (Python), `Arrays.binarySearch` (Java), `std::lower_bound` (C++), `sort.Search` (Go). For JavaScript, write a 10-line bisect helper; the cost is trivial compared to the speedup.

**Incorrect (linear scan against sorted data — O(n) per call):**

```python
sorted_timestamps = [...]            # sorted, 1,000,000 entries

def first_after(t):
    for i, ts in enumerate(sorted_timestamps):
        if ts >= t:
            return i
    return None
# 10,000 queries × 500k avg scan = 5,000,000,000 comparisons
```

**Correct (binary search — O(log n) per call):**

```python
import bisect
def first_after(t):
    return bisect.bisect_left(sorted_timestamps, t)
# 10,000 queries × ~20 comparisons = 200,000 comparisons total
```

**Alternative (range queries with both bounds):**

```python
def items_in_range(lo, hi):
    left = bisect.bisect_left(sorted_timestamps, lo)
    right = bisect.bisect_right(sorted_timestamps, hi)
    return sorted_timestamps[left:right]      # O(log n + k)
```

**When NOT to use this pattern:**
- When data is not sorted and you can only insert (not rebuild) — binary search doesn't apply to unsorted data. Use a hash structure or a balanced tree.
- When the array is tiny (< 50 items) — the constant factor of bisect can match linear scan; favor readability.

Reference: [Python `bisect` — Array bisection algorithm](https://docs.python.org/3/library/bisect.html)
