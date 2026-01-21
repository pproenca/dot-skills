---
title: Use any() and all() for Boolean Aggregation
impact: MEDIUM
impactDescription: O(n) to O(1) best case
tags: loop, any, all, short-circuit, performance
---

## Use any() and all() for Boolean Aggregation

Manual loops for checking conditions iterate through all elements. `any()` and `all()` short-circuit on the first conclusive result.

**Incorrect (checks all elements):**

```python
def has_admin_user(users: list[dict]) -> bool:
    found = False
    for user in users:
        if user["role"] == "admin":
            found = True
            # Continues iterating even after finding one!
    return found
```

**Correct (short-circuits immediately):**

```python
def has_admin_user(users: list[dict]) -> bool:
    return any(user["role"] == "admin" for user in users)
    # Stops at first admin found
```

**Common patterns:**

```python
# Check if all items meet condition
all_active = all(user["status"] == "active" for user in users)

# Check if any item fails condition
has_invalid = any(not validate_email(user["email"]) for user in users)

# Combine with filter-like logic
has_large_order = any(order["total"] > 1000 for order in orders if order["status"] == "completed")
```

**Note:** Use generator expressions (parentheses) not list comprehensions (brackets) to get short-circuit behavior.

Reference: [any() documentation](https://docs.python.org/3/library/functions.html#any)
