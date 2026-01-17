---
title: Use frozenset for Hashable Set Keys
impact: CRITICAL
impactDescription: enables set-of-sets patterns
tags: ds, frozenset, hashable, dict-keys
---

## Use frozenset for Hashable Set Keys

Regular sets are mutable and unhashable, so they cannot be dict keys or set members. Use `frozenset` for immutable, hashable sets.

**Incorrect (unhashable set as key):**

```python
def find_duplicate_permission_groups(users: list[dict]) -> list[set]:
    seen = {}
    duplicates = []
    for user in users:
        perms = set(user["permissions"])
        if perms in seen:  # TypeError: unhashable type: 'set'
            duplicates.append(perms)
        seen[perms] = user["id"]
    return duplicates
```

**Correct (hashable frozenset):**

```python
def find_duplicate_permission_groups(users: list[dict]) -> list[set]:
    seen = {}
    duplicates = []
    for user in users:
        perms = frozenset(user["permissions"])  # Immutable and hashable
        if perms in seen:  # O(1) lookup works
            duplicates.append(set(perms))
        seen[perms] = user["id"]
    return duplicates
```

**Alternative (caching computed sets):**

```python
from functools import cache

@cache
def compute_dependencies(package: frozenset[str]) -> frozenset[str]:
    # frozenset enables caching of set-based inputs
    return frozenset(resolve_deps(package))
```

Reference: [frozenset documentation](https://docs.python.org/3/library/stdtypes.html#frozenset)
