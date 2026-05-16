---
title: Detect Cycles With DFS Colours, Not "Visited" Alone
impact: MEDIUM-HIGH
impactDescription: prevents wrong cycle answers and infinite recursion bugs
tags: graph, dfs, cycle-detection, three-color
---

## Detect Cycles With DFS Colours, Not "Visited" Alone

A single `visited` set is not enough to detect cycles in a directed graph — it conflates "we've fully explored this node" with "this node is in our current DFS stack." A node already visited via a different DFS branch is *not* a cycle. The three-colour scheme (WHITE = unseen, GRAY = on stack, BLACK = done) is the canonical fix: a back-edge to a GRAY node is a cycle; an edge to a BLACK node is not. For *undirected* graphs, instead track the parent and ignore the edge back to it.

Conflating these is a frequent source of false positives (BLACK nodes flagged as cycles) and false negatives (forgetting that a GRAY node is a back-edge target).

**Incorrect (single visited set on directed graph — false positives):**

```python
def has_cycle(adj):
    visited = set()
    def dfs(u):
        if u in visited: return True     # ← wrong: BLACK node is fine, not a cycle
        visited.add(u)
        return any(dfs(v) for v in adj[u])
    return any(dfs(u) for u in range(len(adj)) if u not in visited)
```

**Correct (three-colour DFS for directed cycle detection):**

```python
def has_cycle_directed(adj: list[list[int]]) -> bool:
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * len(adj)

    def dfs(u: int) -> bool:
        color[u] = GRAY
        for v in adj[u]:
            if color[v] == GRAY:         # back-edge to ancestor → cycle
                return True
            if color[v] == WHITE and dfs(v):
                return True
        color[u] = BLACK
        return False

    return any(color[u] == WHITE and dfs(u) for u in range(len(adj)))
```

**Undirected variant** (track parent — don't follow the edge you came in on):

```python
def has_cycle_undirected(adj: list[list[int]]) -> bool:
    visited = [False] * len(adj)
    def dfs(u: int, parent: int) -> bool:
        visited[u] = True
        for v in adj[u]:
            if not visited[v]:
                if dfs(v, u): return True
            elif v != parent:            # visited neighbour that isn't where we came from
                return True
        return False
    return any(not visited[u] and dfs(u, -1) for u in range(len(adj)))
```

**Recursion-depth note:** Python's default recursion limit is 1000. For deep graphs (chains of length 10⁵), either iterate with an explicit stack or `sys.setrecursionlimit(10**6)` AND raise the thread stack size (`threading.stack_size`).

Reference: [CLRS Chapter 22 — Elementary Graph Algorithms](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
