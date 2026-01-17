---
title: Leverage Zero-Cost Exception Handling
impact: LOW
impactDescription: zero overhead in happy path (Python 3.11+)
tags: py, exceptions, zero-cost, EAFP
---

## Leverage Zero-Cost Exception Handling

Python 3.11+ implements zero-cost exception handling where try/except blocks have no overhead when no exception is raised. This makes EAFP (Easier to Ask Forgiveness than Permission) efficient.

**Incorrect (LBYL style, always checks):**

```python
def get_user_value(data: dict, key: str) -> str | None:
    if key in data:  # Always performs check
        value = data[key]
        if isinstance(value, str):  # Another check
            return value.strip()
    return None
```

**Correct (EAFP style, zero cost when key exists):**

```python
def get_user_value(data: dict, key: str) -> str | None:
    try:
        return data[key].strip()  # Zero overhead if key exists
    except (KeyError, AttributeError):
        return None
```

**When EAFP is better:**
- Key/attribute usually exists (happy path is common)
- Multiple conditions would need checking
- Race conditions between check and use

**When LBYL is better:**
- Operation has side effects (file creation)
- Check is cheap, exception is expensive to create
- Failure is common (50%+ of cases)

```python
# LBYL better here - side effect
if not path.exists():
    path.mkdir()

# EAFP better here - usually exists
try:
    config = load_config()
except FileNotFoundError:
    config = default_config()
```

Reference: [CPython Exception Handling](https://github.com/python/cpython/blob/main/InternalDocs/exception_handling.md)
