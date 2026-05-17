---
title: Use Limbo To Cluster Files By Preserving Information About Their Features
impact: HIGH
impactDescription: 2-5× faster than Bunch's genetic-algorithm variant with comparable MoJoFM; applies Information Bottleneck principle
tags: arch, limbo, information-bottleneck, andritsos, tzerpos, tishby
---

## Use Limbo To Cluster Files By Preserving Information About Their Features

**Limbo** (sCAlable Information BOttleneck — **Andritsos & Tzerpos, WCRE 2003 / ICSE 2005**) applies **Tishby's Information Bottleneck method** (Tishby, Pereira, Bialek, "The information bottleneck method," 1999) to software clustering. The Information Bottleneck framework asks a fundamentally different question from modularity or MQ: *"Compress the file representation into k clusters while preserving as much information as possible about what features each file has."* Mathematically: minimise mutual information I(File; Cluster) subject to maximising I(Cluster; Feature). The result is the **most-compressed possible cluster assignment that still tells you almost everything about each file's features.**

This is one of the most theoretically grounded clustering algorithms in software engineering, and almost no one outside the SAR research community has heard of it. Limbo's contribution is making the IB framework *scalable* via the **DCF (Distributional Cluster Features) matrix** — a single representation of each cluster as a probability distribution over features, updated incrementally as clusters merge.

**Incorrect (TF-IDF + cosine + k-means — picks k arbitrarily, no information-theoretic guarantee):**

```python
from sklearn.cluster import KMeans
from sklearn.feature_extraction.text import TfidfVectorizer

vec = TfidfVectorizer().fit_transform(file_term_strings)
labels = KMeans(n_clusters=8, random_state=42).fit_predict(vec)
# Result: a partition. No way to say "is k=8 enough features preserved?"
# or "how much information did I lose by compressing into 8 clusters?"
```

**Correct (Step 1 — build the file × feature joint distribution):**

```python
import numpy as np
from collections import Counter, defaultdict

def build_joint_distribution(files: dict[str, list[str]]):
    """
    p(file, feature) = (count of feature in file) / (total count in all files)
    Features can be: identifier tokens, import targets, AST node types, etc.
    Mixing feature types is fine — Limbo treats them uniformly.
    """
    all_features = set()
    counts = defaultdict(Counter)
    total = 0
    for f, feats in files.items():
        c = Counter(feats)
        counts[f] = c
        all_features.update(feats)
        total += sum(c.values())

    feature_list = sorted(all_features)
    feat_idx = {f: i for i, f in enumerate(feature_list)}
    file_list = sorted(files)

    P = np.zeros((len(file_list), len(feature_list)))
    for i, f in enumerate(file_list):
        for feat, cnt in counts[f].items():
            P[i, feat_idx[feat]] = cnt / total
    # p(file) = row sums, p(feat) = col sums, p(feat | file) = row-normalized
    return P, file_list, feature_list
```

**Correct (Step 2 — agglomerative IB clustering with the DCF matrix):**

```python
def jensen_shannon_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """JSD is the IB merge cost: how much information is lost merging
    distributions p and q. Symmetric, bounded, finite for sparse distributions."""
    m = 0.5 * (p + q)
    p_safe = np.where(p > 0, p, 1)
    q_safe = np.where(q > 0, q, 1)
    m_safe = np.where(m > 0, m, 1)
    kl_pm = np.sum(p * (np.log2(p_safe) - np.log2(m_safe))) if p.sum() > 0 else 0
    kl_qm = np.sum(q * (np.log2(q_safe) - np.log2(m_safe))) if q.sum() > 0 else 0
    return 0.5 * (kl_pm + kl_qm)

def limbo(P, k_target: int):
    """
    Each row of P is a file's distribution over features. Iteratively merge
    the two files (clusters) whose JSD-weighted merge cost is minimum,
    until k_target clusters remain. The merge cost is the information loss
    incurred by representing both as one cluster.
    """
    n = P.shape[0]
    clusters = [{i} for i in range(n)]
    distributions = [P[i].copy() for i in range(n)]
    weights = [P[i].sum() for i in range(n)]

    while len(clusters) > k_target:
        best_cost = float("inf")
        best_pair = None
        for i in range(len(clusters)):
            for j in range(i + 1, len(clusters)):
                w_i, w_j = weights[i], weights[j]
                if w_i + w_j == 0: continue
                p_i = distributions[i] / w_i if w_i else distributions[i]
                p_j = distributions[j] / w_j if w_j else distributions[j]
                cost = (w_i + w_j) * jensen_shannon_divergence(p_i, p_j)
                if cost < best_cost:
                    best_cost = cost
                    best_pair = (i, j)
        i, j = best_pair
        clusters[i] |= clusters[j]
        distributions[i] += distributions[j]
        weights[i] += weights[j]
        del clusters[j], distributions[j], weights[j]
    return clusters
```

**Correct (Step 3 — pick k from the information-loss curve):**

```python
def limbo_information_curve(P, k_range=(2, 30)):
    """
    Limbo's killer feature: at each merge step, you know exactly how much
    mutual information I(Cluster; Feature) you've lost. Plot the loss curve
    and pick k at the "knee" (the largest drop in marginal information).
    """
    losses = {}
    # Re-run limbo at each k; in practice cache the dendrogram and read off.
    for k in range(k_range[0], k_range[1] + 1):
        clusters = limbo(P.copy(), k_target=k)
        # I(C; F) = Σ p(c) Σ p(f|c) log [p(f|c) / p(f)]
        total_info = 0
        p_f = P.sum(axis=0)
        for c in clusters:
            cluster_dist = P[list(c)].sum(axis=0)
            p_c = cluster_dist.sum()
            if p_c == 0: continue
            p_f_given_c = cluster_dist / p_c
            safe = (p_f_given_c > 0) & (p_f > 0)
            total_info += p_c * np.sum(p_f_given_c[safe] * np.log2(p_f_given_c[safe] / p_f[safe]))
        losses[k] = total_info
    return losses
```

**Why the IB framework is the principled answer:**

When you cluster, you make a lossy compression: F (files) → C (clusters). You want C to be small (compression) but to preserve information about whatever you care about — call it Y (features, behaviour, future tasks). The IB optimum minimises I(F; C) − β · I(C; Y) for some trade-off β. As β increases, you preserve more about Y at the cost of less compression. The Limbo dendrogram traces the entire frontier; you pick the operating point.

For software: F = files, Y = features (identifiers, imports, etc.), C = clusters. The clusters at any cut of the Limbo dendrogram are the *most informative* clusters of that size — a guarantee that modularity, MQ, or k-means cannot provide.

**Empirical baseline:** Andritsos & Tzerpos (ICSE 2005) showed Limbo matches or beats Bunch on TOBEY, Linux kernel, Mozilla, and X11 on MoJoFM, while being **2–5× faster than Bunch's genetic-algorithm variant** on systems > 1000 files (Bunch with hill-climbing is comparable in wall-clock to Limbo). The information-loss curve also makes Limbo *self-describing*: you can see exactly when adding more clusters stops helping.

**When NOT to use:**

- Very small datasets — IB needs reasonable joint distributions; few files means sparse, noisy estimates.
- Non-distributional features (continuous, ordinal) — IB's framework is for *categorical* features. Use spectral or HDBSCAN on continuous embeddings.
- Speed-critical streaming clustering — Limbo is O(n²) per merge step; not online.

**Production:** Original `LIMBO` tool from York University. Re-implementations exist in research papers; the `pyLIMBO` Python port has the agglomerative variant. The IB framework itself has many implementations (`information_bottleneck` package) but software-specific tooling is rare.

Reference: [Information-Theoretic Software Clustering (Andritsos & Tzerpos, WCRE 2003)](https://www.cs.toronto.edu/~periklis/pubs/wcre03.pdf)
