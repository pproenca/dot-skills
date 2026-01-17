---
title: Use defaultdict to Avoid Key Existence Checks
impact: CRITICAL
impactDescription: eliminates redundant lookups
tags: ds, defaultdict, collections, grouping
---

## Use defaultdict to Avoid Key Existence Checks

Checking if a key exists before modifying it requires two lookups. `defaultdict` auto-initializes missing keys, reducing code and improving performance.

**Incorrect (double lookup per key):**

```python
def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = {}
    for order in orders:
        user_id = order["user_id"]
        if user_id not in grouped:  # First lookup
            grouped[user_id] = []
        grouped[user_id].append(order)  # Second lookup
    return grouped
```

**Correct (single lookup):**

```python
from collections import defaultdict

def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = defaultdict(list)
    for order in orders:
        grouped[order["user_id"]].append(order)  # Single lookup, auto-creates list
    return dict(grouped)
```

**Alternative (setdefault):**

```python
def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = {}
    for order in orders:
        grouped.setdefault(order["user_id"], []).append(order)
    return grouped
```

**Note:** Convert back to regular dict if you need strict KeyError behavior later.

Reference: [collections.defaultdict documentation](https://docs.python.org/3/library/collections.html#collections.defaultdict)
