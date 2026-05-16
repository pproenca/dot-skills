---
title: Recognize The Knapsack Pattern For Subset-Sum Decisions
impact: MEDIUM-HIGH
impactDescription: exponential subset search to pseudo-polynomial O(n·W)
tags: dp, knapsack, subset-sum, pseudo-polynomial
---

## Recognize The Knapsack Pattern For Subset-Sum Decisions

Many problems reduce to "pick a subset that maximizes value subject to a capacity constraint": 0/1 knapsack, subset-sum, partition into equal halves, coin change (count), bounded ways-to-make-change. They all share the recurrence `dp[i][w] = max/min/count of (skip item i, take item i)`. Recognizing this pattern collapses a 2ⁿ subset enumeration into O(n·W) — pseudo-polynomial because W can itself be exponential in input bits, but practical when W is bounded.

The two flavours:
- **0/1 knapsack**: each item once. Inner loop runs *downwards* in the rolling array to prevent using the same item twice.
- **Unbounded knapsack (coin change)**: items reusable. Inner loop runs *upwards*.

**Incorrect (exponential subset enumeration — O(2ⁿ)):**

```python
from itertools import combinations

def max_value(weights, values, capacity):
    best = 0
    for r in range(len(weights) + 1):
        for subset in combinations(range(len(weights)), r):
            w = sum(weights[i] for i in subset)
            if w <= capacity:
                best = max(best, sum(values[i] for i in subset))
    return best
```

**Correct (0/1 knapsack DP — O(n·W) with O(W) rolling array):**

```python
def max_value(weights: list[int], values: list[int], capacity: int) -> int:
    # dp[w] = max value achievable with capacity w considering items seen so far.
    # Inner loop descends so each item is used at most once.
    dp = [0] * (capacity + 1)
    for wt, val in zip(weights, values):
        for w in range(capacity, wt - 1, -1):
            dp[w] = max(dp[w], dp[w - wt] + val)
    return dp[capacity]
```

**Unbounded knapsack (coin change, count of ways):**

```python
def count_change(coins: list[int], amount: int) -> int:
    # Inner loop ascends → coins reusable. Outer loop is over coins
    # (not amounts) so each combination is counted once.
    dp = [0] * (amount + 1)
    dp[0] = 1
    for c in coins:
        for w in range(c, amount + 1):
            dp[w] += dp[w - c]
    return dp[amount]
```

**Loop order is correctness, not optimization:**

- 0/1 descending capacity, items outer: each item considered once
- Unbounded ascending capacity, items outer (for count of combinations) OR amounts outer (for count of permutations) — these give different answers

Reference: [cp-algorithms — Knapsack problem](https://cp-algorithms.com/dynamic_programming/knapsack.html)
