---
title: Use Adjusted Rand Index And Normalized Mutual Information For Cross-Algorithm Comparison
impact: HIGH
impactDescription: chance-adjusted clustering similarity; reduces inflated baseline of plain Rand index by 0.6-0.9
tags: valid, ari, nmi, rand-index, vinh, hubert-arabie
---

## Use Adjusted Rand Index And Normalized Mutual Information For Cross-Algorithm Comparison

MoJoFM (`valid-mojofm-as-software-clustering-distance`) is the SAR-specific gold standard, but it's **asymmetric** (you measure distance *toward* ground truth) and not always available — sometimes you have *two algorithms* and want to ask "do they agree?" without an expert reference. The general-purpose answers are **Adjusted Rand Index** (Hubert & Arabie, "Comparing partitions," J. Classification 1985) and **Normalized Mutual Information** (Vinh, Epps, Bailey, "Information theoretic measures for clusterings comparison," ICML 2009 / JMLR 2010). Both are:

- **Chance-corrected**: random clusterings score ≈ 0, not the inflated baseline of plain Rand index
- **Bounded**: ARI ∈ [-1, 1] (theoretical), [0, 1] practically; NMI ∈ [0, 1]
- **Symmetric**: ARI(A, B) = ARI(B, A)
- **Scale-invariant**: don't care about cluster count

Use both. ARI is sharper when cluster sizes are roughly balanced; NMI is more forgiving and handles imbalanced cluster sizes better. The **Adjusted Mutual Information** (Vinh et al. 2010, AMI) is NMI's chance-corrected sibling — even better. For software, **always report ARI + NMI alongside MoJoFM** — they're cheap, they're standard, and they make your evaluation comparable to clustering literature outside SAR.

**Incorrect (use raw Rand index — inflated, not chance-corrected):**

```python
from sklearn.metrics import rand_score

ri = rand_score(labels_a, labels_b)
# Two random clusterings of 1000 items into 10 clusters score Rand ≈ 0.9
# (most pairs of items end up in different clusters in BOTH).
# Numbers near 0.9 are meaningless — could be random or excellent.
```

**Correct (Step 1 — ARI and NMI from sklearn):**

```python
from sklearn.metrics import adjusted_rand_score, normalized_mutual_info_score, \
                            adjusted_mutual_info_score

def compare_clusterings(labels_a, labels_b):
    """
    Returns ARI, NMI (geometric mean), AMI — three chance-corrected metrics.
    All ∈ [0, 1] for any practical comparison. 0 = random; 1 = identical.
    """
    return {
        "ARI": adjusted_rand_score(labels_a, labels_b),
        "NMI": normalized_mutual_info_score(labels_a, labels_b, average_method="geometric"),
        "AMI": adjusted_mutual_info_score(labels_a, labels_b, average_method="arithmetic"),
    }

# Note: sklearn wants *label* arrays (per-item integer cluster ids),
# not sets-of-files. Convert if needed.
def clusters_to_labels(clusters: list[set], item_order: list) -> list[int]:
    item_to_cluster = {item: i for i, c in enumerate(clusters) for item in c}
    return [item_to_cluster[item] for item in item_order]
```

**Correct (Step 2 — compare a single clustering across multiple algorithms):**

```python
def compare_algorithms(files, algorithms_outputs: dict[str, list[set]]):
    """
    algorithms_outputs: {"leiden": [set, set, ...], "infomap": [...], ...}
    Returns pairwise ARI / NMI matrix — which algorithms agree?
    """
    labels = {name: clusters_to_labels(clusters, files)
              for name, clusters in algorithms_outputs.items()}
    algos = list(labels)

    print(f"{'pair':30} {'ARI':>6}  {'NMI':>6}  {'AMI':>6}")
    for i, a1 in enumerate(algos):
        for a2 in algos[i+1:]:
            m = compare_clusterings(labels[a1], labels[a2])
            print(f"{a1:>12} vs {a2:>12} : {m['ARI']:>6.3f}  {m['NMI']:>6.3f}  {m['AMI']:>6.3f}")

# Typical software-clustering output:
#   leiden vs infomap    :  0.512  0.681  0.612
#   leiden vs sbm        :  0.434  0.598  0.534
#   infomap vs sbm       :  0.401  0.587  0.521
# Agreement around 0.5 ARI is high for clustering algorithms with different
# inductive biases on the same input — the same underlying structure.
```

**Correct (Step 3 — interpret the numbers calibrated against random):**

```python
import random
import numpy as np

def random_baseline(labels_a, n_random: int = 100, seed: int = 42):
    """Shuffle labels_b randomly n_random times; compute ARI/NMI for each.
    The 95th percentile is the "random baseline" — your real ARI/NMI must
    exceed this to be meaningful."""
    rng = random.Random(seed)
    n = len(labels_a)
    n_clusters = max(labels_a) + 1
    aris, nmis = [], []
    for _ in range(n_random):
        random_labels = [rng.randrange(n_clusters) for _ in range(n)]
        aris.append(adjusted_rand_score(labels_a, random_labels))
        nmis.append(normalized_mutual_info_score(labels_a, random_labels))
    return {"ari_95": np.percentile(aris, 95), "nmi_95": np.percentile(nmis, 95)}

# Typical baseline on 1000 items, 10 clusters: ARI ≈ 0.001, NMI ≈ 0.02
# So any real result > 0.05 is meaningfully better than chance.
# Strong agreement: ARI > 0.5, NMI > 0.6.
```

**ARI vs NMI vs AMI — when to prefer which:**

| Property | ARI | NMI | AMI |
|----------|-----|-----|-----|
| Chance-corrected | yes | only loosely | yes |
| Penalizes imbalanced clusters | yes (heavily) | less | properly |
| Sensitive to small clusters | yes | yes | yes |
| Reported in most ML literature | yes | yes | rising |
| Numerically stable for low overlap | yes | yes | sometimes unstable |
| Recommended by Vinh-Epps-Bailey 2010 | for balanced | for general | for *exact* fairness |

The Vinh-Epps-Bailey JMLR 2010 paper is *the* reference for "which to use when" — read it for any serious clustering-evaluation study. Their bottom line: **AMI when cluster sizes vary widely, ARI when they're balanced, NMI as a fallback** (cheaper to compute).

**Other useful clustering-comparison metrics:**

| Metric | Use case |
|--------|----------|
| **Variation of Information (VI)** | Meila 2003 — symmetric, bounded by log N, interpretable as bits |
| **Fowlkes-Mallows Index** | Useful when comparing to *hierarchical* clusterings |
| **Jaccard Index on pairs** | Set-based; simpler interpretation |
| **F-measure (max-match)** | Reports per-cluster agreement; useful for asymmetric "find this cluster" tasks |

**Empirical baseline:** On the standard LFR benchmark (Lancichinetti-Fortunato-Radicchi PRE 2008), Louvain achieves NMI ≈ 0.70–0.85 against ground truth; Leiden 0.78–0.88; Infomap 0.80–0.92. For software, similar values apply against expert decompositions: Andritsos-Tzerpos 2005 reports Limbo at NMI ≈ 0.72 on TOBEY; comparable Bunch and ACDC are 0.65–0.78.

**When NOT to use:**

- Highly imbalanced cluster sizes (one giant cluster + many small) — NMI is misleading; use AMI or report ARI alongside.
- Overlapping clusters — both ARI and NMI assume disjoint partitions; use **overlapping NMI** (McDaid-Greene-Hurley 2011) or the **omega index**.
- Clusterings with very different cluster counts — informative for one direction but symmetric metrics may flatten the difference; supplement with MoJoFM which is asymmetric.

**Production:** scikit-learn `adjusted_rand_score`, `normalized_mutual_info_score`, `adjusted_mutual_info_score`. The `scikit-network` and `networkx-community` libraries provide more variants. For *overlapping* clusterings, `overlapping-nmi` and `cd-evaluation` packages.

Reference: [Information Theoretic Measures for Clusterings Comparison: Variants, Properties, Normalization and Correction for Chance (Vinh, Epps, Bailey, JMLR 2010)](https://www.jmlr.org/papers/v11/vinh10a.html)
