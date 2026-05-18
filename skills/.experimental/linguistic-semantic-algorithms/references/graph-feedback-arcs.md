---
title: Approximate Minimum Feedback Arc Set to Choose the Smallest Cycle-Breaking Cut
impact: MEDIUM-HIGH
impactDescription: minimizes edits required to make the import graph acyclic
tags: graph, feedback-arc-set, cycle-breaking, refactoring, eades
---

## Approximate Minimum Feedback Arc Set to Choose the Smallest Cycle-Breaking Cut

Once `graph-scc-cycle-tangles` has found a tangle, the next question is: what is the smallest set of import statements I can delete (or invert) to make the tangle acyclic? That set is called a Feedback Arc Set, and finding the *minimum* is NP-hard. But the Eades–Lin–Smyth greedy approximation runs in O(V+E) and produces a feedback arc set within a small constant factor of optimum on real codebases. The output is a ranked list of edges to break — far more actionable than "this tangle has 12 files, good luck."

**Incorrect (delete an arbitrary edge in each cycle — often picks the wrong one):**

```python
# Find a cycle, delete any edge in it. Repeat until acyclic.
# Often breaks an edge that was the cheap one to keep and leaves
# the expensive ones. Result: more edits than necessary.
import networkx as nx

def break_cycles_naive(G: nx.DiGraph) -> list[tuple]:
    deleted = []
    try:
        while True:
            cycle = nx.find_cycle(G)
            G.remove_edge(*cycle[0])               # always the first edge
            deleted.append(cycle[0])
    except nx.NetworkXNoCycle:
        return deleted
```

**Correct (Eades–Lin–Smyth greedy — minimum-ish FAS in linear time):**

```python
import networkx as nx
from collections import deque

def eades_feedback_arc_set(G: nx.DiGraph) -> list[tuple]:
    """
    Eades, Lin, Smyth (1993): A fast and effective heuristic for the FAS problem.
    Repeatedly pull sinks, then sources, then highest delta(v) = outdeg - indeg.
    Edges to delete = edges going "backward" in the resulting ordering.
    """
    H = G.copy()
    s1: deque[str] = deque()
    s2: deque[str] = deque()
    while H.number_of_nodes() > 0:
        # Sinks: out-degree 0 -> append to s2 from the right
        while True:
            sinks = [v for v in H if H.out_degree(v) == 0]
            if not sinks: break
            for v in sinks: s2.appendleft(v); H.remove_node(v)
        # Sources: in-degree 0 -> append to s1
        while True:
            sources = [v for v in H if H.in_degree(v) == 0]
            if not sources: break
            for v in sources: s1.append(v); H.remove_node(v)
        if H.number_of_nodes() == 0: break
        # Otherwise: pick max delta(v)
        v = max(H, key=lambda x: H.out_degree(x) - H.in_degree(x))
        s1.append(v); H.remove_node(v)

    ordering = list(s1) + list(s2)
    pos = {v: i for i, v in enumerate(ordering)}
    return [(u, v) for u, v in G.edges() if pos[u] > pos[v]]    # backward edges

# Usage on a tangle
import ast, pathlib
G = nx.DiGraph()
# ... build import graph as before ...
sccs = [c for c in nx.strongly_connected_components(G) if len(c) > 1]
worst = max(sccs, key=len)
sub = G.subgraph(worst).copy()

cut = eades_feedback_arc_set(sub)
print(f"Tangle has {sub.number_of_edges()} edges; breaking {len(cut)} makes it acyclic.")
for u, v in cut:
    print(f"  break: {u}  -- imports -->  {v}")
```

**Weight edges by cost-of-breaking** to bias the cut toward cheap edges to remove. A useful weight: number of identifiers actually imported from the module. Edges that import many symbols are harder to break (you'd have to provide alternatives for each); edges importing one symbol are cheap. Apply the weight by duplicating cheap edges or by replacing the greedy delta with a weighted variant.

**Use the inverse of the FAS as a refactor plan.** The ordering produced by Eades-Lin-Smyth is the dependency order you should aim for *after* the refactor. Files near the start of the ordering should depend on nothing in the tangle; files near the end depend on everything. Make the ordering match physical module layout.

**Combine with `graph-betweenness-bottlenecks`:** edges in the FAS that are also high in edge-betweenness are doubly motivated to delete — they break cycles AND reduce graph fragility.

**When NOT to apply:**
- Tangles under 4-5 files — eyeballing the cycle and picking by hand is faster
- Cycles you can't break by edge removal (legitimate mutual recursion) — use dependency inversion (interfaces) instead; FAS gives the answer but you implement it differently

Reference: [Eades, Lin, Smyth, A fast and effective heuristic for the feedback arc set problem (1993)](https://www.sciencedirect.com/science/article/pii/002001909390079O), [Berger & Shor, Approximation algorithms for the maximum acyclic subgraph problem (1990)](https://dl.acm.org/doi/10.5555/313559.313601)
