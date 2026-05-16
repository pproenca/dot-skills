---
title: Use Topological Sort For Dependency Ordering And DAG DP
impact: HIGH
impactDescription: O(V+E) — enables linear-time DP on DAGs and reliable cycle detection
tags: graph, topological-sort, dag, kahn
---

## Use Topological Sort For Dependency Ordering And DAG DP

Whenever the input is "things with prerequisites" (build targets, task scheduling, course planning, expression evaluation, package install order), the right primitive is topological sort. Kahn's algorithm runs in O(V+E), processes nodes once their in-degree hits zero, and detects cycles as a free side effect (any unprocessed node means a cycle). After sorting, DP on a DAG runs in linear time because subproblem dependencies are guaranteed to be resolved before any node is visited.

Don't write ad-hoc "process the smallest first" loops; they're slower and miss cycles silently.

**Incorrect (ad-hoc dependency resolution — O(V²) and cycle bugs):**

```python
def build_order(tasks, deps):
    # deps[u] = list of prerequisites of u.
    # O(V²) — every pass scans everything; cycle yields infinite loop.
    done, order = set(), []
    while len(done) < len(tasks):
        progress = False
        for t in tasks:
            if t in done: continue
            if all(d in done for d in deps[t]):
                done.add(t); order.append(t); progress = True
        if not progress:
            raise RuntimeError("cycle? infinite loop")
    return order
```

**Correct (Kahn's algorithm — O(V+E), detects cycles):**

```python
from collections import deque

def topological_sort(n: int, edges: list[tuple[int, int]]) -> list[int] | None:
    # edges (u, v) mean "u must come before v". Returns None if a cycle exists.
    adj: list[list[int]] = [[] for _ in range(n)]
    indeg = [0] * n
    for u, v in edges:
        adj[u].append(v)
        indeg[v] += 1
    queue = deque(i for i, d in enumerate(indeg) if d == 0)
    order = []
    while queue:
        u = queue.popleft()
        order.append(u)
        for v in adj[u]:
            indeg[v] -= 1
            if indeg[v] == 0:
                queue.append(v)
    return order if len(order) == n else None  # None ⇒ cycle
```

**DP on a DAG** (once you have the topological order, every recurrence becomes linear):

```python
def longest_path_in_dag(n, edges, weight):
    order = topological_sort(n, edges)
    if order is None:
        raise ValueError("not a DAG")
    adj: list[list[tuple[int, int]]] = [[] for _ in range(n)]
    for (u, v), w in zip(edges, weight):
        adj[u].append((v, w))
    dist = [0] * n
    for u in order:                      # nodes appear after their dependencies
        for v, w in adj[u]:
            if dist[u] + w > dist[v]:
                dist[v] = dist[u] + w
    return max(dist)
```

**DFS-based topo sort** is also O(V+E) and uses post-order; Kahn's version is preferred when you also need cycle detection or want to process in BFS-like waves (e.g. layer-by-layer parallelism).

Reference: [cp-algorithms — Topological sorting](https://cp-algorithms.com/graph/topological-sort.html)
