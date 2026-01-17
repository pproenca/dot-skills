---
title: Use Generators for Large Sequences
impact: HIGH
impactDescription: 100-1000× memory reduction
tags: mem, generators, lazy-evaluation, yield
---

## Use Generators for Large Sequences

Lists store all elements in memory simultaneously. Generators produce values on-demand, using constant memory regardless of sequence size.

**Incorrect (loads entire dataset into memory):**

```python
def process_large_file(filepath: str) -> list[dict]:
    with open(filepath) as f:
        lines = f.readlines()  # Loads entire file into memory

    results = []
    for line in lines:
        parsed = parse_line(line)
        if parsed["status"] == "active":
            results.append(transform(parsed))
    return results
# 1GB file = 1GB+ memory usage
```

**Correct (constant memory usage):**

```python
def process_large_file(filepath: str):
    with open(filepath) as f:
        for line in f:  # Yields one line at a time
            parsed = parse_line(line)
            if parsed["status"] == "active":
                yield transform(parsed)
# 1GB file = ~100KB memory usage

# Use the generator
for result in process_large_file("data.csv"):
    save_to_database(result)
```

**Alternative (generator expression):**

```python
def get_active_users(users: list[dict]):
    return (user for user in users if user["status"] == "active")
    # Generator expression uses minimal memory
```

**When NOT to use generators:**
- When you need random access to elements
- When you need to iterate multiple times

Reference: [Python Wiki - Generators](https://wiki.python.org/moin/Generators)
