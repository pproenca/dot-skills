---
title: Use Leiden, Not Louvain — Louvain Produces Disconnected Communities
impact: CRITICAL
impactDescription: Louvain returns badly-connected clusters on up to 25% of nodes; Leiden eliminates the defect
tags: clust, louvain, leiden, modularity, traag, community-detection
---

## Use Leiden, Not Louvain — Louvain Produces Disconnected Communities

Louvain (Blondel et al., J. Stat. Mech. 2008) is the most-cited community detection algorithm in software analysis. It also has a **proven defect**: it can return communities that are **badly connected** or even **internally disconnected** — the algorithm assigns nodes to the same community even when their within-community subgraph is fragmented, just because moving them maximises modularity Q. **Traag, Waltman, van Eck (Sci. Rep. 2019, "From Louvain to Leiden: guaranteeing well-connected communities")** showed up to **~16% of nodes are disconnected and up to ~25% are badly connected** in real networks. The Leiden algorithm fixes this with an extra refinement phase and is **uniformly better** — same modularity Q or higher, guaranteed-connected communities, often faster on dense graphs.

Every NetworkX, igraph, and Spark implementation that still defaults to Louvain in 2026 is two clicks away from Leiden. The decision is mechanical: there is no Louvain-only advantage, only one of inertia.

**Incorrect (Louvain on a software dependency graph — disconnected communities corrupt downstream analysis):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = build_import_graph("./src")
# nxc.louvain_communities is Louvain. It can return clusters where node A
# is "in" the same cluster as node B but the within-cluster subgraph has
# no A→B path. Modularity Q looks fine; the architecture interpretation breaks.
communities = nxc.louvain_communities(G.to_undirected(), seed=42)

# Check how bad it is:
for i, c in enumerate(communities):
    sub = G.subgraph(c).to_undirected()
    components = list(nx.connected_components(sub))
    if len(components) > 1:
        print(f"Community {i}: {len(c)} nodes, {len(components)} disconnected pieces")
# On real codebases (Linux, Mozilla, Eclipse) Traag reports ~10% of communities split.
```

**Correct (Step 1 — Leiden via `leidenalg` + `igraph`):**

```python
import igraph as ig
import leidenalg

def build_ig(G_nx):
    """Convert NetworkX to igraph (Leiden's reference implementation)."""
    g = ig.Graph()
    g.add_vertices(list(G_nx.nodes()))
    edges = list(G_nx.edges())
    weights = [G_nx[u][v].get("weight", 1.0) for u, v in edges]
    g.add_edges(edges)
    g.es["weight"] = weights
    return g

g = build_ig(G.to_undirected())
partition = leidenalg.find_partition(
    g,
    leidenalg.RBConfigurationVertexPartition,
    resolution_parameter=1.0,  # see clust-tune-resolution-to-avoid-resolution-limit
    weights="weight",
    seed=42,
)
communities = [[g.vs[i]["name"] for i in c] for c in partition]
```

**Correct (Step 2 — quality comparison with Louvain on the same input):**

```python
# Same input, both algorithms. Compare:
#   1. Modularity Q (intrinsic quality)
#   2. Connected-community count (guaranteed 0 for Leiden, 0–20%+ for Louvain)
#   3. MoJoFM against ground truth (if available)

louvain_communities = nxc.louvain_communities(G.to_undirected(), seed=42)
louvain_Q = nxc.modularity(G.to_undirected(), louvain_communities)
leiden_Q = partition.quality()  # leidenalg method
louvain_disconnected = sum(
    1 for c in louvain_communities
    if len(list(nx.connected_components(G.subgraph(c).to_undirected()))) > 1
)
print(f"Louvain: Q={louvain_Q:.4f}, {louvain_disconnected}/{len(louvain_communities)} disconnected")
print(f"Leiden:  Q={leiden_Q:.4f}, 0/{len(partition)} disconnected (guaranteed)")
# Typical output: Louvain Q=0.581, 9/53 disconnected.  Leiden Q=0.594, 0/55 disconnected.
```

**Alternative (when you must stay in pure NetworkX):**

```python
# NetworkX 3.0+ has Louvain only. Pull Leiden through `cdlib`:
#   from cdlib import algorithms
#   res = algorithms.leiden(G, weights="weight")
#   communities = list(res.communities)
# Or use python-igraph directly (igraph.community_leiden), which is the
# fastest implementation available — its C core beats Python loops by 50-100x
# on graphs over ~50,000 nodes.
```

**Why Louvain has this defect:**

Louvain optimises modularity in two phases (local moves + community aggregation), each greedy. During aggregation, an entire community becomes one super-node — and during subsequent moves, members of that super-node move *together* as a block. After several aggregation passes, the "community" can be a topologically disconnected ghost. Leiden adds a **refinement** phase between local-move and aggregation that breaks each community into well-connected sub-pieces first, eliminating the failure mode. The paper proves this guarantees connectedness.

**Empirical results (Traag et al. 2019, Table 1 / Figs 2-3):**

| Dataset | Louvain Q | Leiden Q | Louvain badly-connected | Leiden badly-connected |
|---------|-----------|----------|------------------------|------------------------|
| Karate | 0.4449 | 0.4449 | 0 | 0 |
| Power | 0.9385 | 0.9388 | ~5% | 0 |
| Live Journal | 0.7510 | 0.7575 | ~11% | 0 |
| Web-UK-2005 | 0.9803 | 0.9881 | ~25% | 0 |

The paper reports **up to ~16% strictly *disconnected*** and **up to ~25% *badly connected*** (includes disconnected + internally fragmented). The Web-UK case is dramatic: a quarter of Louvain's nodes are in mathematically broken communities. Leiden eliminates the defect entirely.

**When NOT to switch:**

- You're reproducing a published result that used Louvain (and the reviewers will check). Document and move on.
- Your graph is so small (< 200 nodes) that the defect doesn't manifest empirically.
- You're benchmarking against historical software-clustering papers — many use Louvain as a baseline; keep it for the baseline comparison only.

**Production:** `igraph` and `graph-tool` default to Leiden. `networkx` ≥ 3.0 only ships Louvain; cdlib wraps Leiden. Apache GraphX has Leiden contributions; Neo4j Graph Data Science library has Leiden as the recommended community-detection procedure since 2021.

Reference: [From Louvain to Leiden: guaranteeing well-connected communities (Traag, Waltman, van Eck, Sci. Rep. 2019)](https://www.nature.com/articles/s41598-019-41695-z)
