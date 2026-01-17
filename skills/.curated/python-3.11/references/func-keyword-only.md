---
title: Use Keyword-Only Arguments for API Clarity
impact: LOW-MEDIUM
impactDescription: prevents positional argument errors
tags: func, keyword-only, api-design, clarity
---

## Use Keyword-Only Arguments for API Clarity

Functions with multiple boolean or similar-typed arguments are error-prone when called positionally. Keyword-only arguments (after `*`) enforce explicit naming.

**Incorrect (ambiguous positional args):**

```python
def create_user(name: str, admin: bool, active: bool, verified: bool) -> User:
    return User(name=name, admin=admin, active=active, verified=verified)

# Easy to get wrong:
user = create_user("alice", True, False, True)  # Which bool is which?
user = create_user("bob", False, True, False)  # Confusing
```

**Correct (keyword-only after *):**

```python
def create_user(
    name: str,
    *,
    admin: bool = False,
    active: bool = True,
    verified: bool = False,
) -> User:
    return User(name=name, admin=admin, active=active, verified=verified)

# Forces clarity:
user = create_user("alice", admin=True, verified=True)
user = create_user("bob", active=True)
# create_user("charlie", True, False, True)  # TypeError!
```

**Positional-only (Python 3.8+):**

```python
def calculate_distance(x1: float, y1: float, x2: float, y2: float, /) -> float:
    # / means all args before it are positional-only
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

Reference: [PEP 3102 - Keyword-Only Arguments](https://peps.python.org/pep-3102/)
