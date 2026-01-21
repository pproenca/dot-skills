---
title: Hoist Loop-Invariant Computations
impact: MEDIUM
impactDescription: avoids N× redundant work
tags: loop, optimization, invariant, hoisting
---

## Hoist Loop-Invariant Computations

Computations that don't change between iterations should be moved outside the loop to avoid repeating the same work N times.

**Incorrect (recomputes constant every iteration):**

```python
def apply_discount(prices: list[float], discount_code: str) -> list[float]:
    result = []
    for price in prices:
        discount = get_discount_rate(discount_code)  # Same result every time
        threshold = calculate_threshold(discount)  # Same result every time
        if price > threshold:
            result.append(price * (1 - discount))
        else:
            result.append(price)
    return result
# 10,000 prices × 2 function calls = 20,000 redundant calls
```

**Correct (compute once before loop):**

```python
def apply_discount(prices: list[float], discount_code: str) -> list[float]:
    discount = get_discount_rate(discount_code)  # Computed once
    threshold = calculate_threshold(discount)  # Computed once
    result = []
    for price in prices:
        if price > threshold:
            result.append(price * (1 - discount))
        else:
            result.append(price)
    return result
# 10,000 prices × 0 redundant calls
```

**Also hoist attribute lookups:**

```python
# Before (attribute lookup each iteration)
for item in items:
    self.processor.transform(item)

# After (single lookup)
transform = self.processor.transform
for item in items:
    transform(item)
```

Reference: [Python Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)
