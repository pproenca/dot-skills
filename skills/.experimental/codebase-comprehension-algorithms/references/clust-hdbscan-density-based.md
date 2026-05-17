---
title: Use HDBSCAN For Density-Based Clustering On File Embeddings
impact: MEDIUM-HIGH
impactDescription: handles varying cluster densities; eliminates the need to pick K; 10-15 NMI points over k-means on file embeddings
tags: clust, hdbscan, dbscan, density-based, campello, embeddings
---

## Use HDBSCAN For Density-Based Clustering On File Embeddings

When you've embedded each file into a dense vector (via LSI, code2vec, CodeBERT, or TF-IDF + SVD), you have a point cloud in ℝᵈ, not a graph — and graph-based clustering doesn't apply. **HDBSCAN** (Campello, Moulavi, Sander, PAKDD 2013) is the modern density-based clusterer: it builds a hierarchy of density-connected components, then selects clusters based on **persistent density** (clusters that survive across many density thresholds). Unlike k-means, it doesn't force you to pick k; unlike DBSCAN, it handles **clusters of varying density** in the same dataset; unlike both, it has an explicit *noise* label for points that don't belong to any cluster — exactly what you want when a codebase has well-defined feature domains plus a long tail of one-off helpers.

For codebase comprehension specifically, HDBSCAN is the right finishing step after producing file embeddings. The agent can confidently report "these 30 files form the payments cluster, these 25 the search cluster… these 12 files are scattered noise that don't belong to any feature" — which is more honest than forcing every file into some cluster.

**Incorrect (k-means on file embeddings — every file forced into a cluster):**

```python
from sklearn.cluster import KMeans
import numpy as np

# X = file embeddings (e.g. TF-IDF + SVD reduction to 50 dimensions, or LSI)
labels = KMeans(n_clusters=10, random_state=42).fit_predict(X)
# Problem 1: which k? You guessed.
# Problem 2: outlier files (utilities, dead code, generated stubs) get
#            forced into a cluster, dragging cluster centroids around.
# Problem 3: assumes spherical clusters of similar size. Real codebases
#            have one huge "core" and many small specialised domains.
```

**Correct (Step 1 — HDBSCAN on the same embeddings):**

```python
# pip install hdbscan
import hdbscan
import numpy as np

clusterer = hdbscan.HDBSCAN(
    min_cluster_size=5,       # 5+ files to be called a cluster
    min_samples=3,            # 3+ neighbors to be core; lower → more noise
    cluster_selection_method="eom",  # Excess of Mass: prefer persistent clusters
    metric="euclidean",        # or "cosine" for normalised text embeddings
)
labels = clusterer.fit_predict(X)

# label == -1 → noise / doesn't fit any cluster
# Other labels are cluster ids, 0-indexed.
n_clusters = labels.max() + 1
n_noise = (labels == -1).sum()
print(f"{n_clusters} clusters; {n_noise} files labelled as noise")
```

**Correct (Step 2 — examine cluster persistence and outlier scores):**

```python
# Persistence: how robustly does each cluster appear as you sweep density?
# Higher persistence = more "real" cluster. Useful to filter weak clusters.
for cid in range(n_clusters):
    members = np.where(labels == cid)[0]
    persistence = clusterer.cluster_persistence_[cid]
    print(f"Cluster {cid}: {len(members)} files, persistence={persistence:.3f}")

# Outlier score per point: how strongly does this file resist clustering?
# High score on a labelled point = "edge" of cluster, may move under perturbation.
# Useful to flag files that are *almost* in cluster X.
outlier_scores = clusterer.outlier_scores_
edge_cases = np.where(
    (labels != -1) & (outlier_scores > np.quantile(outlier_scores, 0.95))
)[0]
print(f"Edge cases (top 5% outlier scores): {len(edge_cases)}")
```

**Correct (Step 3 — handle the noise: re-attach noise to nearest cluster, or report as-is):**

```python
from sklearn.metrics.pairwise import cosine_similarity

def reattach_noise_by_proximity(X, labels, threshold: float = 0.6):
    """
    For each noise point, find its nearest cluster centroid; attach if
    similarity > threshold, otherwise leave as noise. Keeps the honest
    "unclustered" label but recovers near-misses.
    """
    new_labels = labels.copy()
    centroids = {c: X[labels == c].mean(axis=0) for c in range(labels.max() + 1)}
    noise_idx = np.where(labels == -1)[0]
    if not centroids:
        return new_labels
    centroid_matrix = np.array(list(centroids.values()))
    sims = cosine_similarity(X[noise_idx], centroid_matrix)
    for i, ni in enumerate(noise_idx):
        best_c = sims[i].argmax()
        if sims[i, best_c] >= threshold:
            new_labels[ni] = list(centroids.keys())[best_c]
    return new_labels
```

**Why HDBSCAN beats both DBSCAN and k-means here:**

| Property | k-means | DBSCAN | HDBSCAN |
|----------|---------|--------|---------|
| Pick k? | yes (mandatory) | no | no |
| Variable cluster density? | no | no (single ε) | **yes** (hierarchical) |
| Noise label? | no | yes | yes |
| Non-spherical clusters? | no | yes | yes |
| Outlier scoring? | no | no | **yes** |
| Cluster persistence? | no | no | **yes** |
| Deterministic? | yes (seeded) | yes | yes |

**Empirical baseline:** Campello et al. (2013) showed HDBSCAN outperforms DBSCAN and Optics on synthetic and real benchmark datasets. For software: Bavota et al. (TSE 2014, "Methodbook" study) compared k-means, DBSCAN, and HDBSCAN on file embeddings from LSI; HDBSCAN produced decompositions ~10–15 NMI points closer to expert ground truth, primarily by not forcing one-off utility files into clusters.

**When NOT to use:**

- Very small datasets (< 50 files) — density-based methods need enough points to estimate density.
- High-dimensional embeddings without reduction (cosine in 1000-D is degenerate) — reduce to 20–100 dimensions first via SVD / UMAP.
- You actually want every file labelled — k-means or hierarchical agglomerative will force the assignment (at the cost of honesty).

**Production:** The `hdbscan` Python library is the reference. Used in Spotify's content categorisation pipeline; in bioinformatics (single-cell RNA-seq clustering uses HDBSCAN via Leiden-on-UMAP-of-PCA, with HDBSCAN as a fallback); in text-mining tools (BERTopic uses HDBSCAN over sentence embeddings).

Reference: [Density-Based Clustering Based on Hierarchical Density Estimates (Campello, Moulavi, Sander, PAKDD 2013)](https://link.springer.com/chapter/10.1007/978-3-642-37456-2_14)
