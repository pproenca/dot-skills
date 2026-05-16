---
title: Represent Sparse Graphs As Adjacency Lists, Not Matrices
impact: MEDIUM-HIGH
impactDescription: O(V²) memory and per-iteration cost to O(V+E)
tags: graph, adjacency-list, representation, sparse
---

## Represent Sparse Graphs As Adjacency Lists, Not Matrices

An adjacency *matrix* uses V² memory and forces every traversal to scan all V neighbours of every node — O(V²) work regardless of how many edges exist. For sparse graphs (E = O(V) or O(V log V)), that's catastrophic: a road network with 10⁶ nodes and 10⁷ edges fits in ~80 MB as an adjacency list but needs 1 TB as a matrix. Adjacency *lists* store only the edges that exist, giving O(V+E) iteration.

The rule of thumb: prefer adjacency lists by default. Reach for a matrix only when (1) the graph is dense (E close to V²), or (2) the algorithm needs O(1) edge-existence queries (Floyd-Warshall, transitive closure), or (3) V is small (≤ ~1000).

**Incorrect (adjacency matrix on a sparse social graph — O(V²) BFS, O(V²) memory):**

```python
def shortest_hops_matrix(adj_matrix, src, dst):
    # Inner loop scans all V neighbours every step → O(V²) total, even if the
    # graph has only 5 edges per node.
    n = len(adj_matrix)
    from collections import deque
    visited = {src}
    queue = deque([(src, 0)])
    while queue:
        u, d = queue.popleft()
        if u == dst: return d
        for v in range(n):
            if adj_matrix[u][v] and v not in visited:
                visited.add(v); queue.append((v, d + 1))
    return -1
```

**Correct (adjacency list — O(V+E)):**

```python
def shortest_hops_list(adj: list[list[int]], src: int, dst: int) -> int:
    # Inner loop visits only actual neighbours. O(V+E) total.
    from collections import deque
    if src == dst: return 0
    visited = {src}
    queue = deque([(src, 0)])
    while queue:
        u, d = queue.popleft()
        for v in adj[u]:
            if v in visited: continue
            if v == dst: return d + 1
            visited.add(v); queue.append((v, d + 1))
    return -1
```

**Building an adjacency list from an edge list:**

```python
def build_adj(n: int, edges: list[tuple[int, int]]) -> list[list[int]]:
    adj: list[list[int]] = [[] for _ in range(n)]
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)  # omit for directed
    return adj
```

**When a matrix wins:**

- V ≤ ~500 and edges are dense (E > V²/4)
- The algorithm needs `is_edge(u, v)` in O(1) (Floyd-Warshall, max-flow with Edmonds-Karp on dense networks)
- A bitset adjacency matrix (each row is a packed `int`) gives O(V²/64) memory and SIMD-style "AND" for neighbour-of-neighbour queries

Reference: [Sedgewick & Wayne — Graphs](https://algs4.cs.princeton.edu/40graphs/)
