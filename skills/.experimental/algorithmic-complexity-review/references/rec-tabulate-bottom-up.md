---
title: Tabulate Bottom-Up to Eliminate Recursion Overhead
impact: MEDIUM-HIGH
impactDescription: Same Big-O but 2-10× constant-factor speedup; eliminates stack-depth risk
tags: rec, dynamic-programming, tabulation, iterative, space-optimization
---

## Tabulate Bottom-Up to Eliminate Recursion Overhead

Memoized recursion (top-down DP) and tabulation (bottom-up DP) have the same Big-O, but tabulation is faster in practice on most runtimes (no function-call overhead, no hash lookups on the memo, better cache locality on a contiguous array) and trivially space-bounded. The conversion is mechanical: identify the dependency order of subproblems, allocate a table sized to the input, fill it in that order. Tabulation also makes the **rolling-array** space optimization obvious — if `f(n)` only depends on `f(n-1)` and `f(n-2)`, you only need two variables, not a length-n array.

**Incorrect (top-down memoization — same Big-O, but pays call/cache overhead):**

```python
@lru_cache(None)
def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)
# O(n) time, O(n) space — and pays Python's function-call overhead n times
```

**Correct (bottom-up tabulation — faster constants, O(1) space):**

```python
def fib(n):
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b
# O(n) time, O(1) space — pure arithmetic in a tight loop
```

**Alternative (2-D problem with rolling rows — O(n) space instead of O(n²)):**

```python
def edit_distance(a, b):
    prev = list(range(len(b) + 1))
    for i, x in enumerate(a, 1):
        curr = [i] + [0] * len(b)
        for j, y in enumerate(b, 1):
            curr[j] = prev[j - 1] if x == y else 1 + min(prev[j], curr[j - 1], prev[j - 1])
        prev = curr
    return prev[-1]
# O(|a|*|b|) time but only O(|b|) space — useful when one string is large
```

**When NOT to use this pattern:**
- When the subproblem space is sparse (most cells in the table never accessed) — top-down memoization only fills the cells it needs.
- When the dependency order is hard to derive — start with top-down memoization, then convert once correctness is established.

Reference: [Sedgewick & Wayne, Algorithms 4e — Dynamic Programming](https://algs4.cs.princeton.edu/)
