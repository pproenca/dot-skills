---
title: Use BFS For Unweighted Shortest Paths, Not Dijkstra
impact: HIGH
impactDescription: O((V+E) log V) Dijkstra to O(V+E) BFS — 5-50x faster
tags: graph, bfs, shortest-path, unweighted
---

## Use BFS For Unweighted Shortest Paths, Not Dijkstra

For graphs where every edge has the same weight (typically 1 — grids, social networks, unweighted state graphs), BFS finds shortest paths in O(V+E) with a plain FIFO queue. Dijkstra solves the more general weighted case in O((V+E) log V), which is strictly slower because of the heap operations. Reaching for Dijkstra when BFS suffices is a 5-50x slowdown depending on input size.

The diagnostic: are all edges weighted 1 (or any single constant)? Use BFS. Are weights 0 or 1 only? Use 0-1 BFS with a deque (push 0-weight to front, 1-weight to back) — still O(V+E).

**Incorrect (Dijkstra on unweighted grid — wastes the heap):**

```python
import heapq

def shortest_path_grid(grid, start, end):
    # All edges have weight 1. Heap log-factor is pure overhead here.
    R, C = len(grid), len(grid[0])
    dist = {start: 0}
    pq = [(0, start)]
    while pq:
        d, (r, c) = heapq.heappop(pq)
        if (r, c) == end: return d
        for dr, dc in ((-1,0),(1,0),(0,-1),(0,1)):
            nr, nc = r + dr, c + dc
            if 0 <= nr < R and 0 <= nc < C and grid[nr][nc] != "#":
                nd = d + 1
                if nd < dist.get((nr, nc), float("inf")):
                    dist[(nr, nc)] = nd
                    heapq.heappush(pq, (nd, (nr, nc)))
    return -1
```

**Correct (BFS — O(V+E) with a deque, no heap):**

```python
from collections import deque

def shortest_path_grid(grid, start, end):
    # Pure BFS: first time we dequeue a cell, its distance is optimal.
    R, C = len(grid), len(grid[0])
    if start == end: return 0
    visited = {start}
    queue = deque([(start, 0)])
    while queue:
        (r, c), d = queue.popleft()
        for dr, dc in ((-1,0),(1,0),(0,-1),(0,1)):
            nr, nc = r + dr, c + dc
            if 0 <= nr < R and 0 <= nc < C and grid[nr][nc] != "#" \
               and (nr, nc) not in visited:
                if (nr, nc) == end:
                    return d + 1
                visited.add((nr, nc))
                queue.append(((nr, nc), d + 1))
    return -1
```

**0-1 BFS** (when edges are weight 0 or 1):

```python
from collections import deque

def shortest_01(adj, src, dst):
    INF = float("inf")
    dist = {src: 0}
    dq = deque([src])
    while dq:
        u = dq.popleft()
        for v, w in adj[u]:
            nd = dist[u] + w
            if nd < dist.get(v, INF):
                dist[v] = nd
                # Weight 0 → front; weight 1 → back. Maintains BFS invariant.
                (dq.appendleft if w == 0 else dq.append)(v)
    return dist.get(dst, -1)
```

Reference: [cp-algorithms — Breadth-first search](https://cp-algorithms.com/graph/breadth-first-search.html)
