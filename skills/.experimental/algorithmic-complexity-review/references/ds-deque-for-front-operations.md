---
title: Use a Deque for Front Insertions and Removals
impact: HIGH
impactDescription: O(n) per op to O(1) — flips queue/sliding-window code from quadratic to linear
tags: ds, deque, queue, sliding-window, front-insert
---

## Use a Deque for Front Insertions and Removals

`list.pop(0)`, `list.insert(0, x)`, `Array.prototype.shift`, and `Array.prototype.unshift` all run in O(n) because the underlying contiguous array must memmove every element one slot. Used inside a loop — say, a BFS dequeue or a sliding-window slide — they turn an O(n) algorithm into O(n²). A double-ended queue (`collections.deque` in Python, `ArrayDeque` in Java, `LinkedList` or a ring buffer in JS) supports both ends in O(1).

**Incorrect (list as a queue — O(n²) for n dequeues):**

```python
queue = list(initial_items)
while queue:
    item = queue.pop(0)            # O(n) shift of remaining elements
    for child in children(item):
        queue.append(child)
# n items dequeued → O(n²) total
```

**Correct (deque — O(n) total):**

```python
from collections import deque
queue = deque(initial_items)
while queue:
    item = queue.popleft()         # O(1)
    for child in children(item):
        queue.append(child)
```

**Alternative (sliding window over a stream):**

```python
from collections import deque
window = deque(maxlen=K)           # auto-evicts the oldest on append when full
for value in stream:
    window.append(value)           # O(1) — old element drops out for free
    process(window)
```

**When NOT to use this pattern:**
- When the queue is provably tiny (≲ ~30 items) and bounded — the constant factors of `deque` and `list` are similar; choose for readability.
- In JavaScript, when you need random access by index frequently — a deque library may not match `Array`'s indexed access; consider a ring buffer or two stacks if appropriate.

Reference: [Python `collections.deque` — O(1) appends and pops from either end](https://docs.python.org/3/library/collections.html#collections.deque)
