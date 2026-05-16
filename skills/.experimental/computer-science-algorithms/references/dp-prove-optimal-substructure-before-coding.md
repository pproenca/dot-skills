---
title: Prove Optimal Substructure Before Writing The DP
impact: MEDIUM-HIGH
impactDescription: prevents shipping DPs that produce subtly wrong answers
tags: dp, correctness, optimal-substructure, proof
---

## Prove Optimal Substructure Before Writing The DP

DP requires *optimal substructure*: the optimal answer to a problem must be expressible in terms of optimal answers to subproblems. If this property doesn't hold, your recurrence will be wrong on some inputs — and the bug is invisible until adversarial cases hit production. The classic failure mode: greedy-shaped problems where the locally-optimal choice rules out the globally-optimal one further down.

Before coding, write down: (1) the subproblem definition, (2) why the optimal solution of the full problem must use the optimal solution of *some* subproblem, (3) which subproblem to combine. If step (2) is hand-wavy, the DP is unsound.

**Incorrect (DP that lacks optimal substructure — longest *simple* path on a general graph):**

```python
def longest_simple_path(graph, start, end):
    # Sounds like a DP: longest path from u = 1 + max(longest path from each neighbor).
    # WRONG — the neighbor's "longest path" might reuse nodes that the caller has
    # already visited, so combining optima doesn't yield a simple path.
    # (Longest-simple-path is NP-hard for a reason.)
    from functools import cache
    @cache
    def f(u):
        if u == end: return 0
        return 1 + max((f(v) for v in graph[u]), default=-float("inf"))
    return f(start)
```

**Correct (DP only when optimal substructure holds — longest path in a DAG):**

```python
def longest_path_dag(graph, start, end):
    # In a DAG, "longest path from u to end" depends only on `u` (no node revisit
    # is possible). Optimal substructure holds — DP is sound.
    from functools import cache
    @cache
    def f(u):
        if u == end: return 0
        return 1 + max((f(v) for v in graph[u]), default=-float("inf"))
    return f(start)
```

**Common substructure-failure smells:**

- The subproblem depends on a path / set of nodes already used elsewhere (e.g. longest simple path, Hamiltonian)
- The decision at one stage forecloses choices at distant stages in unpredictable ways
- The problem is known NP-hard (TSP, set cover, bin packing) — DP only works with subset-of-the-state in the state itself (bitmask DP), or as an approximation

**When DP doesn't apply, look for:** branch-and-bound, ILP, approximation algorithms, or accept exponential blowup on small inputs.

Reference: [CLRS Chapter 14, §14.3 — Elements of Dynamic Programming](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
