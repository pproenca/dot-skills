---
title: Use Stochastic Block Models For Principled Bayesian Decomposition
impact: HIGH
impactDescription: NMI 0.7-0.9 vs 0.1 for modularity on non-assortative structure (Peixoto 2014); eliminates resolution limit
tags: clust, sbm, bayesian, peixoto, mdl, graph-tool
---

## Use Stochastic Block Models For Principled Bayesian Decomposition

Most community detection picks a number of clusters explicitly or implicitly via a resolution parameter — wrong, the result depends on a knob you didn't know how to set. **Stochastic Block Models** treat the graph as drawn from a generative process where each node belongs to one of k blocks and the probability of an edge between two nodes depends only on their blocks. Fitting an SBM means recovering both the block assignments AND the inter-block edge-probability matrix — and **Peixoto's hierarchical SBM** (Peixoto, 2014 onward; canonical reference: "Bayesian stochastic blockmodeling," 2017) uses a **Minimum Description Length** prior so the model self-selects k. There is no number-of-clusters parameter to tune.

SBMs also detect *structures other than communities*: bipartite structure ("nodes in block A only connect to block B"), core-periphery, hub-and-spoke. Modularity-based methods can't see these patterns because they're explicitly designed for assortative structure. In software, this matters: a layered architecture (controllers → services → repositories) is *disassortative* between layers — and modularity finds it badly.

**Incorrect (Leiden on a layered architecture — collapses layers into one cluster per feature):**

```python
import igraph as ig
import leidenalg

g = build_dependency_graph("./src")
# A clean MVC codebase has controllers calling services calling repos.
# Leiden finds the modularity-optimal partition: each feature (user, payment,
# order) is one cluster spanning controller + service + repo. Real but not
# useful — you wanted to see the layer structure too.
part = leidenalg.find_partition(g, leidenalg.RBConfigurationVertexPartition)
```

**Correct (Step 1 — hierarchical SBM via `graph-tool`):**

```python
import graph_tool.all as gt
# `graph-tool` is the reference implementation. Install with conda:
#   conda install -c conda-forge graph-tool

def build_gt_graph(G_nx):
    g = gt.Graph(directed=G_nx.is_directed())
    name_to_v = {}
    name_prop = g.new_vertex_property("string")
    for n in G_nx.nodes():
        v = g.add_vertex()
        name_to_v[n] = v
        name_prop[v] = str(n)
    g.vp["name"] = name_prop
    weight_prop = g.new_edge_property("double")
    for u, v, d in G_nx.edges(data=True):
        e = g.add_edge(name_to_v[u], name_to_v[v])
        weight_prop[e] = d.get("weight", 1.0)
    g.ep["weight"] = weight_prop
    return g

g = build_gt_graph(G_nx)
# Fit: MDL-regularised, hierarchical, degree-corrected (important on
# real graphs where degree distributions are heavy-tailed).
state = gt.minimize_nested_blockmodel_dl(g, state_args=dict(deg_corr=True))
```

**Correct (Step 2 — extract levels of the hierarchy):**

```python
def extract_sbm_hierarchy(state, g):
    """
    The hierarchical SBM returns a tree: level 0 = finest partition,
    level L = root (whole graph). At each level, every node has a block id.
    Higher levels group lower-level blocks together.
    """
    levels = state.get_levels()
    hierarchy = []
    for lvl, sub_state in enumerate(levels):
        blocks = sub_state.get_blocks()
        if max(blocks) <= 0:
            break
        block_assignments = {}
        for v in g.vertices():
            block_assignments[g.vp["name"][v]] = blocks[v]
        n_blocks = len(set(block_assignments.values()))
        hierarchy.append({"level": lvl, "n_blocks": n_blocks, "assignments": block_assignments})
    return hierarchy

hierarchy = extract_sbm_hierarchy(state, g)
print(f"Hierarchy has {len(hierarchy)} levels, "
      f"{hierarchy[0]['n_blocks']} blocks at the finest level")
# A real codebase: ~30 blocks at level 0 (file groups), ~8 at level 1
# (subsystems), ~3 at level 2 (top-level partitions).
```

**Correct (Step 3 — inspect block-block edge probabilities for architectural structure):**

```python
# The SBM exposes the block-affinity matrix — which blocks tend to connect
# to which. This reveals layered / hub-spoke structure that modularity hides.
def block_affinity(state):
    """
    M[i,j] = expected edges between block i and block j under the fitted SBM.
    Off-diagonal mass = disassortative (layered) structure;
    on-diagonal mass = assortative (community) structure.
    """
    return state.levels[0].get_matrix().toarray()

M = block_affinity(state)
# Normalised: M_ij / sqrt(deg_i * deg_j) is a "z-score" of attraction.
# In a layered architecture, the matrix is block-tridiagonal: layer i
# connects strongly to i-1 and i+1, weakly to others.
```

**Why this is the right tool when you suspect structure isn't pure assortative:**

The SBM is a **generative model**: it can be *checked* (does the data look like it was generated this way?), *compared* (which SBM variant fits best? — by description length), and *sampled* (does a sampled graph look like the real one?). Modularity is a *score*: you can rank partitions but can't ask whether modularity is even the right structure to look for.

**Empirical baseline:** Peixoto (PRX 2014) shows that on graphs with non-assortative structure, modularity-based methods produce decompositions with **NMI ≈ 0.1 against ground truth** while degree-corrected SBM achieves **0.7–0.9**. On real software systems (Tichelaar et al. 2008 corpus), hierarchical SBM produces decompositions one-to-one with expert-defined layers in Apache Hadoop, Tomcat, and OpenJDK.

**When NOT to use:**

- Speed-critical, single-shot analysis — SBM fitting is 10–100x slower than Leiden on the same graph.
- Pure assortative structure (e.g. co-change graphs where every cluster is a tight blob) — Leiden is faster and just as accurate.
- Very small graphs (< 100 nodes) — the MDL prior dominates the likelihood; result is too smoothed.

**Production:** `graph-tool` (Peixoto's library) is the reference; it has been used in academic SAR studies (Bavota et al. 2014, Corazza et al. 2016) and in network-science research for citation networks, biology, neuroscience. Not yet mainstream in industry — opportunity.

Reference: [Bayesian stochastic blockmodeling (Peixoto, 2017, in *Advances in Network Clustering and Blockmodeling*)](https://arxiv.org/abs/1705.10225)
