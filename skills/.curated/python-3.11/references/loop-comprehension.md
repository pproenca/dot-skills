---
title: Use List Comprehensions Over Explicit Loops
impact: MEDIUM
impactDescription: 2-3× faster iteration
tags: loop, comprehension, performance, pythonic
---

## Use List Comprehensions Over Explicit Loops

List comprehensions are optimized in C and avoid the overhead of repeated `append()` calls. They're 2-3× faster than equivalent for loops.

**Incorrect (explicit loop with append):**

```python
def get_active_user_ids(users: list[dict]) -> list[int]:
    result = []
    for user in users:
        if user["status"] == "active":
            result.append(user["id"])  # Method lookup + call per iteration
    return result
```

**Correct (list comprehension):**

```python
def get_active_user_ids(users: list[dict]) -> list[int]:
    return [user["id"] for user in users if user["status"] == "active"]
    # No append overhead, optimized bytecode
```

**For complex transformations:**

```python
# Multiple operations are still cleaner as comprehension
active_emails = [
    user["email"].lower().strip()
    for user in users
    if user["status"] == "active" and user["email"]
]
```

**When NOT to use comprehensions:**
- Side effects needed (logging, database writes)
- Complex multi-step logic requiring intermediate variables
- Readability suffers with deeply nested conditions

Reference: [Python Wiki - Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)
