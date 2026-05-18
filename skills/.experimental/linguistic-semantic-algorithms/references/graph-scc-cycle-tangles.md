---
title: Use Strongly Connected Components to Find Dependency Cycle Tangles
impact: HIGH
impactDescription: reveals every cyclic import group in O(V+E) — Tarjan's algorithm
tags: graph, scc, tarjan, cycles, dependency-tangles
---

## Use Strongly Connected Components to Find Dependency Cycle Tangles

A clean codebase has a directed acyclic dependency graph. A *real* codebase has cycles — `A.py` imports `B.py`, which imports `C.py`, which imports `A.py`. These cycles often hide behind multi-step paths and are invisible to "did you add a circular import?" linters. Tarjan's SCC algorithm finds every strongly-connected component (every maximal set of files where everyone can reach everyone) in O(V+E). Any SCC with size > 1 is a tangle — a cluster of files that must move together because they cannot be separated. Refactoring starts with knowing where the tangles are.

**Incorrect (catch cycles only when Python raises ImportError — most cycles hide):**

```python
# Python silently allows many "almost-circular" import patterns
# via deferred imports inside functions. The runtime never raises
# but the static graph has cycles. Waiting for ImportError misses
# 90%+ of real tangles.
try:
    import src.app                              # if it runs, "no cycles"
except ImportError as e:
    print("Cycle detected:", e)
```

**Correct (Tarjan's SCC on the static import graph — every tangle surfaces):**

```python
import ast, pathlib
import networkx as nx

G = nx.DiGraph()
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): str(p) for p in files}

for p in files:
    G.add_node(str(p))
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(str(p), mod_map[node.module])

# Tarjan finds SCCs in O(V + E)
sccs = [c for c in nx.strongly_connected_components(G) if len(c) > 1]
sccs.sort(key=len, reverse=True)

print(f"Found {len(sccs)} cycle tangles, largest has {len(sccs[0])} files")
for i, scc in enumerate(sccs[:5]):
    print(f"\nTangle {i} ({len(scc)} files):")
    for f in scc:
        # In-degree within the SCC = how many cycle-mates need this file
        in_within = sum(1 for u in G.predecessors(f) if u in scc)
        print(f"  in_within={in_within:>2}  {f}")
```

**Order tangles by size of SCC × external impact.** The biggest tangle is the most painful to break, but a small tangle right at the architectural core can cause more damage than a large peripheral one. Multiply tangle size by the sum of PageRank of its members for a "tangle priority" score.

**Pick the right cut.** Inside a tangle, run `nx.algorithms.minimum_edge_cut(scc_subgraph)` or compute edge betweenness within the SCC — the high-betweenness edges are the import statements to break first. This is the bridge to `graph-feedback-arcs`.

**Identify "false cycles" caused by re-exports.** Common pattern: `pkg/__init__.py` re-exports symbols from sub-modules, then sub-modules import from `pkg`. The cycle is a packaging accident, not a logical loop. Filter SCCs whose only edges go through `__init__.py` files before alerting.

**Combine with `mine-change-coupling`:** SCCs whose members ALSO change together are real coupling. SCCs whose members never change together are accidents of the static graph — usually safe to leave.

**When NOT to apply:**
- Languages where circular imports are intentional (Haskell modules) — SCCs aren't a defect signal there
- Codebases with heavy lazy imports — static analysis under-reports the graph; combine with runtime import tracing

Reference: [Tarjan, Depth-first search and linear graph algorithms (SIAM 1972)](https://epubs.siam.org/doi/10.1137/0201010), [NetworkX strongly_connected_components](https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.components.strongly_connected_components.html)
