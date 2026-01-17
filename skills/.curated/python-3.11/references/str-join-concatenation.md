---
title: Use join() for Multiple String Concatenation
impact: MEDIUM
impactDescription: 4× faster for 5+ strings
tags: str, join, concatenation, performance
---

## Use join() for Multiple String Concatenation

String concatenation with `+` in loops is O(n²) because strings are immutable—each concatenation creates a new string. `join()` pre-allocates the final size for O(n) performance.

**Incorrect (O(n²) concatenation):**

```python
def build_csv_row(values: list[str]) -> str:
    result = ""
    for i, value in enumerate(values):
        if i > 0:
            result += ","  # Creates new string
        result += value  # Creates another new string
    return result
# 100 values = ~5,000 string allocations
```

**Correct (O(n) join):**

```python
def build_csv_row(values: list[str]) -> str:
    return ",".join(values)
    # Single allocation of final size
```

**For conditional inclusion:**

```python
def build_query_params(params: dict[str, str]) -> str:
    return "&".join(f"{key}={value}" for key, value in params.items() if value)
```

**Note:** For 2-3 strings, `+` or f-strings are fine. Use `join()` when concatenating 5+ strings or in loops.

Reference: [Real Python - String Concatenation](https://realpython.com/python-string-concatenation/)
