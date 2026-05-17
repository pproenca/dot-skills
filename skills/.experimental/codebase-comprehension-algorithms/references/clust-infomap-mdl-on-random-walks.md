---
title: Use Infomap When You Want To Compress Flow, Not Maximize Modularity
impact: CRITICAL
impactDescription: 5-15% NMI improvement over Leiden on directed flow-meaningful graphs; comparable on undirected
tags: clust, infomap, mdl, random-walks, rosvall, bergstrom, information-theoretic
---

## Use Infomap When You Want To Compress Flow, Not Maximize Modularity

Modularity-based methods (Louvain, Leiden) ask: *"which partition has more intra-community edges than chance?"* — that's a *density* question. **Infomap** (Rosvall & Bergstrom, PNAS 2008, "Maps of random walks on complex networks reveal community structure") asks a fundamentally different question: *"which partition produces the shortest description of a random walker's trajectory?"* — a *flow* question. It encodes random walks using a two-level code (Huffman-style: one codebook per community + a codebook for community-to-community transitions) and finds the partition that minimises the total **map equation** L(M) — a description length, in bits.

The two answers can be very different. For a software call graph where requests *flow* through layers (entry → router → handler → service → DB), Infomap recovers the *layers*; modularity recovers *blob-shaped* communities that cross layers. Lancichinetti & Fortunato's LFR benchmark (PRE 2009) and the comparative reviews of Yang et al. (Sci. Rep. 2016) consistently rank Infomap top on directed and flow-meaningful graphs, where modularity-based methods place 5th–10th.

This is the second-most-cited community detection algorithm after Louvain, and almost no software-clustering paper uses it. Try it whenever the edges represent *flow* (calls, data transfer, control transfer).

**Incorrect (Leiden on a directed call graph — collapses layers into blobs):**

```python
import igraph as ig
import leidenalg

g = build_directed_call_graph("./src")  # directed: source calls target
# Leiden in modularity mode treats edge direction as a hint at most; the
# graph's flow structure is lost. The community structure ends up
# "things that share many callers", not "things on the same execution layer".
partition = leidenalg.find_partition(g, leidenalg.RBConfigurationVertexPartition)
```

**Correct (Step 1 — Infomap via `infomap` Python package):**

```python
# pip install infomap
from infomap import Infomap

def run_infomap(G_nx, directed: bool = True, num_trials: int = 10):
    """
    Build an Infomap problem from a NetworkX graph and minimise the map
    equation L(M). `num_trials` runs multiple restarts; the best L(M) wins.
    """
    im = Infomap("--directed" if directed else "", num_trials=num_trials, silent=True)
    name_to_id = {n: i for i, n in enumerate(G_nx.nodes())}
    for u, v, d in G_nx.edges(data=True):
        im.add_link(name_to_id[u], name_to_id[v], d.get("weight", 1.0))
    im.run()
    return im, name_to_id

im, name_to_id = run_infomap(G_call_directed, directed=True)
print(f"Codelength (lower = better): {im.codelength:.4f} bits")
```

**Correct (Step 2 — extract the (possibly hierarchical) communities):**

```python
def extract_communities(im, name_to_id):
    """
    Infomap returns a HIERARCHICAL community structure (modules can have
    sub-modules). For a flat decomposition, take the top-level module id.
    For hierarchy, use im.iterTree() to walk depth.
    """
    id_to_name = {v: k for k, v in name_to_id.items()}
    flat = {}     # top-level: name → community id
    hierarchy = {}  # full path: name → tuple of community ids
    for node in im.tree:
        if node.is_leaf:
            flat[id_to_name[node.node_id]] = node.module_id
            hierarchy[id_to_name[node.node_id]] = tuple(node.path)
    return flat, hierarchy

flat, hier = extract_communities(im, name_to_id)
# Plot: nodes coloured by community id, layout by hierarchy depth — the
# layered structure of the call graph appears cleanly.
```

**Why the map equation captures something Modularity misses:**

The map equation L(M) = q · H(Q) + Σᵢ pᵢ · H(Pᵢ) where:
- q = probability the walker exits its current module
- H(Q) = entropy of inter-module transitions
- pᵢ = probability of being in module i
- H(Pᵢ) = entropy of intra-module transitions

Minimising L(M) means choosing modules so that the walker rarely crosses module boundaries (most steps stay inside) AND the within-module dynamics are predictable. This captures *flow communities* — sets of nodes the walker tends to stay within — which is exactly what a "feature domain" looks like in a call graph: requests bounce around within a domain, occasionally hop to another.

**When to use Infomap vs Leiden:**

| Situation | Algorithm |
|-----------|-----------|
| Directed graph with meaningful flow (calls, control transfer) | **Infomap** |
| Undirected graph, density question (who is connected to whom) | Leiden |
| Need explicit hierarchy | Infomap (native) or Leiden multi-resolution |
| Very large graph (10⁶+ nodes) | Both scale; igraph-Leiden slightly faster |
| Sparse, low-modularity graph | Infomap (less prone to resolution limit) |

**Empirical baseline (Lancichinetti-Fortunato benchmark, LFR):** on the standard LFR benchmark with mixing parameter μ = 0.5 (moderately mixed communities), Infomap recovers true communities with NMI ≈ 0.85; Louvain 0.70; Leiden 0.78. On undirected benchmarks the three are typically comparable (Yang et al. 2016 arXiv:1807.01130) — Infomap's advantage concentrates in *directed, flow-meaningful* graphs (citation networks, web link graphs, software call graphs). On real software call graphs (Mancoridis benchmark), Infomap matches or exceeds Bunch's MQ-optimized clusterings.

**When NOT to use:**

- Undirected, density-meaningful graphs (co-change, lexical similarity) — Leiden's modularity is better-aligned with the right question.
- Graphs with no flow interpretation (e.g. pure structural similarity).
- Very dense graphs (average degree > √N) — random walks mix too fast to discriminate modules.

**Production:** Apache Hadoop's GraphX has community-Infomap contributions; the `infomap` C++ library is the reference (also as a `pip install infomap` Python wrapper); used in the original Map-Equation papers and now in scientometrics, citation networks, transportation networks.

Reference: [Maps of random walks on complex networks reveal community structure (Rosvall & Bergstrom, PNAS 2008)](https://www.pnas.org/doi/10.1073/pnas.0706851105)
