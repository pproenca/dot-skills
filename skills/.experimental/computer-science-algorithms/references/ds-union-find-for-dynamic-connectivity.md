---
title: Use Union-Find For Dynamic Connectivity And Grouping
impact: HIGH
impactDescription: O(n) per query to nearly O(1) amortized (inverse-Ackermann)
tags: ds, union-find, disjoint-set, dsu
---

## Use Union-Find For Dynamic Connectivity And Grouping

Whenever the problem asks "are these two things in the same group?" or "merge these two groups," the canonical answer is a disjoint-set union (DSU / Union-Find) with path compression and union-by-rank. Operations cost O(α(n)) amortized — inverse Ackermann, effectively constant for any input that fits in this universe. The naive alternative is a BFS/DFS over the current graph per query, which is O(V+E) each time — fine for one query, catastrophic for many.

Use DSU for: Kruskal's MST, connectivity queries on a growing graph, equivalence-class problems, Hoshen-Kopelman percolation, image segmentation.

**Incorrect (BFS per query, quadratic over q queries):**

```python
def connected_queries(n, edges, queries):
    adj = [[] for _ in range(n)]
    for u, v in edges:
        adj[u].append(v); adj[v].append(u)
    out = []
    for u, v in queries:
        # BFS from u to see if it reaches v — O(V+E) per query.
        seen = {u}; stack = [u]; found = False
        while stack:
            x = stack.pop()
            if x == v:
                found = True; break
            for y in adj[x]:
                if y not in seen:
                    seen.add(y); stack.append(y)
        out.append(found)
    return out
```

**Correct (DSU with path compression and union-by-rank):**

```python
class DSU:
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x: int) -> int:
        # Path compression: every node on the path points directly at the root.
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        # Union by rank keeps trees shallow.
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True

def connected_queries(n, edges, queries):
    dsu = DSU(n)
    for u, v in edges:
        dsu.union(u, v)
    return [dsu.find(u) == dsu.find(v) for u, v in queries]
```

**Both optimizations are required:** path compression alone gives O(log n) amortized; union-by-rank alone gives O(log n) worst case per op; together they give O(α(n)).

Reference: [CLRS Chapter 21 — Data Structures for Disjoint Sets](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
