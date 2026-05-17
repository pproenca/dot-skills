---
title: Be Aware Of The Resolution Limit Of Modularity Maximization
impact: CRITICAL
impactDescription: prevents modularity Q from detecting clusters smaller than sqrt(2m); affects every codebase with > 10000 edges
tags: valid, resolution-limit, fortunato-barthelemy, modularity, multi-resolution
---

## Be Aware Of The Resolution Limit Of Modularity Maximization

**Fortunato & Barthélemy** ("Resolution limit in community detection," PNAS 2007) proved a startling result: **modularity Q maximization cannot detect communities smaller than approximately sqrt(2m)** where m is the number of edges. Below that scale, modularity *prefers* to merge small communities into larger ones, even when the small communities are perfectly cohesive and statistically distinct. This isn't a bug in Louvain or Leiden — it's a mathematical property of the modularity function itself. It applies to **every modularity-based method**: Louvain, Leiden, fast-greedy, spectral modularity, Bunch (which uses MQ, a different but related quality function with its own resolution limit).

For software clustering: a codebase with 10,000 edges (m = 10,000) has sqrt(2m) ≈ 141. Any "real" community smaller than ~140 files gets merged into something larger. On a typical industrial codebase, this means **modules of 5-50 files cannot be recovered by modularity**, even when they're architecturally crisp. The codebase's *actual* fine-grained decomposition is invisible to Q-based methods.

The fix is **multi-resolution modularity** — use a resolution parameter γ > 1 to find finer clusters, < 1 for coarser. Sweep γ and inspect the stable plateaus. Infomap, SBM, and HDBSCAN don't suffer from the resolution limit; for important fine-grained decisions, prefer them.

**Incorrect (run Louvain/Leiden once, take the result as truth):**

```python
import leidenalg, igraph as ig

g = build_ig_graph(G)
partition = leidenalg.find_partition(g, leidenalg.ModularityVertexPartition)
# At default γ = 1, the resolution limit is in effect. Communities of size
# < ~sqrt(2m) are merged. Real architectural modules of 20-50 files are
# invisible. The agent reports 8 communities; the actual codebase has 80.
```

**Correct (Step 1 — diagnose whether you're hit by the resolution limit):**

```python
import math
import networkx as nx

def diagnose_resolution_limit(G, cluster_sizes):
    """
    Compare your cluster sizes to the resolution limit threshold.
    If your *smallest* cluster size is well below sqrt(2m), then either:
      (a) your data has bigger structure than fine modules (OK), OR
      (b) modularity merged things that shouldn't be merged.
    Sweep γ to distinguish.
    """
    m = G.number_of_edges()
    limit = math.sqrt(2 * m)
    smallest = min(cluster_sizes)
    n_below_limit = sum(1 for s in cluster_sizes if s < limit)
    print(f"Edges m = {m}, resolution limit ≈ {limit:.1f}")
    print(f"Cluster size distribution: min={smallest}, "
          f"clusters below limit: {n_below_limit}/{len(cluster_sizes)}")
    if smallest > limit and n_below_limit < 0.3 * len(cluster_sizes):
        print("→ Resolution limit may be merging real fine structure. Sweep γ.")
```

**Correct (Step 2 — sweep the resolution parameter γ):**

```python
def resolution_sweep(g_ig, gamma_values=(0.5, 0.7, 1.0, 1.4, 2.0, 3.0, 5.0)):
    """
    The RBConfigurationVertexPartition has a resolution parameter γ
    (also known as 'γ' or 'gamma' in physics literature, or 'resolution'
    in the Reichardt-Bornholdt Hamiltonian).
    γ < 1 → coarser (bigger clusters, hits resolution limit harder)
    γ = 1 → standard modularity
    γ > 1 → finer (smaller clusters; resolution limit moves down)
    """
    import leidenalg
    results = []
    for gamma in gamma_values:
        partition = leidenalg.find_partition(
            g_ig,
            leidenalg.RBConfigurationVertexPartition,
            resolution_parameter=gamma,
            seed=42,
        )
        sizes = sorted([len(c) for c in partition], reverse=True)
        results.append({
            "gamma": gamma,
            "n_clusters": len(partition),
            "largest_size": sizes[0] if sizes else 0,
            "median_size": sizes[len(sizes)//2] if sizes else 0,
            "quality_Q": partition.quality(),
        })
    return results

for r in resolution_sweep(g_ig):
    print(f"γ = {r['gamma']:>4}  K = {r['n_clusters']:>3}  "
          f"largest = {r['largest_size']:>4}  Q = {r['quality_Q']:.3f}")
```

**Correct (Step 3 — find stable plateaus across the sweep):**

```python
from sklearn.metrics import normalized_mutual_info_score

def find_stable_resolutions(g_ig, gamma_values):
    """A 'stable plateau' is a range of γ values that produce similar
    clusterings (NMI > 0.85). These are robust decompositions —
    the same answer across a range of resolutions. Pick a γ from inside
    the longest plateau."""
    partitions = []
    for gamma in gamma_values:
        p = leidenalg.find_partition(g_ig, leidenalg.RBConfigurationVertexPartition,
                                      resolution_parameter=gamma, seed=42)
        labels = [0] * len(g_ig.vs)
        for ci, members in enumerate(p):
            for m in members:
                labels[m] = ci
        partitions.append((gamma, labels))

    print(f"{'γ_i':>5} {'γ_{i+1}':>8}  NMI")
    plateau_starts = []
    for i in range(len(partitions) - 1):
        g1, l1 = partitions[i]
        g2, l2 = partitions[i+1]
        nmi = normalized_mutual_info_score(l1, l2)
        marker = "  ← stable" if nmi > 0.85 else ""
        print(f"{g1:>5} {g2:>8}  {nmi:.3f}{marker}")

# Look for runs of "← stable" markers — those are the plateaus.
```

**Multi-resolution alternatives that avoid the limit entirely:**

| Method | How it avoids the limit |
|--------|-------------------------|
| **Infomap** | Map equation is per-cluster code-length, not normalized by graph total → no resolution limit |
| **Stochastic Block Model (Peixoto)** | MDL-based; clusters can be any size that minimizes description length |
| **HDBSCAN** | Density-based; explicit cluster_min_size parameter |
| **Markov Clustering (MCL)** | Inflation parameter directly controls granularity; no implicit limit |
| **Multi-Level Modularity (Reichardt-Bornholdt)** | Sweep γ explicitly — the technique above |

The Fortunato-Barthélemy result is *the* reason "Use Infomap instead of Louvain" is the default in many modern complex-systems papers.

**Empirical scope of the problem:**

| System | m (edges) | sqrt(2m) | "Lost" small clusters? |
|--------|----------|----------|------------------------|
| Toy ZKKC | 78 | 12.5 | No — clusters are larger than 12 |
| Mozilla | 10K–30K | 141–245 | Yes — many "real" subsystems are < 50 files |
| Linux | 100K+ | > 450 | Severe — many drivers/modules are tiny |
| Industrial monorepo (1M edges) | 1M | 1414 | Catastrophic — any "small" service is invisible |

**When NOT to worry about the resolution limit:**

- You only care about coarse-grained structure (top-level subsystems).
- The codebase is small enough that sqrt(2m) is below your smallest real module.
- You're using Infomap, SBM, MCL, HDBSCAN (these are immune).

**When you MUST consider it:**

- You suspect "real" small modules exist and want them back.
- Your modularity-Q output has surprisingly few, large clusters compared to the codebase's apparent feature count.
- You're publishing — *report* whether you've checked for resolution-limit effects.

**Production:** Leiden / Louvain implementations (`leidenalg`, `python-louvain`, `networkx`, igraph) all expose the resolution parameter. The Reichardt-Bornholdt Hamiltonian is the underlying generalization; multi-resolution modularity is the SAR community's standard workaround.

Reference: [Resolution limit in community detection (Fortunato & Barthélemy, PNAS 2007)](https://www.pnas.org/doi/10.1073/pnas.0605965104)
