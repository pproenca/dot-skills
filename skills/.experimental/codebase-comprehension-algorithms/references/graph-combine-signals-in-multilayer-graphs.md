---
title: Combine Structural, Lexical and Co-Change Signals As A Multilayer Graph
impact: HIGH
impactDescription: 15-30% MoJoFM improvement over single-signal clustering on real codebases (Beck-Diehl EMSE 2013)
tags: graph, multilayer, multiplex, fusion, combined-signals
---

## Combine Structural, Lexical and Co-Change Signals As A Multilayer Graph

A single edge type cannot capture a codebase. Structural edges (calls, imports) miss DI and dynamic dispatch. Lexical edges miss intent. Co-change edges miss never-changed code. The right answer is a **multilayer graph** — same node set (files), multiple edge sets (one per signal) — and a clustering algorithm aware of the layered structure. This is the dominant finding of the last decade of SAR research: Bavota et al. (TSE 2013), Beck-Diehl (EMSE 2013), Corazza-Di Martino-Maggio-Scanniello (JSS 2016) all report that **combined-signal clustering beats single-signal by 15–30 MoJoFM points** on standardised corpora.

The two important sub-decisions are: (1) how to *weigh* layers (so a dense layer doesn't drown a sparse layer) and (2) which algorithm to use on the result. Naively summing edge weights produces garbage because layers live on different scales.

**Incorrect (sum raw edge weights — the densest layer wins):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = nx.Graph()
for u, v, w in call_edges():       # weights 1–1000
    G.add_edge(u, v, weight=w)
for u, v, w in cochange_edges():   # weights 0–50
    if G.has_edge(u, v):
        G[u][v]["weight"] += w
    else:
        G.add_edge(u, v, weight=w)
for u, v, w in lexical_edges():    # weights 0–1 (cosine)
    if G.has_edge(u, v):
        G[u][v]["weight"] += w
    else:
        G.add_edge(u, v, weight=w)

# Call edges dominate by 3 orders of magnitude. The co-change and lexical
# layers have ~zero effect on Louvain's modularity score.
comms = nxc.louvain_communities(G, weight="weight")
```

**Correct (normalize each layer, weight by an explicit α you can ablate):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

def multilayer_combine(layers: dict[str, nx.Graph], alpha: dict[str, float]) -> nx.Graph:
    """
    layers: {"call": G_call, "cochange": G_cochange, "lexical": G_lexical}
    alpha:  {"call": 0.4, "cochange": 0.4, "lexical": 0.2}  must sum to 1.0
    Each layer is normalized to [0,1] by max edge weight before mixing.
    """
    assert abs(sum(alpha.values()) - 1.0) < 1e-6
    H = nx.Graph()
    for name, G in layers.items():
        w_max = max((d.get("weight", 1) for _, _, d in G.edges(data=True)), default=1)
        a = alpha[name]
        for u, v, d in G.edges(data=True):
            w_norm = d.get("weight", 1) / w_max * a
            if H.has_edge(u, v):
                H[u][v]["weight"] += w_norm
            else:
                H.add_edge(u, v, weight=w_norm)
    return H

H = multilayer_combine(
    layers={"call": G_call, "cochange": G_cc, "lexical": G_lex},
    alpha={"call": 0.4, "cochange": 0.4, "lexical": 0.2},
)
comms = nxc.louvain_communities(H, weight="weight", seed=42)
```

**Alternative (true multilayer — Mucha et al. PNAS 2010 generalized modularity):**

```python
# Mucha et al. defined modularity for multilayer networks: clusters can span
# layers via inter-layer coupling parameter ω. Implemented in `multinetx` and
# `pymnet`. Strictly more principled than the α-weighted sum because each
# layer's null model is preserved.
#
# import pymnet
# mnet = pymnet.MultilayerNetwork(aspects=1)  # 1 aspect = layer index
# for u, v, w in call_edges():     mnet[u, v, "call",     "call"]     = w
# for u, v, w in cochange_edges(): mnet[u, v, "cochange", "cochange"] = w
# for u, v, w in lexical_edges():  mnet[u, v, "lexical",  "lexical"]  = w
# # Inter-layer coupling: same file across layers
# for f in all_files:
#     mnet[f, f, "call", "cochange"] = OMEGA
#     mnet[f, f, "call", "lexical"]  = OMEGA
#     mnet[f, f, "cochange", "lexical"] = OMEGA
# clusters = pymnet.louvain.louvain_multilayer(mnet, gamma=1.0, omega=OMEGA)
```

**Alternative (consensus clustering — when you can't pick α):**

```python
# Run single-layer Louvain on each layer separately, then build a meta-graph
# where edge weight = (# of layers in which u,v ended up in the same cluster) / L.
# Cluster the meta-graph. Robust to layer-weight choice but loses fine detail.
# See valid-consensus-clustering-for-stability for the validation rationale.

def consensus_clustering(layers: list[nx.Graph]) -> list[set]:
    assignments = []
    for G in layers:
        comms = nxc.louvain_communities(G, weight="weight", seed=42)
        a = {node: i for i, c in enumerate(comms) for node in c}
        assignments.append(a)

    all_nodes = set().union(*[set(a) for a in assignments])
    M = nx.Graph()
    M.add_nodes_from(all_nodes)
    for u in all_nodes:
        for v in all_nodes:
            if u < v:
                same = sum(1 for a in assignments if a.get(u) == a.get(v) and u in a and v in a)
                if same >= len(layers) / 2:
                    M.add_edge(u, v, weight=same / len(layers))
    return nxc.louvain_communities(M, weight="weight")
```

**Why α matters and how to set it:** in the absence of expert ground truth, do a sensitivity sweep — fit clusterings at α = (0.6, 0.2, 0.2), (0.4, 0.4, 0.2), (0.2, 0.4, 0.4), etc., and pick the configuration that maximises *intrinsic* modularity Q (Newman 2006) or — better — *predictive* co-change accuracy on held-out commits (see `valid-cochange-prediction-as-ground-truth-proxy`). Beck-Diehl (EMSE 2013) report that α weights are remarkably stable across systems — ~40/40/20 (structural/co-change/lexical) is a good default.

**When NOT to use:**

- One signal is empty or near-empty (very little history, no comments, generated code) — fall back to single-layer.
- Strict time budget — Mucha's multilayer modularity is ~5–10× slower than single-layer Louvain.
- You're answering a *specific* question (just runtime impact? just feature boundaries?) — use the single layer for that question (see `graph-pick-edge-type-by-question-asked`).

**Production:** Microsoft's CODEMINE platform fuses structural and co-change signals for cross-cutting concern detection; LinkedIn's monorepo tools use a weighted-multilayer clustering for ownership inference; Google's Code Search backs ranking with a multilayer call+lexical signal.

Reference: [Community Structure in Time-Dependent, Multiscale, and Multiplex Networks (Mucha, Richardson, Macon, Porter, Onnela, Science 2010)](https://www.science.org/doi/10.1126/science.1184819)
