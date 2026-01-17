---
title: Use enumerate() for Index-Value Iteration
impact: MEDIUM
impactDescription: cleaner code, avoids index errors
tags: loop, enumerate, pythonic, iteration
---

## Use enumerate() for Index-Value Iteration

Manual index tracking with `range(len())` is error-prone and requires two lookups. `enumerate()` provides both index and value in one clean pattern.

**Incorrect (manual index tracking):**

```python
def find_duplicates(items: list[str]) -> list[tuple[int, int]]:
    duplicates = []
    for i in range(len(items)):  # Index only
        for j in range(i + 1, len(items)):
            if items[i] == items[j]:  # Separate lookup
                duplicates.append((i, j))
    return duplicates
```

**Correct (enumerate for index + value):**

```python
def find_duplicates(items: list[str]) -> list[tuple[int, int]]:
    duplicates = []
    for i, item_i in enumerate(items):  # Index and value together
        for j, item_j in enumerate(items[i + 1:], start=i + 1):
            if item_i == item_j:  # Direct comparison
                duplicates.append((i, j))
    return duplicates
```

**With custom start index:**

```python
# Line numbers typically start at 1
for line_num, line in enumerate(file_lines, start=1):
    if "ERROR" in line:
        print(f"Error on line {line_num}: {line}")
```

Reference: [enumerate documentation](https://docs.python.org/3/library/functions.html#enumerate)
