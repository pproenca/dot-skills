---
title: Tabulate Bottom-Up When Recursion Depth Or Eviction Order Matters
impact: HIGH
impactDescription: prevents stack overflow on deep DPs; enables O(1) space via rolling arrays
tags: dp, tabulation, bottom-up, rolling-array
---

## Tabulate Bottom-Up When Recursion Depth Or Eviction Order Matters

Memoized recursion (top-down) is easiest to write, but bottom-up tabulation has two advantages that often matter: (1) no recursion stack — fills an iterative loop instead, so DPs with depth > 10⁴ don't blow CPython's stack; (2) you control the order, which lets you collapse the table to a rolling 1- or 2-row window for O(1) extra space. For DPs on long strings, large arrays, or grids ≥ 10⁴ × 10⁴, this is the difference between "works" and "OOM kill / stack overflow."

The conversion is mechanical: identify which dimensions appear in the recurrence (the "state"), iterate them in dependency order, and write the same transition.

**Incorrect (memoized recursion that overflows the stack on `n = 10⁵`):**

```python
from functools import cache

def lis_length(arr: list[int]) -> int:
    # Recurses up to n times. n = 10⁵ → RecursionError in CPython.
    @cache
    def f(i: int) -> int:
        best = 1
        for j in range(i):
            if arr[j] < arr[i]:
                best = max(best, f(j) + 1)
        return best
    return max((f(i) for i in range(len(arr))), default=0)
```

**Correct (bottom-up tabulation — no recursion):**

```python
def lis_length(arr: list[int]) -> int:
    # dp[i] = LIS length ending at i. O(n²) time, O(n) space, no recursion.
    n = len(arr)
    if n == 0:
        return 0
    dp = [1] * n
    for i in range(n):
        for j in range(i):
            if arr[j] < arr[i] and dp[j] + 1 > dp[i]:
                dp[i] = dp[j] + 1
    return max(dp)
```

**Rolling-array compression** (when the recurrence only references the last 1-2 rows):

```python
def edit_distance(a: str, b: str) -> int:
    # Classic DP uses O(|a|·|b|) memory. Rolling 2 rows → O(min(|a|,|b|)) memory.
    if len(a) < len(b):
        a, b = b, a
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, start=1):
        cur = [i] + [0] * len(b)
        for j, cb in enumerate(b, start=1):
            cur[j] = prev[j - 1] if ca == cb else 1 + min(prev[j - 1], prev[j], cur[j - 1])
        prev = cur
    return prev[len(b)]
```

**When top-down is still better:**

- Many states are unreachable — top-down skips them, tabulation fills the whole grid anyway
- The recurrence is more naturally recursive (e.g. game theory minimax) and the depth fits the stack

Reference: [USACO Guide — Introduction to DP](https://usaco.guide/gold/intro-dp)
