---
title: Use str.startswith() with Tuple for Multiple Prefixes
impact: MEDIUM
impactDescription: single call vs multiple comparisons
tags: str, startswith, endswith, pattern-matching
---

## Use str.startswith() with Tuple for Multiple Prefixes

Checking multiple prefixes with `or` requires multiple string scans. `startswith()` accepts a tuple of prefixes, checking all in one optimized call.

**Incorrect (multiple comparisons):**

```python
def is_system_file(filename: str) -> bool:
    return (filename.startswith(".") or
            filename.startswith("__") or
            filename.startswith("~"))
```

**Correct (tuple of prefixes):**

```python
def is_system_file(filename: str) -> bool:
    return filename.startswith((".", "__", "~"))
```

**Works with endswith too:**

```python
def is_image_file(filename: str) -> bool:
    return filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif", ".webp"))

def is_config_file(path: str) -> bool:
    return path.endswith((".yaml", ".yml", ".json", ".toml"))
```

**Note:** The argument must be a tuple, not a list. Lists are not supported.

Reference: [str.startswith documentation](https://docs.python.org/3/library/stdtypes.html#str.startswith)
