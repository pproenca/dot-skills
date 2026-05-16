---
title: Use Dijkstra With A Heap For Non-Negative Weighted Shortest Paths
impact: HIGH
impactDescription: O(V·E) Bellman-Ford to O((V+E) log V) — orders of magnitude on dense graphs
tags: graph, dijkstra, shortest-path, heap
---

## Use Dijkstra With A Heap For Non-Negative Weighted Shortest Paths

For weighted graphs with non-negative edge weights, Dijkstra's algorithm with a binary heap runs in O((V+E) log V). It's strictly faster than Bellman-Ford's O(V·E) and is the right default for road networks, network routing, and any "weighted shortest distance" question. The two failure modes to recognize: **(1) negative edge weights** break Dijkstra silently (it commits to nodes too early and never revisits) — use Bellman-Ford or SPFA. **(2) Bidirectional A\*** can be dramatically faster when a good heuristic exists, but plain Dijkstra is the safe default.

The standard implementation uses lazy deletion: push every relaxation onto the heap; skip popped entries whose distance is stale. This is simpler than a decrease-key heap and almost as fast.

**Incorrect (Bellman-Ford on a graph with all non-negative weights — O(V·E) wasted):**

```python
def bellman_ford(n, edges, src):
    # O(V·E) — runs V-1 relaxation passes. For dense graphs that's ~V³.
    dist = [float("inf")] * n
    dist[src] = 0
    for _ in range(n - 1):
        for u, v, w in edges:
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
    return dist
```

**Correct (Dijkstra with lazy deletion):**

```python
import heapq

def dijkstra(adj: list[list[tuple[int, int]]], src: int) -> list[float]:
    # adj[u] = [(v, w), ...]. All w >= 0.
    n = len(adj)
    dist = [float("inf")] * n
    dist[src] = 0
    pq = [(0, src)]
    while pq:
        d, u = heapq.heappop(pq)
        if d > dist[u]:
            continue  # lazy-deleted stale entry
        for v, w in adj[u]:
            nd = d + w
            if nd < dist[v]:
                dist[v] = nd
                heapq.heappush(pq, (nd, v))
    return dist
```

**When you have a heuristic (e.g. Euclidean distance for road graphs), use A\*:**

```python
import heapq

def a_star(adj, h, src, dst):
    g = {src: 0}
    pq = [(h(src), 0, src)]
    while pq:
        _, gu, u = heapq.heappop(pq)
        if u == dst: return gu
        if gu > g.get(u, float("inf")): continue
        for v, w in adj[u]:
            ng = gu + w
            if ng < g.get(v, float("inf")):
                g[v] = ng
                heapq.heappush(pq, (ng + h(v), ng, v))
    return float("inf")
```

**Hard constraints:**

- Dijkstra requires non-negative weights. Period. A single -1 edge silently breaks it.
- For all-pairs shortest paths on small dense graphs (V ≤ ~400), Floyd-Warshall O(V³) is simpler and often faster than V × Dijkstra.

Reference: [cp-algorithms — Dijkstra Algorithm](https://cp-algorithms.com/graph/dijkstra.html)
