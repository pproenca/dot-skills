---
title: Collapse Strongly Connected Components Before Clustering
impact: CRITICAL
impactDescription: turns a tangled multigraph into a DAG and prevents clusters from being split mid-cycle
tags: graph, scc, tarjan, kosaraju, dag, cycles
---

## Collapse Strongly Connected Components Before Clustering

Most community-detection algorithms (Louvain, Leiden, Infomap) ignore edge direction. That's catastrophic when the codebase has dependency cycles — a Strongly Connected Component (SCC) by definition has a path from every node to every other node, so an undirected projection shows it as a dense blob. The algorithm will then either:

1. Put the whole SCC in one cluster (often correct, but you lose internal structure),
2. Split the SCC across clusters (almost always wrong — the cycle says "we are inseparable"),
3. Or worse, drift between (1) and (2) across runs, producing unstable clusterings.

The fix is mechanical and predates every clustering algorithm: **find SCCs with Tarjan's or Kosaraju's algorithm (O(V + E)), collapse each SCC to a single super-node, and you have a DAG**. Cluster the DAG; expand SCCs back at the end. This is the *condensation* of the graph, and it's been standard practice in compiler theory since the 1970s, but is almost never applied before community detection in software analysis.

**Incorrect (Louvain on a cyclic dependency graph — splits the cycle, hides the real structure):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

# A small but realistic cycle: 4 service modules tightly coupled in a circular
# import. Plus 6 unrelated utility files.
G = nx.DiGraph()
G.add_edges_from([
    ("auth/session", "auth/token"),
    ("auth/token", "auth/user"),
    ("auth/user", "auth/permissions"),
    ("auth/permissions", "auth/session"),  # closes the cycle
    ("auth/session", "auth/user"),
])
for u in range(6):
    G.add_edge(f"util/lib{u}", f"util/lib{(u+1) % 6}")

# Louvain ignores direction; the 4-cycle looks like 4 densely connected nodes.
# The algorithm cuts the cycle to maximise modularity Q — but the cut is
# arbitrary and changes across runs.
comms = nxc.louvain_communities(G.to_undirected(), seed=42)
print(comms)  # auth/session may be in a different cluster from auth/token
```

**Correct (Tarjan SCC → condense → cluster the DAG → expand):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

def collapse_sccs(G: nx.DiGraph):
    """
    Tarjan SCC in NetworkX (`strongly_connected_components`) runs in O(V+E)
    and returns the SCCs. We map each SCC to a representative super-node
    and rebuild the graph as a DAG.
    """
    sccs = list(nx.strongly_connected_components(G))
    member_to_scc = {}
    for i, scc in enumerate(sccs):
        rep = f"scc#{i}({len(scc)})" if len(scc) > 1 else next(iter(scc))
        for n in scc:
            member_to_scc[n] = rep

    H = nx.DiGraph()
    for u, v in G.edges():
        ru, rv = member_to_scc[u], member_to_scc[v]
        if ru != rv:  # drop intra-SCC edges (now self-loops)
            H.add_edge(ru, rv)
    return H, sccs, member_to_scc

H, sccs, mapping = collapse_sccs(G)
# H is now a DAG. Cluster it — every SCC is a single, indivisible node.
clusters = nxc.louvain_communities(H.to_undirected(), seed=42)

# Expand: each cluster gets every member of each SCC it contained.
expanded = []
for c in clusters:
    files = set()
    for super_node in c:
        # Find the SCC this super_node represents
        for scc in sccs:
            if any(mapping[m] == super_node for m in scc):
                files.update(scc)
                break
    expanded.append(files)
```

**Alternative (when SCCs are themselves huge — recursive condensation):**

```python
# In rare cases (e.g. circular dependencies in a 200-file God-package),
# a single SCC contains hundreds of files. You still want internal structure.
# Strategy: cluster INSIDE the SCC with an algorithm that respects direction
# (Infomap on directed graphs, or weighted by edge-betweenness), then place
# those sub-clusters in the parent decomposition.

def recursive_cluster(G: nx.DiGraph, max_scc: int = 50):
    H, sccs, mapping = collapse_sccs(G)
    outer = nxc.louvain_communities(H.to_undirected())

    refined = []
    for cluster in outer:
        files = set()
        for super_node in cluster:
            for scc in sccs:
                rep = mapping[next(iter(scc))]
                if rep == super_node:
                    if len(scc) > max_scc:
                        # Re-cluster the giant SCC with a direction-aware method
                        sub_G = G.subgraph(scc).copy()
                        sub_clusters = nxc.louvain_communities(sub_G.to_undirected())
                        refined.extend(sub_clusters)
                    else:
                        files.update(scc)
        if files:
            refined.append(files)
    return refined
```

**Why this is non-obvious:**

The SAR literature treats SCCs as a *quality signal* (cycles are bad) rather than a *preprocessing step*. Sarkar et al. (TSE 2009, "Discovery of Architectural Layers and Measurement of Layering Violations in Source Code") use SCC presence as a modularity penalty. But for the agent's job — finding domains — cycles aren't bad, they're *information*: a cycle says "these things are inseparable, treat them as one." Collapsing makes that explicit and stabilises every downstream algorithm.

**When NOT to collapse:**

- Co-change graphs are undirected by construction — there are no SCCs, only connected components.
- You're specifically reporting on cycles as architecture violations (DSM analysis, Lattix-style) — keep them visible.
- The whole codebase is one giant SCC (rare but happens in early-stage prototypes) — collapsing gives you a single node. Use spectral methods or recursive decomposition instead.

**Production:** GCC and LLVM both condense SCCs in the call graph before inlining decisions for exactly this reason — you cannot reason about ordering within a cycle. Java's `jdeps --cyclic` and Go's `go mod graph | tsort` reveal SCCs to developers.

Reference: [Tarjan, R. "Depth-first search and linear graph algorithms." SIAM J. Comput. 1972](https://epubs.siam.org/doi/10.1137/0201010)
