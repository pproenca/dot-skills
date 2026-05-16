---
title: Use A Fenwick Or Segment Tree For Mutable Range Queries
impact: MEDIUM-HIGH
impactDescription: O(n) per update OR query to O(log n) for both
tags: ds, fenwick, segment-tree, range-query
---

## Use A Fenwick Or Segment Tree For Mutable Range Queries

When an array supports both updates and range queries (sum, min, max, gcd) freely interleaved, neither a plain array (O(n) per query) nor a prefix-sum array (O(n) per update) is acceptable. A Fenwick tree (BIT) gives O(log n) for point-update + prefix-sum and is ~10 lines of code. A segment tree handles arbitrary associative operations and lazy propagation for range updates.

Pick Fenwick when the operation is sum and updates are point-wise — it's smaller and faster by a constant factor. Pick a segment tree for min/max/gcd or for range updates with lazy propagation.

**Incorrect (prefix sum rebuilt on every update — O(n) per update):**

```python
def process(arr, ops):
    out = []
    for op in ops:
        if op[0] == "update":
            arr[op[1]] = op[2]
        else:  # query l..r
            out.append(sum(arr[op[1]:op[2] + 1]))  # O(n) per query
    return out
```

**Correct (Fenwick tree — O(log n) for both):**

```python
class Fenwick:
    def __init__(self, n: int):
        self.n = n
        self.t = [0] * (n + 1)

    def update(self, i: int, delta: int) -> None:
        # Point-add `delta` at position i. O(log n).
        i += 1
        while i <= self.n:
            self.t[i] += delta
            i += i & -i

    def prefix(self, i: int) -> int:
        # Sum of indices 0..i-1. O(log n).
        s = 0
        while i > 0:
            s += self.t[i]
            i -= i & -i
        return s

    def range_sum(self, l: int, r: int) -> int:
        # Sum of indices l..r inclusive.
        return self.prefix(r + 1) - self.prefix(l)
```

**When to skip and use sqrt decomposition:**

For exotic operations that don't compose nicely (e.g. "k-th element in range"), an O(√n) bucket structure is easier to write than a balanced BST and only ~30x slower than a segment tree at n = 10⁵.

Reference: [cp-algorithms — Fenwick tree](https://cp-algorithms.com/data_structures/fenwick.html)
