---
title: Keep Metric Computation Near-Linear, Not NP-Hard
impact: HIGH
impactDescription: prevents an NP-hard definition that can't run per commit (target O(V+E))
tags: comp, tractability, np-hard, approximation
---

## Keep Metric Computation Near-Linear, Not NP-Hard

A metric an agent computes on every edit must be cheap, or it will not run at the cadence it is needed. Many natural metric definitions hide an NP-hard optimization — "minimum set of edges to cut to isolate this module," "largest common subtree across all functions," "optimal clustering" — that cannot be computed exactly at scale. Choose a proxy with a known polynomial (ideally near-linear) algorithm, or an approximation with a proven ratio, and state the complexity in the spec so reviewers can see it scales.

**Incorrect (NP-hard definition computed per commit):**

```python
# coupling = size of the minimum edge set whose removal isolates the module.
# Multiway (multi-terminal) cut is NP-hard; this will not finish on a real dependency graph.
def coupling(module, dep_graph):
    return minimum_multiway_cut(dep_graph, terminals=module.boundary)   # NP-hard
```

**Correct (polynomial proxy, complexity stated):**

```python
# Proxy: fraction of a module's dependency edges that cross its boundary. O(V + E).
def coupling(module, dep_graph):
    crossing = sum(1 for u, v in dep_graph.edges if crosses(module, u, v))
    internal = sum(1 for u, v in dep_graph.edges if inside(module, u, v))
    return crossing / (crossing + internal + 1)   # O(E), deterministic, bounded in [0, 1)
```

**When an exact optimum is unavoidable:** use an approximation algorithm with a proven ratio (e.g., a 2-approximation) and report the ratio next to the value, so consumers know the slack.

Reference: [Garey & Johnson, *Computers and Intractability: A Guide to the Theory of NP-Completeness*](https://dl.acm.org/doi/book/10.5555/574848)
