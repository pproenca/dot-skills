---
title: Use Walrus Operator for Assignment in Expressions
impact: LOW
impactDescription: eliminates redundant computations
tags: py, walrus, assignment-expression, python38
---

## Use Walrus Operator for Assignment in Expressions

The walrus operator (`:=`) assigns a value while also returning it, avoiding duplicate computations or function calls.

**Incorrect (duplicate computation):**

```python
def process_data(items: list[str]) -> list[str]:
    results = []
    for item in items:
        if len(item.strip()) > 10:  # Computes strip() once
            results.append(item.strip())  # Computes strip() again
    return results
```

**Correct (single computation with walrus):**

```python
def process_data(items: list[str]) -> list[str]:
    results = []
    for item in items:
        if len(stripped := item.strip()) > 10:  # Assign and test
            results.append(stripped)  # Reuse assigned value
    return results
```

**Common patterns:**

```python
# Regex match and use
if match := pattern.search(text):
    print(f"Found: {match.group()}")

# Read until empty
while chunk := file.read(8192):
    process(chunk)

# Filter with computed value
valid_users = [user for user in users if (age := calculate_age(user)) >= 18]
```

**Note:** Introduced in Python 3.8 (PEP 572).

Reference: [PEP 572 - Assignment Expressions](https://peps.python.org/pep-0572/)
