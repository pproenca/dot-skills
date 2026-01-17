---
title: Use Set for O(1) Membership Testing
impact: CRITICAL
impactDescription: O(n) to O(1) lookup
tags: ds, set, membership, lookup, performance
---

## Use Set for O(1) Membership Testing

List membership testing with `in` is O(n), scanning every element. Set membership is O(1) using hash lookup, making it 100× faster for large collections.

**Incorrect (O(n) per lookup):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    result = []
    for user_id in user_ids:
        if user_id in valid_ids:  # O(n) scan on every iteration
            result.append(user_id)
    return result
# 10,000 users × 10,000 valid IDs = 100M comparisons
```

**Correct (O(1) per lookup):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    valid_set = set(valid_ids)  # One-time O(n) conversion
    result = []
    for user_id in user_ids:
        if user_id in valid_set:  # O(1) hash lookup
            result.append(user_id)
    return result
# 10,000 users × O(1) = 10,000 operations
```

**Even better (comprehension):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    valid_set = set(valid_ids)
    return [user_id for user_id in user_ids if user_id in valid_set]
```

Reference: [Python Wiki - Time Complexity](https://wiki.python.org/moin/TimeComplexity)
