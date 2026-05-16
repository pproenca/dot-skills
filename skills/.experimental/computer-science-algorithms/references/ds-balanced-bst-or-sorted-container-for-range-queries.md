---
title: Use A Balanced BST Or Sorted Container For Order-Sensitive Queries
impact: HIGH
impactDescription: O(n) per range query to O(log n) — required when both order and lookup matter
tags: ds, balanced-bst, sorted-container, range-query
---

## Use A Balanced BST Or Sorted Container For Order-Sensitive Queries

A hash map is faster than a balanced BST for point lookups — but it loses to a BST whenever you need any *ordered* operation: predecessor, successor, range scan, k-th smallest, or "give me the smallest key larger than x." For those, a balanced BST (`std::map`, `TreeMap`, `SortedContainers.SortedList`) gives O(log n) per operation while a hash map needs O(n) to find ordered neighbours.

The decision rule: use a hash map for "is x here?" and "what value does x map to?" Use an ordered structure when the question involves "next/previous/range/rank."

**Incorrect (linear scan for predecessor — O(n) per query):**

```python
def closest_below(values: list[int], target: int) -> int | None:
    # Walk the list to find the largest value < target. O(n) per query.
    best = None
    for v in values:
        if v < target and (best is None or v > best):
            best = v
    return best
```

**Correct (sorted container — O(log n) per query):**

```python
from sortedcontainers import SortedList

class ClosestBelowIndex:
    def __init__(self, values: list[int]):
        # O(n log n) build, O(log n) per query and per insert.
        self.s = SortedList(values)

    def query(self, target: int) -> int | None:
        i = self.s.bisect_left(target)  # O(log n)
        return self.s[i - 1] if i > 0 else None
```

**When a hash map is enough:**

If the only ordered query is "global min/max" and inserts never delete the current extreme, a hash map plus a running min/max variable is simpler and faster.

**Language equivalents:**

- Python: `sortedcontainers.SortedList` / `SortedDict` (third-party; or use `bisect` + `list` for static data)
- C++: `std::map`, `std::set` (red-black trees), `std::multiset`
- Java: `TreeMap`, `TreeSet`
- Go: stdlib lacks one — use a third-party B-tree or skip list

Reference: [CLRS Chapter 13 — Red-Black Trees](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
