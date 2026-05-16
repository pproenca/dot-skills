---
title: Use Bitmask DP When The State Includes A Small Subset
impact: MEDIUM
impactDescription: factorial (n!) to O(2ⁿ·n) — practical up to n ≈ 20
tags: dp, bitmask, tsp, subset-state
---

## Use Bitmask DP When The State Includes A Small Subset

When the natural state is "which subset of these items have I visited / used / assigned" and n ≤ ~20, encode the subset as bits of an integer. The state space becomes 2ⁿ rather than n! — for n = 16 that's 65k states vs 20 trillion permutations. The canonical example is the Travelling Salesman Problem: O(2ⁿ·n²) DP beats the O(n!) brute force decisively at n = 15.

The encoding: `mask = 0b1011` means "items 0, 1, and 3 are in the set." Bit ops: `mask | (1 << i)` adds i; `mask & ~(1 << i)` removes i; `mask & (1 << i)` tests i.

**Incorrect (permutation enumeration for TSP — O(n!)):**

```python
from itertools import permutations

def tsp_brute(dist: list[list[int]]) -> int:
    n = len(dist)
    # (n-1)! permutations starting from 0. n = 12 → ~5x10⁸ ops, n = 15 → infeasible.
    best = float("inf")
    for perm in permutations(range(1, n)):
        cost = dist[0][perm[0]]
        for a, b in zip(perm, perm[1:]):
            cost += dist[a][b]
        cost += dist[perm[-1]][0]
        best = min(best, cost)
    return best
```

**Correct (Held-Karp bitmask DP — O(2ⁿ·n²)):**

```python
def tsp_dp(dist: list[list[int]]) -> int:
    # dp[mask][i] = min cost to start at 0, visit exactly the set `mask`, end at i.
    n = len(dist)
    INF = float("inf")
    dp = [[INF] * n for _ in range(1 << n)]
    dp[1][0] = 0  # mask = {0}, ended at 0
    for mask in range(1, 1 << n):
        if not (mask & 1):
            continue  # we always start at 0
        for i in range(n):
            if not (mask & (1 << i)) or dp[mask][i] == INF:
                continue
            for j in range(n):
                if mask & (1 << j):
                    continue
                nmask = mask | (1 << j)
                cand = dp[mask][i] + dist[i][j]
                if cand < dp[nmask][j]:
                    dp[nmask][j] = cand
    full = (1 << n) - 1
    return min(dp[full][i] + dist[i][0] for i in range(1, n))
```

**Iterate subsets of a mask** (for partitioning problems):

```python
def iter_submasks(mask: int):
    sub = mask
    while sub > 0:
        yield sub
        sub = (sub - 1) & mask
    yield 0
```

**Watch the memory:** 2ⁿ × n states with 8-byte ints is 8·n·2ⁿ bytes — n = 22 needs ~700 MB. Stop at n = 20 unless you compress.

Reference: [cp-algorithms — Submask enumeration](https://cp-algorithms.com/algebra/all-submasks.html)
