---
title: Use Kruskal Or Prim For Minimum Spanning Trees
impact: MEDIUM
impactDescription: O(E log E) — the only practical algorithms for MST on real graphs
tags: graph, mst, kruskal, prim
---

## Use Kruskal Or Prim For Minimum Spanning Trees

When the problem is "connect all nodes with minimum total edge weight," the answer is a minimum spanning tree. Two greedy algorithms are canonical: **Kruskal** sorts edges by weight and adds them if they don't form a cycle (uses Union-Find — O(E log E)). **Prim** grows the tree from a starting node, picking the cheapest crossing edge each step (uses a heap — O((V+E) log V)). Both produce an optimal MST; both run in essentially O(E log V).

Pick Kruskal when the graph is given as an edge list — it's the more natural fit. Pick Prim when the graph is given as adjacency lists and is dense, or when you only need an MST starting from a particular node.

**Incorrect (enumerate edge subsets, exponential blowup):**

```python
# 2^E subsets of edges; checking each for "spans + cheapest" is O(V α(V)).
# Even for tiny graphs (V = 20, E = 50) this is infeasible.
from itertools import combinations
def mst_brute(n, edges):
    best = float("inf")
    for size in range(n - 1, len(edges) + 1):
        for subset in combinations(edges, size):
            # check connectivity, sum weights ... O(2^E) total
            ...
    return best
```

**Correct (Kruskal with Union-Find):**

```python
class DSU:
    def __init__(self, n):
        self.p = list(range(n)); self.r = [0]*n
    def find(self, x):
        while self.p[x] != x:
            self.p[x] = self.p[self.p[x]]; x = self.p[x]
        return x
    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra == rb: return False
        if self.r[ra] < self.r[rb]: ra, rb = rb, ra
        self.p[rb] = ra
        if self.r[ra] == self.r[rb]: self.r[ra] += 1
        return True

def kruskal(n: int, edges: list[tuple[int, int, int]]) -> int:
    # edges: (weight, u, v). Returns total MST weight.
    dsu = DSU(n)
    total = 0
    for w, u, v in sorted(edges):       # O(E log E)
        if dsu.union(u, v):             # O(α(V))
            total += w
    return total
```

**Alternative (Prim with a heap):**

```python
import heapq

def prim(adj: list[list[tuple[int, int]]]) -> int:
    # adj[u] = [(v, w), ...]
    n = len(adj)
    in_mst = [False] * n
    pq: list[tuple[int, int]] = [(0, 0)]  # (weight, vertex), start at 0
    total = 0
    seen = 0
    while pq and seen < n:
        w, u = heapq.heappop(pq)
        if in_mst[u]:
            continue
        in_mst[u] = True
        total += w
        seen += 1
        for v, ew in adj[u]:
            if not in_mst[v]:
                heapq.heappush(pq, (ew, v))
    return total if seen == n else float("inf")
```

**Both algorithms are greedy and optimal because MSTs satisfy the *cut property*:** the cheapest edge crossing any cut belongs to some MST. Greedy never has to backtrack.

Reference: [cp-algorithms — Minimum spanning tree](https://cp-algorithms.com/graph/mst_kruskal.html)
