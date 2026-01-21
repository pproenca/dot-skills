---
title: Use lru_cache for Expensive Function Memoization
impact: LOW-MEDIUM
impactDescription: avoids repeated computation
tags: func, lru-cache, memoization, caching
---

## Use lru_cache for Expensive Function Memoization

Functions called with the same arguments repeatedly waste computation. `@lru_cache` stores results automatically, returning cached values on subsequent calls.

**Incorrect (recomputes every call):**

```python
def calculate_fibonacci(n: int) -> int:
    if n < 2:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)
# fib(35) = 9,227,465 recursive calls

def get_user_permissions(user_id: int) -> set[str]:
    user = fetch_user_from_db(user_id)  # DB call every time
    return compute_effective_permissions(user)
```

**Correct (cached results):**

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def calculate_fibonacci(n: int) -> int:
    if n < 2:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)
# fib(35) = 35 unique calls, rest cached

@lru_cache(maxsize=1000)
def get_user_permissions(user_id: int) -> frozenset[str]:
    user = fetch_user_from_db(user_id)  # Cached after first call
    return frozenset(compute_effective_permissions(user))
```

**For unhashable arguments:**

```python
from functools import cache  # Python 3.9+, unbounded cache

@cache
def expensive_computation(x: int, y: int) -> int:
    return x ** y
```

**Note:** Arguments must be hashable. Use `frozenset` instead of `set`, tuple instead of list.

Reference: [functools.lru_cache documentation](https://docs.python.org/3/library/functools.html#functools.lru_cache)
