---
title: Use MoJoFM As The Canonical Distance Between Software Clusterings
impact: CRITICAL
impactDescription: reduces cross-algorithm comparison to a single 0-100 score; the SAR gold-standard since 2004
tags: valid, mojofm, tzerpos, wen, software-specific, distance
---

## Use MoJoFM As The Canonical Distance Between Software Clusterings

When you have two clusterings of the same files — your algorithm's output and an expert's ground-truth decomposition, or two algorithms' outputs — how do you measure how close they are? **Generic metrics** (Adjusted Rand Index, Normalized Mutual Information) come from clustering literature and are fine, but they don't capture the *software-specific* notion of "how many edits to turn clustering A into clustering B?" That's what **MoJo** (**Tzerpos & Holt, "MoJo: A distance metric for software clusterings," WCRE 1999**) and its normalized variant **MoJoFM** (**Wen & Tzerpos, "An effectiveness measure for software clustering algorithms," IWPC 2004**) measure: the minimum number of **Move** and **Join** operations to convert one clustering into the other, normalized to [0, 100] where 100 = identical and 0 = maximally distant.

MoJoFM is **the** standard metric in the Software Architecture Recovery literature; published comparisons between Bunch, ACDC, Limbo, Leiden, Infomap all report MoJoFM. **If your skill or paper claims to "do clustering on code", you need to report MoJoFM** against expert decompositions on standard benchmarks — there is no other accepted way to compare to prior art.

**Incorrect (use only Adjusted Rand Index — misses the asymmetric, edit-based nature):**

```python
from sklearn.metrics import adjusted_rand_score

ari = adjusted_rand_score(ground_truth_labels, predicted_labels)
# ARI is fine, but not commensurable with the SAR literature. You can't
# compare your ARI = 0.62 against published Bunch / Limbo / ACDC results
# which all report MoJoFM.
```

**Correct (Step 1 — implement MoJo distance, then normalize to MoJoFM):**

```python
from collections import Counter

def mojo_distance(A: list[set], B: list[set]) -> int:
    """
    A, B are clusterings of the same node set: lists of disjoint sets.
    MoJo distance = min (Move + Join) operations to turn A into B.

    Two-pass greedy algorithm (Tzerpos-Holt 1999):
    1. For each cluster in A, find the cluster in B with maximum overlap.
       That cluster is its "target". Each node not in its target is one Move.
    2. After all moves, the partition of A may have more clusters than B.
       Join each excess cluster of A into its target — each Join is 1 op.
    """
    a_to_b = {}      # cluster index in A → best target cluster index in B
    for i, ca in enumerate(A):
        best_overlap, best_j = -1, 0
        for j, cb in enumerate(B):
            overlap = len(ca & cb)
            if overlap > best_overlap:
                best_overlap, best_j = overlap, j
        a_to_b[i] = best_j

    moves = 0
    for i, ca in enumerate(A):
        target = B[a_to_b[i]]
        moves += len(ca - target)

    # Join cost: how many distinct A-clusters target each B-cluster?
    target_counts = Counter(a_to_b.values())
    joins = sum(c - 1 for c in target_counts.values())
    return moves + joins
```

**Correct (Step 2 — MoJoFM normalizes to [0, 100]):**

```python
def mojofm(A: list[set], B: list[set]) -> float:
    """
    MoJoFM = (1 - mojo(A, B) / max_mojo(A)) · 100
      where max_mojo(A) = N - 1 (worst case: every node in its own A-cluster,
                                  B is one giant cluster — N-1 joins)
    Wen-Tzerpos TSE 2004 use a tighter max based on the partition pair, but
    the N-1 normalization is the common reproducible variant.
    Returns: 100 = identical, 0 = maximally distant.
    """
    n = sum(len(c) for c in A)
    if n == 0:
        return 100.0
    d = mojo_distance(A, B)
    return (1 - d / (n - 1)) * 100 if n > 1 else 100.0
```

**Correct (Step 3 — apply to validate a clustering against expert ground truth):**

```python
def validate_clustering(predicted_clusters, ground_truth_clusters, files):
    """
    predicted_clusters: list[set[file]]
    ground_truth_clusters: list[set[file]] from expert decomposition
    files: list of all files (both clusterings should cover the same set)
    """
    score = mojofm(predicted_clusters, ground_truth_clusters)
    print(f"MoJoFM = {score:.2f}")

    # Interpretive bands from the SAR literature:
    # > 80  → very close to expert decomposition; publishable result
    # 60-80 → reasonable; comparable to published Bunch / ACDC / Limbo
    # 40-60 → algorithm captures most of the structure; investigate divergences
    # < 40  → fundamental mismatch; rethink the algorithm or the ground truth
    return score
```

**The standard benchmarks to report on:**

| System | Files | Source of ground truth |
|--------|------:|------------------------|
| TOBEY (compiler) | 939 | Hand-crafted by experts; common benchmark |
| Linux kernel | 8,000+ | Subsystem partition from MAINTAINERS file |
| Mozilla | 1,500–10,000 | Module structure from build system |
| Eclipse | 3,000+ | Plugin-bundle structure |
| Apache Tomcat | ~700 | Package structure |
| Apache Hadoop | ~2,000 | Module structure |

For any SAR-paper comparison, report MoJoFM on at least 3 of these. Published baselines (Mitchell-Mancoridis 2006, Andritsos-Tzerpos 2005, Beck-Diehl 2013) cluster between 55 and 85 across systems.

**Why MoJoFM beats ARI / NMI for software:**

| Property | MoJoFM | ARI | NMI |
|----------|--------|-----|-----|
| Operation-based interpretability | yes (Move + Join count) | no | no |
| Asymmetric (toward ground truth) | yes | no | no |
| Published software baselines exist | yes (hundreds) | rare | rare |
| Robust to cluster size imbalance | yes | yes (corrected) | yes |
| Handles overlapping clusters | partial | no | yes (variants) |

Move-and-Join operations correspond to *real refactoring effort* — "X files would need to move to a different package" — making MoJoFM directly interpretable to architects. ARI and NMI report "set similarity" in dimensionless units.

**The Tzerpos-Holt variant — MeCl, EdgeSim:**

For completeness: **EdgeSim** (Mitchell-Mancoridis) measures edge-preservation across clusterings. **MeCl** measures cluster merging cost. **MoJoSim** is MoJo normalized symmetrically. All published as alternatives; MoJoFM remains dominant. Pick MoJoFM unless you have a specific reason for an alternative.

**When NOT to use MoJoFM alone:**

- No ground truth available — pair with intrinsic metrics (modularity Q, MQ, silhouette) and consensus stability.
- Clusterings have very different cluster counts — MoJoFM penalises this; report it but supplement with NMI for symmetric comparison.
- Overlapping / fuzzy clusterings — MoJoFM is defined for hard partitions; use variants of the soft-clustering metric (Filipova-Iordanov 2008).

**Production:** Tzerpos's original MoJo tool (Java) is the reference; available from York University. Python reimplementations are scattered across SAR-replication research; the above ~30-line snippet covers the standard case. The SAR community maintains a registry of expert-decomposition benchmarks (TOBEY, Mozilla, Linux subsets) used in all comparison studies.

Reference: [An Effectiveness Measure for Software Clustering Algorithms (Wen & Tzerpos, IWPC 2004)](https://ieeexplore.ieee.org/document/1311061)
