---
title: Use bisect for O(log n) Sorted List Operations
impact: CRITICAL
impactDescription: O(n) to O(log n) search
tags: ds, bisect, binary-search, sorted-list
---

## Use bisect for O(log n) Sorted List Operations

Linear search through a sorted list wastes the sorted property. The `bisect` module provides O(log n) binary search operations.

**Incorrect (O(n) linear search):**

```python
def find_price_tier(price: float, thresholds: list[float]) -> int:
    # thresholds = [10.0, 25.0, 50.0, 100.0, 250.0] (sorted)
    tier = 0
    for i, threshold in enumerate(thresholds):  # O(n) scan
        if price >= threshold:
            tier = i + 1
        else:
            break
    return tier
```

**Correct (O(log n) binary search):**

```python
import bisect

def find_price_tier(price: float, thresholds: list[float]) -> int:
    # thresholds = [10.0, 25.0, 50.0, 100.0, 250.0] (sorted)
    return bisect.bisect_right(thresholds, price)  # O(log n)
```

**Alternative (maintaining sorted order):**

```python
import bisect

def add_score_sorted(scores: list[int], new_score: int) -> None:
    bisect.insort(scores, new_score)  # O(n) insert but maintains order
    # Better than: scores.append(new_score); scores.sort()  # O(n log n)
```

**Note:** `bisect_left` finds leftmost position, `bisect_right` finds rightmost for equal values.

Reference: [bisect documentation](https://docs.python.org/3/library/bisect.html)
