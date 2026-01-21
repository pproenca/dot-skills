---
title: Use itertools for Efficient Iteration Patterns
impact: MEDIUM
impactDescription: 2-3× faster iteration patterns
tags: loop, itertools, performance, iteration
---

## Use itertools for Efficient Iteration Patterns

The `itertools` module provides C-optimized functions for common iteration patterns, avoiding Python loop overhead.

**Incorrect (manual nested loops):**

```python
def generate_combinations(colors: list[str], sizes: list[str]) -> list[tuple]:
    result = []
    for color in colors:
        for size in sizes:
            result.append((color, size))
    return result
```

**Correct (itertools.product):**

```python
from itertools import product

def generate_combinations(colors: list[str], sizes: list[str]) -> list[tuple]:
    return list(product(colors, sizes))
```

**Common itertools patterns:**

```python
from itertools import chain, groupby, islice, batched

# Flatten nested lists (faster than nested comprehension)
flat = list(chain.from_iterable(nested_lists))

# Group consecutive items
for key, group in groupby(sorted(orders, key=lambda x: x["status"]), key=lambda x: x["status"]):
    print(f"{key}: {list(group)}")

# Slice iterators without loading all into memory
first_1000 = list(islice(huge_generator, 1000))

# Batch items (Python 3.12+)
for batch in batched(items, 100):
    process_batch(batch)
```

Reference: [itertools documentation](https://docs.python.org/3/library/itertools.html)
