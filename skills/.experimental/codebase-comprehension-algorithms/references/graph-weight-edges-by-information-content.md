---
title: Weight Edges By Information Content, Not Raw Frequency
impact: CRITICAL
impactDescription: 2–5x MoJoFM improvement over unweighted graphs by suppressing high-fan-in noise
tags: graph, weighting, tf-idf, mutual-information, edge-weight
---

## Weight Edges By Information Content, Not Raw Frequency

In a raw call graph or import graph, every edge has the same weight (1) — yet "module A imports the logger" and "module A imports the billing-specific tax-engine" are wildly unequal evidence of coupling. The logger has fan-in of 500; the tax-engine has fan-in of 4. **The information-theoretic content of an edge is roughly `log(N / fan-in(target))`** — exactly the IDF (inverse document frequency) of the target node treated as a "term." High-fan-in targets carry near-zero information; low-fan-in targets carry a lot.

Weighting edges by IDF (or by mutual information, or by Pointwise Mutual Information for directed edges) is the single biggest free win in software clustering after omnipresent filtering. It transforms every algorithm that respects edge weights — weighted Louvain, weighted Leiden, weighted Infomap, MCL — without changing the algorithm.

**Incorrect (unweighted graph — every edge counts the same):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = nx.Graph()
for src, dst in iter_imports("./src"):
    G.add_edge(src, dst)  # unweighted

# Louvain treats edge to logger and edge to tax-engine identically.
# Modules cluster by shared utility imports, not by shared domain dependencies.
comms = nxc.louvain_communities(G)
```

**Correct (IDF-weighted edges — common targets contribute little):**

```python
import math
import networkx as nx
import networkx.algorithms.community as nxc

def idf_weighted(G_directed: nx.DiGraph) -> nx.Graph:
    """
    Weight each edge u → v by IDF(v) = log(N / fan-in(v)).
    Edges to high-fan-in nodes (loggers, utilities) get weight ≈ 0.
    Edges to low-fan-in nodes (domain-specific helpers) get high weight.
    """
    N = G_directed.number_of_nodes()
    idf = {v: math.log(N / (1 + G_directed.in_degree(v))) for v in G_directed.nodes}

    H = nx.Graph()
    for u, v in G_directed.edges():
        w = idf[v]
        if H.has_edge(u, v):
            H[u][v]["weight"] += w
        else:
            H.add_edge(u, v, weight=w)
    return H

H = idf_weighted(G_directed)
comms = nxc.louvain_communities(H, weight="weight", seed=42)
```

**Alternative (Pointwise Mutual Information — directional, accounts for source rarity too):**

```python
# PMI(u, v) = log( P(u→v) / (P(u→·) · P(·→v)) )
# Captures: this edge happens more often than chance, given both endpoints.
# Better than IDF when source nodes also vary wildly in fan-out.

def pmi_weighted(G_directed: nx.DiGraph) -> nx.DiGraph:
    total_edges = G_directed.number_of_edges()
    H = nx.DiGraph()
    for u, v in G_directed.edges():
        p_uv = 1 / total_edges
        p_u_out = G_directed.out_degree(u) / total_edges
        p_v_in = G_directed.in_degree(v) / total_edges
        if p_u_out > 0 and p_v_in > 0:
            pmi = math.log(p_uv / (p_u_out * p_v_in))
            # PMI can be negative (edges *less* than chance). Clip to 0 for clustering.
            H.add_edge(u, v, weight=max(0, pmi))
    return H

# For co-change graphs, the canonical metric is Lift = P(A ∧ B) / (P(A) · P(B))
# which is exactly exp(PMI). See evol-mine-cochange-with-lift-and-confidence.
```

**Alternative (Jaccard on neighbourhoods — symmetric, lower-fan-in noise):**

```python
def jaccard_weighted(G: nx.Graph) -> nx.Graph:
    """
    For each edge (u, v), weight = |N(u) ∩ N(v)| / |N(u) ∪ N(v)|.
    Edges to dominant hubs (which everyone neighbours) get low Jaccard.
    Edges where both endpoints share specific neighbours get high Jaccard.
    """
    H = nx.Graph()
    for u, v in G.edges():
        Nu = set(G.neighbors(u))
        Nv = set(G.neighbors(v))
        union = Nu | Nv
        if union:
            H.add_edge(u, v, weight=len(Nu & Nv) / len(union))
    return H
```

**Empirical baseline:** Maqbool & Babri (TSE 2007, "Hierarchical Clustering for Software Architecture Recovery") report that IDF / Jaccard weighting on the import graph improves MoJoFM agreement with expert decompositions by **15–35 points** on Mozilla, Linux kernel, and three industrial systems compared to unweighted clustering — and the *interaction* with omnipresent filtering is mildly negative (one substitutes for the other), so do whichever is easier.

**The four-line summary of which to use:**

| Weighting | Use when |
|-----------|----------|
| IDF on target | Static call / import graph (target popularity is the dominant noise) |
| PMI / Lift | Co-change graph (both endpoints vary in frequency) |
| Jaccard on neighbours | Bipartite graphs and lexical similarity |
| Mutual information | When both nodes have categorical features (file type, language, layer) |

**When NOT to weight:**

- Tiny graphs (< 100 edges) — every edge is a needle in not-much-haystack; IDF adds noise.
- Pre-filtered graphs (after omnipresent removal) — diminishing returns; you've already removed the noise.
- When the algorithm doesn't honour edge weights — naive label propagation, some implementations of Walktrap. Read the docs.

**Production:** Apache Tinkerpop's Gremlin pattern for software analytics weights edges by IDF before community detection; CodeQL's call-graph queries optionally weight edges by call-site rarity; the Stochastic Block Model implementations in `graph-tool` honour edge weights natively.

Reference: [Hierarchical Clustering for Software Architecture Recovery (Maqbool & Babri, IEEE TSE 2007)](https://ieeexplore.ieee.org/document/4276083)
