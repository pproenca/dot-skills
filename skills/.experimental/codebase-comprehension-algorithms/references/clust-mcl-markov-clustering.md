---
title: Use MCL (Markov Clustering) For Flow Simulation On Sparse Graphs
impact: MEDIUM-HIGH
impactDescription: 15-30% improvement on noise-injected networks (Brohée-van Helden 2006); eliminates K hyperparameter
tags: clust, mcl, markov-clustering, flow, van-dongen
---

## Use MCL (Markov Clustering) For Flow Simulation On Sparse Graphs

**Markov Clustering (MCL)** was Stijn van Dongen's PhD thesis (Utrecht, 2000) and has been the dominant clustering algorithm in computational biology (protein-protein interaction networks) for over two decades. Almost no software engineer has heard of it. The idea is delightfully physical: simulate a random walker on the graph for a few steps (**expansion** — multiply the transition matrix by itself), then artificially amplify the walker's preference for already-likely edges (**inflation** — raise each entry to a power r > 1 and renormalise). Iterate to convergence. The fixed point is a sparse matrix whose connected components are the clusters.

MCL has three properties that matter for software analysis: (1) **the inflation parameter r implicitly controls granularity** (r = 1.4 → coarse, r = 4 → fine — predictable and continuous, no resolution limit), (2) **it scales linearly with edges** because the sparse matrix stays sparse, (3) **it's robust to noise** because flow naturally avoids low-weight edges. The trade-off: it's only available as a library (the original `mcl` C tool, or `markov_clustering` in Python), not in `networkx`.

**Incorrect (Leiden on a noisy co-change graph — communities shift across runs):**

```python
import leidenalg, igraph as ig

g = build_cochange_graph("./repo")  # noisy: many spurious one-off co-changes
# Leiden's modularity optimization is sensitive to which edges happened to
# pass the noise floor. The partition shifts across runs; small noise edges
# can move a file between clusters.
part = leidenalg.find_partition(g, leidenalg.RBConfigurationVertexPartition, seed=42)
```

**Correct (Step 1 — MCL on the same noisy graph):**

```python
# pip install markov_clustering
import markov_clustering as mc
import numpy as np
import scipy.sparse as sp

def to_adjacency(G_nx):
    """MCL wants a sparse weighted adjacency. Self-loops added to dampen
    iteration noise (van Dongen §6.1)."""
    nodes = list(G_nx.nodes())
    idx = {n: i for i, n in enumerate(nodes)}
    n = len(nodes)
    A = sp.lil_matrix((n, n))
    for u, v, d in G_nx.edges(data=True):
        w = d.get("weight", 1.0)
        A[idx[u], idx[v]] = w
        A[idx[v], idx[u]] = w
    for i in range(n):
        A[i, i] = 1.0  # self-loops
    return A.tocsr(), nodes

A, nodes = to_adjacency(G_cochange.to_undirected())
```

**Correct (Step 2 — run MCL with inflation parameter r):**

```python
# r = 1.4–2.0 → coarse clusters; r = 2.5–4.0 → fine clusters.
# Empirically, r ≈ 2.0 is the sweet spot for software dependency / co-change
# graphs (matches Bunch's typical granularity).
result = mc.run_mcl(A, inflation=2.0, expansion=2, iterations=100)
clusters_idx = mc.get_clusters(result)
clusters = [[nodes[i] for i in c] for c in clusters_idx]
print(f"{len(clusters)} clusters; sizes: {sorted(len(c) for c in clusters)}")
```

**Correct (Step 3 — sweep r and pick by stability, not by modularity):**

```python
def mcl_stability_sweep(A, nodes, r_values=(1.4, 1.6, 1.8, 2.0, 2.2, 2.5, 3.0)):
    """
    Run MCL at multiple inflation values, compute the pairwise NMI between
    consecutive solutions. A plateau in NMI = stable scale. The recommended
    operating point is the centre of the longest plateau (van Dongen §10).
    """
    partitions = []
    for r in r_values:
        clusters = mc.get_clusters(mc.run_mcl(A, inflation=r))
        labels = np.zeros(len(nodes), dtype=int)
        for ci, members in enumerate(clusters):
            for m in members:
                labels[m] = ci
        partitions.append(labels)

    from sklearn.metrics import normalized_mutual_info_score
    nmis = []
    for i in range(len(partitions) - 1):
        nmis.append(normalized_mutual_info_score(partitions[i], partitions[i + 1]))
    return list(zip(r_values, nmis + [None]))

# Output: [(1.4, 0.93), (1.6, 0.91), (1.8, 0.89), (2.0, 0.95), (2.2, 0.92), ...]
# 2.0 sits in a high-NMI plateau — pick that r.
```

**Why MCL is robust to noise:**

After each expansion step, edges that have *some* probability mass get reinforced; near-zero-mass edges decay. Inflation accelerates this: r = 2 squares each entry, so a 0.01-mass edge becomes 0.0001-mass while a 0.5-mass edge becomes 0.25-mass. Spurious low-weight edges die; meaningful edges survive. The result: clusters depend on dominant *flow patterns*, not on individual noisy edges. This is why MCL has been the default in protein-interaction networks — those are *very* noisy.

**Empirical baseline:** Enright et al. (NAR 2002, "An efficient algorithm for large-scale detection of protein families") compared MCL with single-linkage, average-linkage, and TribeMCL on Pfam: MCL produced clusters with 93% precision/86% recall versus 78%/65% for the next-best method. Brohée & van Helden (BMC Bioinformatics 2006) showed MCL beats modularity-based methods by 15–30% on noise-injected biological networks. The bioinformatics result transfers directly to noisy software co-change data.

**When NOT to use:**

- Dense graphs (average degree > sqrt(N)) — expansion produces a dense intermediate matrix; runtime blows up.
- You need a specific number of clusters — MCL doesn't take k; you tune r and accept what you get.
- Hierarchical decomposition required — MCL is flat. Use SBM hierarchical (`clust-stochastic-block-model`) or repeated MCL with varying r as a poor-man's hierarchy.

**Production:** `mcl` (C tool by van Dongen, original — still maintained at micans.org/mcl); `markov_clustering` (Python); used as default in Pfam, OrthoMCL (orthology detection in genomics), and STRING (protein-protein interactions). Not yet mainstream in software clustering — significant opportunity.

Reference: [Graph Clustering by Flow Simulation (van Dongen, PhD thesis, University of Utrecht, 2000)](https://micans.org/mcl/lit/svdthesis.pdf.gz)
