---
title: Use Consensus Clustering To Measure And Improve Stability
impact: HIGH
impactDescription: reduces single-run variance; 0.70 → 0.85 NMI on LFR benchmark across 50 runs (Lancichinetti-Fortunato 2012)
tags: valid, consensus, stability, lancichinetti-fortunato, monti, bootstrap
---

## Use Consensus Clustering To Measure And Improve Stability

Most community-detection algorithms (Louvain, Leiden, even SBM) depend on random initialisation, seed, or stochastic moves. Two runs on the same input produce **different clusterings**. If they differ a lot, the result is unreliable. **Consensus clustering** (Strehl-Ghosh, JMLR 2002; Monti et al. for genomics, ML 2003; Lancichinetti-Fortunato, "Consensus clustering in complex networks," Sci. Rep. 2012) addresses both **measurement** (how stable is my answer?) and **improvement** (combine many noisy clusterings into one robust answer).

The procedure: run the same algorithm N times with different seeds; build a **co-occurrence matrix** P where P[i,j] = (# runs where i and j are in the same cluster) / N; threshold or cluster on P to get the consensus. For software, **consensus across ≥10 runs is the right way to report a clustering**; if the consensus is shaky (most P[i,j] near 0.5), the data doesn't have crisp community structure and you should report that honestly, not pick one of the noisy answers.

Without consensus, you're trusting whatever the random seed gave you. With consensus, you have a measured confidence per assignment.

**Incorrect (run Leiden once, report the result as the architecture):**

```python
import leidenalg

partition = leidenalg.find_partition(g, leidenalg.ModularityVertexPartition, seed=42)
# Different seed → different partition. The single-run answer might assign
# `src/payments/charge.py` to cluster 3 or cluster 7 depending on luck.
# The agent reports the architecture with false confidence.
```

**Correct (Step 1 — run N times and build the co-occurrence matrix):**

```python
import numpy as np
from collections import defaultdict
import leidenalg

def consensus_matrix(g_ig, n_runs: int = 30, gamma: float = 1.0):
    """
    Run Leiden N times with different seeds.
    P[i,j] = fraction of runs in which i and j ended up in the same cluster.
    """
    n = len(g_ig.vs)
    co_count = np.zeros((n, n), dtype=np.int32)
    for seed in range(n_runs):
        partition = leidenalg.find_partition(
            g_ig,
            leidenalg.RBConfigurationVertexPartition,
            resolution_parameter=gamma,
            seed=seed,
        )
        labels = np.empty(n, dtype=np.int32)
        for ci, members in enumerate(partition):
            for m in members:
                labels[m] = ci
        # Add 1 to every pair (i,j) with same label
        for ci in range(max(labels) + 1):
            members = np.where(labels == ci)[0]
            for idx_i, i in enumerate(members):
                for j in members[idx_i+1:]:
                    co_count[i, j] += 1
                    co_count[j, i] += 1

    P = co_count / n_runs
    np.fill_diagonal(P, 1.0)
    return P
```

**Correct (Step 2 — extract the consensus clustering):**

```python
def consensus_clusters(P: np.ndarray, threshold: float = 0.5):
    """
    Two ways to extract the consensus from P:
    (a) Threshold + connected components: build an unweighted graph where
        i,j are connected if P[i,j] > threshold; clusters = CCs. Simple.
    (b) Apply a final clustering algorithm to P as a weighted graph
        (Lancichinetti-Fortunato 2012). More principled.

    Below: (a) for simplicity. Sweep threshold to see stability.
    """
    import networkx as nx
    n = P.shape[0]
    G = nx.Graph()
    G.add_nodes_from(range(n))
    for i in range(n):
        for j in range(i+1, n):
            if P[i, j] >= threshold:
                G.add_edge(i, j, weight=P[i, j])
    return list(nx.connected_components(G))

clusters_at_05 = consensus_clusters(P, threshold=0.5)
clusters_at_07 = consensus_clusters(P, threshold=0.7)  # tighter

print(f"At p≥0.5: {len(clusters_at_05)} clusters")
print(f"At p≥0.7: {len(clusters_at_07)} clusters  (more conservative)")
```

**Correct (Step 3 — report uncertainty per file):**

```python
def assignment_uncertainty(P, consensus_clusters):
    """
    For each file, compute the probability it's in its assigned cluster
    averaged over members. Low value = unstable assignment.
    Returns: dict[file] → in-cluster-co-occurrence-mean.
    """
    file_to_cluster = {}
    for ci, members in enumerate(consensus_clusters):
        for f in members:
            file_to_cluster[f] = ci

    uncertainty = {}
    for f, ci in file_to_cluster.items():
        cluster_members = [m for m in consensus_clusters[ci] if m != f]
        if not cluster_members:
            uncertainty[f] = 1.0
            continue
        mean_p = np.mean([P[f, m] for m in cluster_members])
        uncertainty[f] = float(mean_p)
    return uncertainty

unc = assignment_uncertainty(P, clusters_at_05)
unstable = sorted(unc.items(), key=lambda kv: kv[1])[:20]
print("Most uncertain assignments (low in-cluster co-occurrence):")
for file_idx, p in unstable:
    print(f"  p = {p:.2f}  file {file_idx}")
# These files sit at boundaries; the agent should report them as
# "could be in either cluster" rather than asserting placement.
```

**Why consensus matters for software clustering:**

A clustering that depends on the seed isn't telling you about the *codebase* — it's telling you about *seed 42*. Consensus surfaces the **invariant** structure across runs, which is what an architect cares about. The same idea is used in bioinformatics (Monti et al. 2003 found consensus essential for cancer-subtype clustering) and is now standard in any rigorous network-clustering pipeline.

For software specifically, Lancichinetti & Fortunato (Sci. Rep. 2012) showed that consensus across 50 Louvain runs **closes most of the gap** between Louvain and Infomap on the LFR benchmark — a free improvement. The same applies to software graphs.

**How many runs N to use:**

| N | When |
|---|------|
| 10 | Quick sanity check; minimum for stability reporting |
| **30** | **Standard** — Lancichinetti-Fortunato recommendation |
| 100 | Publication-quality; high-confidence numbers |
| 1000 | Overkill for clustering; OK for bootstrap-based uncertainty estimation |

**Empirical baseline:** Lancichinetti-Fortunato (Sci. Rep. 2012) report that consensus clustering with N=50 over Louvain achieves NMI ≈ 0.85 on LFR benchmark vs single-run NMI ≈ 0.70. For software: Beck-Diehl (EMSE 2013) replicated on six open-source systems and found consensus improves MoJoFM by 3–8 points and dramatically reduces inter-run variance (sd from 0.05 to < 0.01).

**When NOT to use consensus:**

- The algorithm is deterministic (graph-tool's SBM with a fixed prior is essentially deterministic). Single run is enough.
- Speed-critical (single decision in CI) — one run is fine, just don't claim high confidence.
- Tiny graphs (< 50 nodes) — there isn't enough room for the algorithm to disagree with itself.

**Production:** `cdlib` Python library has consensus clustering wrappers. The `consensus_clustering` R package (originally for genomics) implements Monti et al. directly. Scikit-network exposes consensus utilities for graph clustering.

Reference: [Consensus clustering in complex networks (Lancichinetti & Fortunato, Scientific Reports 2012)](https://www.nature.com/articles/srep00336)
