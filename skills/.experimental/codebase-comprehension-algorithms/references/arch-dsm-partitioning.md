---
title: Use Design Structure Matrix Partitioning To Find Block-Diagonal Architecture
impact: MEDIUM-HIGH
impactDescription: reduces architecture analysis to block-diagonal matrix inspection in O(V+E); reveals cycles and layers
tags: arch, dsm, design-structure-matrix, steward, eppinger, partitioning
---

## Use Design Structure Matrix Partitioning To Find Block-Diagonal Architecture

The **Design Structure Matrix (DSM)** — originally Steward's "design dependency matrix" (Steward, IEEE TEM 1981) and popularised in product engineering by **Eppinger (MIT, 1990s)** — represents a system as a **square N×N matrix** where row i, column j is "1" if element i depends on element j. The killer move is **partitioning / sequencing**: reorder rows and columns simultaneously so that the matrix becomes as **block-triangular** as possible. After reordering, the structure of the system becomes *visually obvious*:

- A **lower-triangular** DSM means a clean acyclic layering (presentation → service → repository, or kernel → drivers → apps).
- A **block-diagonal** DSM means independent subsystems.
- **Remaining elements above the diagonal** ("marks") are cycles — and they cluster into the smallest possible **squared blocks**, which are the strongly-connected components.

DSM analysis predates community detection by 30 years, is widely used in mechanical and systems engineering, and is **almost unknown in software**. MacCormack, Rusnak, Baldwin ("Exploring the structure of complex software designs: an empirical study of open source and proprietary code," HBS 2006) used DSM to compare architectures of Linux and Mozilla. Sangal et al. ("Using dependency models to manage complex software architecture," OOPSLA 2005) built **Lattix LDM**, the canonical DSM tool for software. Both showed DSM reveals layering and cycle structure modularity-based methods miss.

**Incorrect (community detection — finds groups but loses the order/layering):**

```python
import networkx.algorithms.community as nxc

G = build_dependency_graph("./src")
# Louvain gives 8 communities. But you cannot SEE the order between them —
# which layer feeds which, where the cycles are, what's a leaf utility.
# DSM gives all three at once via reordering.
clusters = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — build the DSM as an N×N matrix and assign initial order):**

```python
import numpy as np
import networkx as nx

def build_dsm(G):
    """
    Row i, col j = 1 if file i depends on file j.
    Convention varies — some authors use the transpose. Be consistent.
    """
    nodes = list(G.nodes())
    n = len(nodes)
    M = np.zeros((n, n), dtype=int)
    idx = {nd: i for i, nd in enumerate(nodes)}
    for u, v in G.edges():
        M[idx[u], idx[v]] = 1
    return M, nodes

M, nodes = build_dsm(G)
```

**Correct (Step 2 — partition: find SCCs and topological-sort the condensation):**

```python
def partition_dsm(G):
    """
    Steward's partitioning: condense to a DAG of SCCs, topologically sort
    the SCCs, then internally permute each multi-node SCC by some heuristic
    (degree, or recursive partitioning of the SCC's induced subgraph).
    Result: a node ordering that makes the DSM as block-triangular as possible.
    """
    # 1. SCC condensation: each node's SCC becomes a "block"
    sccs = list(nx.strongly_connected_components(G))
    node_to_scc = {n: i for i, scc in enumerate(sccs) for n in scc}

    # 2. Build condensation DAG
    cond = nx.DiGraph()
    cond.add_nodes_from(range(len(sccs)))
    for u, v in G.edges():
        if node_to_scc[u] != node_to_scc[v]:
            cond.add_edge(node_to_scc[u], node_to_scc[v])

    # 3. Topological sort of the condensation DAG
    topo_order = list(nx.topological_sort(cond))

    # 4. Emit the node permutation
    ordered_nodes = []
    for scc_id in topo_order:
        scc_members = sorted(sccs[scc_id])
        ordered_nodes.extend(scc_members)

    return ordered_nodes, sccs, topo_order
```

**Correct (Step 3 — reorder the DSM and identify the structural blocks):**

```python
def visualize_partitioned_dsm(M, nodes, ordered_nodes, sccs):
    """
    Reorder M according to ordered_nodes. Marks above the diagonal are
    feedback / cycles within SCCs; marks below are forward dependencies.
    A clean lower-triangular result means the codebase is acyclic.
    """
    node_idx = {n: i for i, n in enumerate(nodes)}
    perm = [node_idx[n] for n in ordered_nodes]
    M_reordered = M[np.ix_(perm, perm)]

    # SCC block boundaries
    block_boundaries = []
    cursor = 0
    for scc in sccs:
        if len(scc) > 1:
            block_boundaries.append((cursor, cursor + len(scc), len(scc)))
        cursor += len(scc)

    # Above-diagonal marks: cycles only inside SCC blocks
    above_diag = (M_reordered.astype(bool) & np.triu(np.ones_like(M_reordered, dtype=bool), k=1))
    return {
        "matrix": M_reordered,
        "ordered_nodes": ordered_nodes,
        "scc_blocks": block_boundaries,
        "feedback_marks": int(above_diag.sum()),
    }

result = visualize_partitioned_dsm(M, nodes, *partition_dsm(G)[:2:], partition_dsm(G)[1])
print(f"After partitioning: {result['feedback_marks']} feedback edges within SCC blocks")
print(f"{len(result['scc_blocks'])} SCC blocks; the rest is a clean DAG")
```

**Why DSM partitioning is uniquely valuable:**

A community-detection algorithm gives you a *set* of clusters. A DSM gives you:
1. **An ordering** of the entire codebase (what's upstream of what)
2. **Cycle visibility** — exactly where the feedback loops are, sized as blocks
3. **A graphical representation** that an architect can read in 30 seconds (especially with a tool that draws the matrix)
4. **A history-friendly representation** — DSM diffs across releases show whether you're growing or shrinking cycles

For agent-driven codebase comprehension, the DSM is the right *summary* once clustering has been done — it composes well with any of the other algorithms in this skill. Lattix specifically targets the "rules" extension: declare desired DSM topology (no upward marks!) and let CI enforce it.

**Empirical baseline:** MacCormack, Rusnak, Baldwin (2006) used DSM partitioning to compute "propagation cost" (a measure of how many components a change typically affects). Mozilla's pre-refactor propagation cost was 17.4%; post-refactor 2.7%. Linux's was 7.4%. Closed-source proprietary codebases averaged 25%+. DSM made these differences *visible* and *comparable* in a way modularity scores never could.

**When NOT to use:**

- Very large codebases (> 5,000 files) — DSM matrices become unreadable without heavy sub-sampling or hierarchical drill-down.
- Codebases without clear module boundaries — DSM at file granularity is too fine; DSM at package level is the usual sweet spot.
- Use cases where the *ordering* doesn't matter (e.g. you're computing pure feature similarity) — DSM's main value is the visualization.

**Production:** **Lattix LDM** (commercial) is the canonical software DSM tool — used at Microsoft, Boeing, Ford. Open-source alternatives: **DV-8** (Drexel), **NDepend** (commercial .NET), **PyDSM** for Python. MIT's DSM Forum maintains the academic discourse.

Reference: [Exploring the structure of complex software designs: an empirical study of open source and proprietary code (MacCormack, Rusnak, Baldwin, Management Science 2006)](https://www.hbs.edu/faculty/Pages/item.aspx?num=18039)
