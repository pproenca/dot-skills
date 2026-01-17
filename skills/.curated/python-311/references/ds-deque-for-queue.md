---
title: Use deque for O(1) Queue Operations
impact: CRITICAL
impactDescription: O(n) to O(1) for popleft
tags: ds, deque, queue, collections, performance
---

## Use deque for O(1) Queue Operations

List `pop(0)` is O(n) because all remaining elements must shift. `collections.deque` provides O(1) operations on both ends.

**Incorrect (O(n) popleft):**

```python
def process_tasks(tasks: list[str]) -> list[str]:
    queue = tasks.copy()
    results = []
    while queue:
        task = queue.pop(0)  # O(n) - shifts all elements left
        results.append(execute_task(task))
    return results
# n tasks × O(n) shift = O(n²) total
```

**Correct (O(1) popleft):**

```python
from collections import deque

def process_tasks(tasks: list[str]) -> list[str]:
    queue = deque(tasks)  # O(n) conversion once
    results = []
    while queue:
        task = queue.popleft()  # O(1) - doubly-linked list
        results.append(execute_task(task))
    return results
# n tasks × O(1) = O(n) total
```

**Benefits:**
- `appendleft()` and `popleft()` are O(1)
- `append()` and `pop()` are O(1)
- Thread-safe for single append/pop operations
- Optional `maxlen` for fixed-size buffers

Reference: [collections.deque documentation](https://docs.python.org/3/library/collections.html#collections.deque)
