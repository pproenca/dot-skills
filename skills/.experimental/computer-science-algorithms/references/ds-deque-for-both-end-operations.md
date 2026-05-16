---
title: Use A Deque For Both-End Operations, Not List Pop-From-Front
impact: HIGH
impactDescription: O(n) per pop-front to O(1) — 100-1000x on queue-heavy workloads
tags: ds, deque, queue, bfs
---

## Use A Deque For Both-End Operations, Not List Pop-From-Front

`list.pop(0)` in Python (and array-shift equivalents in other languages) is O(n) because every remaining element shifts down one slot. When this is the queue operation in a BFS or sliding-window algorithm, you've turned an O(n) algorithm into O(n²). A double-ended queue (`collections.deque`, `std::deque`, `ArrayDeque`) gives O(1) at both ends.

Reach for a deque whenever you append on one end and remove from the other (FIFO queue) or when sliding-window algorithms need cheap pops from the head.

**Incorrect (BFS using `list.pop(0)` — O(V²) instead of O(V+E)):**

```python
def bfs(start, adj):
    # Each `queue.pop(0)` is O(|queue|). With V vertices, that's O(V²) total.
    queue = [start]
    visited = {start}
    while queue:
        node = queue.pop(0)  # ← linear in queue size
        for n in adj[node]:
            if n not in visited:
                visited.add(n)
                queue.append(n)
    return visited
```

**Correct (deque — O(V+E) BFS):**

```python
from collections import deque

def bfs(start, adj):
    # deque.popleft() is O(1). BFS is now O(V+E) as it should be.
    queue = deque([start])
    visited = {start}
    while queue:
        node = queue.popleft()
        for n in adj[node]:
            if n not in visited:
                visited.add(n)
                queue.append(n)
    return visited
```

**Sliding window minimum / maximum:**

A monotonic deque is the canonical O(n) algorithm for "find the min/max in every window of size k." Each index enters and leaves the deque at most once.

**Language equivalents:**

- Python: `collections.deque`
- C++: `std::deque` (or `std::queue` adapter)
- Java: `ArrayDeque` (prefer over `LinkedList`)
- Go: container/list or a circular buffer

Reference: [Python docs — collections.deque](https://docs.python.org/3/library/collections.html#collections.deque)
