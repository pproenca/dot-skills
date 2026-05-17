---
title: Share Memoization Across Top-Level Calls
impact: HIGH
impactDescription: O(q*n) to O(q+n) for q queries — eliminates repeat exponential work
tags: rec, memoization, shared-cache, batch-queries, instance-cache
---

## Share Memoization Across Top-Level Calls

Memoization confined to a single call is wasted when the same function is invoked many times with overlapping inputs — each call starts with an empty cache, re-computing what an earlier call already solved. The fix is to lift the memo out of the call (instance attribute, module-level dict, `lru_cache` on the function itself) so subsequent invocations reuse prior results. This is especially important when serving batched requests: 1,000 queries that each compute `fib(40)` should share one memo, not allocate 1,000 of them.

**Incorrect (cache reset on every call — repeats all work):**

```python
def compute(n):
    memo = {}                              # fresh memo every invocation
    def helper(x):
        if x in memo:
            return memo[x]
        # ... recursive work ...
        memo[x] = result
        return result
    return helper(n)

# Batch query
for n in queries:                          # 1,000 queries
    results.append(compute(n))             # each pays full O(n) recursion
```

**Correct (module-level `lru_cache` — shared across all callers):**

```python
@lru_cache(maxsize=10_000)
def compute(n):
    if n < 2:
        return n
    return compute(n - 1) + compute(n - 2)

for n in queries:
    results.append(compute(n))             # second call onward: O(1) cache hits
```

**Alternative (instance-scoped cache for stateful classes):**

```python
class Solver:
    def __init__(self):
        self._memo = {}

    def compute(self, n):
        if n in self._memo:
            return self._memo[n]
        result = ...   # recursive work, using self.compute for subproblems
        self._memo[n] = result
        return result
# One Solver instance, many queries → shared cache
```

**When NOT to use this pattern:**
- When the function's result depends on hidden state (current time, RNG, mutable globals) — cached results become stale.
- When the cache would grow unbounded over a long-running process — set `maxsize` on `lru_cache` or use a TTL cache.

Reference: [Python `functools.lru_cache` — function-level cache survives across all callers](https://docs.python.org/3/library/functools.html#functools.lru_cache)
