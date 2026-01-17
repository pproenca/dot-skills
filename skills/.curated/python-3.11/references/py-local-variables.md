---
title: Prefer Local Variables Over Global Lookups
impact: LOW
impactDescription: faster name resolution
tags: py, local, global, scope, LEGB
---

## Prefer Local Variables Over Global Lookups

Python resolves names using LEGB (Local, Enclosing, Global, Built-in). Local variables are stored in a fixed-size array with O(1) index access, while globals require dictionary lookups.

**Incorrect (global lookup each iteration):**

```python
MULTIPLIER = 2.5
OFFSET = 10

def transform_values(values: list[float]) -> list[float]:
    result = []
    for v in values:
        result.append(v * MULTIPLIER + OFFSET)  # Global lookup × 2 per iteration
    return result
```

**Correct (local variable cache):**

```python
MULTIPLIER = 2.5
OFFSET = 10

def transform_values(values: list[float]) -> list[float]:
    multiplier = MULTIPLIER  # Cache as local
    offset = OFFSET
    result = []
    for v in values:
        result.append(v * multiplier + offset)  # Local lookup (faster)
    return result
```

**For built-in functions:**

```python
# Before (built-in lookup each call)
for item in items:
    result.append(len(item))

# After (local cache)
_len = len
for item in items:
    result.append(_len(item))
```

**Note:** This optimization matters in tight loops with millions of iterations. For typical code, readability is more important.

Reference: [Real Python - LEGB Rule](https://realpython.com/python-scope-legb-rule/)
