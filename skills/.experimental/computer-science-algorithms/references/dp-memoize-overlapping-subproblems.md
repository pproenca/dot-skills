---
title: Memoize Recursions With Overlapping Subproblems
impact: HIGH
impactDescription: O(2ⁿ) to O(n) or O(n²) — turns exponential into polynomial
tags: dp, memoization, top-down, overlapping-subproblems
---

## Memoize Recursions With Overlapping Subproblems

The diagnostic for DP is: a recursion explores the same subproblem many times. Naive Fibonacci visits `fib(k)` ~φ^(n-k) times, blowing up exponentially. Caching each subproblem's answer the first time it's computed collapses that to one visit per distinct subproblem — turning O(2ⁿ) into O(n) or O(n²) depending on how many distinct subproblems exist.

In Python, `functools.cache` (or `lru_cache(maxsize=None)`) is the cheapest possible memoization. Write the recurrence naturally, then add one decorator. Don't pre-optimize to a table; let the cache prove the recurrence first.

**Incorrect (exponential recursion — `coinChange` revisits every (n) thousands of times):**

```python
def min_coins(coins, amount):
    # Each call branches |coins| ways; same `n` reached through many paths.
    # O(|coins|^amount) — TLE for amount = 30.
    if amount == 0: return 0
    if amount < 0:  return float("inf")
    return min(min_coins(coins, amount - c) for c in coins) + 1
```

**Correct (memoize — O(amount · |coins|)):**

```python
from functools import cache

def min_coins(coins, amount):
    @cache  # one cache key per distinct `n` value → at most `amount + 1` calls.
    def f(n: int) -> int:
        if n == 0: return 0
        if n < 0:  return float("inf")
        return min(f(n - c) for c in coins) + 1

    ans = f(amount)
    return -1 if ans == float("inf") else ans
```

**Cache key hygiene:**

- Arguments must be hashable. Tuple up lists, freeze dicts/sets.
- Avoid passing in mutable globals captured implicitly — if the recursion result depends on a global that changes, the cache returns stale answers.
- `@cache` on instance methods caches by `(self, *args)`, which prevents garbage collection of `self`. For long-running objects, use `cachetools.cached(LRUCache(...))` keyed on args only.

**When to switch to bottom-up (tabulation):**

- Recursion depth would overflow the stack (CPython default is 1000)
- You want O(1) space via a rolling window
- The order of subproblem dependence is obvious from the recurrence

Reference: [CLRS Chapter 14 — Dynamic Programming](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
