---
title: Memoize Recursion With Overlapping Subproblems
impact: CRITICAL
impactDescription: O(2ⁿ) to O(n) — 1,000,000× faster at n=30
tags: rec, memoization, dynamic-programming, exponential, lru-cache
---

## Memoize Recursion With Overlapping Subproblems

A recursive function that calls itself with arguments it has already computed for is doing the same work many times — and the count of repeat computations grows exponentially with depth. Fibonacci is the canonical example: `fib(30)` makes over 2.6 million calls to compute 31 distinct values. The structural fix is memoization — cache the result keyed by the arguments, return it on the next call. The recursion shape doesn't change; the cache turns an exponential tree into a linear DAG.

The signal: a recursion whose subcalls overlap (same arguments reached via different paths) is always worth memoizing.

**Incorrect (exponential — O(2ⁿ)):**

```python
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
# fib(30) → 2,692,537 function calls
# fib(40) → 331,160,281 calls (~3 seconds in CPython)
```

**Correct (memoized — O(n)):**

```python
from functools import lru_cache

@lru_cache(maxsize=None)
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
# fib(30) → 31 calls, fib(40) → 41 calls (microseconds)
```

**Alternative (manual memo when key is non-hashable):**

```python
def edit_distance(a, b, memo=None):
    memo = memo if memo is not None else {}
    if (len(a), len(b)) in memo:
        return memo[(len(a), len(b))]
    # ... compute ...
    memo[(len(a), len(b))] = result
    return result
```

**When NOT to use this pattern:**
- When subproblems are unique (no overlap) — memoization adds bookkeeping for no benefit. Example: tree traversal where every subtree is visited exactly once.
- When cache size would exceed memory — bound `maxsize` or switch to tabulation; see [`rec-tabulate-bottom-up`](rec-tabulate-bottom-up.md).

Reference: [Python `functools.lru_cache` — memoization decorator](https://docs.python.org/3/library/functools.html#functools.lru_cache)
