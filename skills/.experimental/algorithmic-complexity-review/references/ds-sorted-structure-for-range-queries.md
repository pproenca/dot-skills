---
title: Use a Sorted Structure for Range Queries
impact: HIGH
impactDescription: O(n) per range query to O(log n + k) — k = result size
tags: ds, sorted-set, tree-map, range-query, balanced-tree
---

## Use a Sorted Structure for Range Queries

"Give me every event between t₁ and t₂" against an unsorted list forces a full scan — O(n) per query. A balanced binary search tree (`TreeMap` in Java, `std::map` in C++, `sortedcontainers.SortedDict` in Python) finds the lower bound in O(log n) and walks forward until t₂ — O(log n + k) where k is the result count. The same applies to "smallest item ≥ x," "largest ≤ x," and "k-th order statistic" — questions that are answered in microseconds against a sorted structure and seconds against a list.

**Incorrect (linear scan per query — O(n) each):**

```python
events = [...]   # 500,000 events, unsorted by timestamp

def events_in_range(t1, t2):
    return [e for e in events if t1 <= e.timestamp <= t2]   # O(n)

# 1,000 queries × 500,000 = 500,000,000 comparisons
```

**Correct (sorted structure — O(log n + k) per query):**

```python
from sortedcontainers import SortedDict
events_by_ts = SortedDict()
for e in events:
    events_by_ts[e.timestamp] = e             # O(n log n) once

def events_in_range(t1, t2):
    return list(events_by_ts.irange(t1, t2))  # O(log n + k)
```

**Alternative (when range queries are rare but inserts are frequent):**

```python
# If reads are bursty after a load phase, sort once and use bisect
import bisect
events.sort(key=lambda e: e.timestamp)
timestamps = [e.timestamp for e in events]

def events_in_range(t1, t2):
    lo = bisect.bisect_left(timestamps, t1)
    hi = bisect.bisect_right(timestamps, t2)
    return events[lo:hi]                       # O(log n + k)
```

**When NOT to use this pattern:**
- When ranges almost always cover most of the data — the structural advantage shrinks; a plain sorted list with `bisect` is simpler.
- When you also need approximate-membership queries on a stream — consider a Bloom filter or count-min sketch instead.

Reference: [`sortedcontainers.SortedDict` — exposes `irange` and `irange_key` in O(log n + k)](http://www.grantjenks.com/docs/sortedcontainers/sorteddict.html)
