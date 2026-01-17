---
title: Use dict.items() for Key-Value Iteration
impact: MEDIUM
impactDescription: single lookup vs double lookup
tags: loop, dict, items, iteration
---

## Use dict.items() for Key-Value Iteration

Iterating over keys then looking up values performs two operations per entry. `dict.items()` provides both in a single iteration.

**Incorrect (double lookup per item):**

```python
def transform_config(config: dict[str, str]) -> dict[str, str]:
    result = {}
    for key in config:  # First: iterate keys
        value = config[key]  # Second: lookup value
        result[key.upper()] = value.strip()
    return result
```

**Correct (single lookup):**

```python
def transform_config(config: dict[str, str]) -> dict[str, str]:
    return {key.upper(): value.strip() for key, value in config.items()}
    # items() yields (key, value) tuples directly
```

**Similarly for values only:**

```python
# When you only need values
total = sum(order["amount"] for order in orders.values())

# When you only need keys
active_keys = [k for k in cache.keys() if not k.startswith("_")]
# Or simply: [k for k in cache if not k.startswith("_")]
```

Reference: [dict.items() documentation](https://docs.python.org/3/library/stdtypes.html#dict.items)
