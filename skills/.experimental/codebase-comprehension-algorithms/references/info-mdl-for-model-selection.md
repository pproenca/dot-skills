---
title: Use Minimum Description Length To Pick Number Of Clusters Or Topics
impact: MEDIUM-HIGH
impactDescription: eliminates K hyperparameter via information-theoretic trade-off; consistent as N → ∞ (Rissanen 1986)
tags: info, mdl, rissanen, model-selection, parsimony, occams-razor
---

## Use Minimum Description Length To Pick Number Of Clusters Or Topics

The **Minimum Description Length** principle (Rissanen, "Modeling by shortest data description," Automatica 1978) is the information-theoretic formalisation of Occam's razor: among models that explain the data, prefer the one whose **total description length** — code-length to specify the model PLUS code-length to specify the data given the model — is shortest. For clustering and topic modelling, this gives a principled way to choose K: the K that minimises **L(model) + L(data | model)** is the right one.

Many of the algorithms in this skill use MDL internally — **Infomap's map equation** is an MDL formulation; **Peixoto's hierarchical SBM** uses MDL for K selection; **Limbo** is an information-theoretic agglomerative clusterer with an MDL stopping criterion. Knowing the MDL framework lets you (1) pick K for *any* clustering / topic model, (2) compare across different model families on the same footing, and (3) detect overfitting (when L(data | model) drops below L(model) decay → you're memorising noise).

**Incorrect (pick K by eyeballing an elbow on a quality curve):**

```python
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

inertias = []
for k in range(2, 30):
    km = KMeans(n_clusters=k, random_state=42).fit(X)
    inertias.append(km.inertia_)
plt.plot(range(2, 30), inertias)
# Look for an "elbow" by eye. Subjective, irreproducible, often ambiguous.
```

**Correct (Step 1 — MDL for k-means-style clustering):**

```python
import numpy as np
import math

def description_length_kmeans(X: np.ndarray, labels: np.ndarray, k: int) -> dict:
    """
    Two-part code MDL for k-means-style clustering:
      L(model)         = bits to specify k centroids in ℝᵈ
                       = k · d · log2(precision)
      L(data | model)  = bits to encode each point as (cluster_id, residual)
                       = N · log2(k)  +  N · d · log2(σ)
        (centroid id + residual under per-cluster Gaussian assumption)

    Pick k that minimises the total.
    """
    N, d = X.shape
    PRECISION = 256  # 8-bit centroid coordinates; tune for resolution
    L_model = k * d * math.log2(PRECISION)

    # Per-cluster residuals: log2(σ) per dimension per point
    log_terms = []
    for c in range(k):
        members = X[labels == c]
        if len(members) < 2:
            log_terms.append(0)
            continue
        centroid = members.mean(axis=0)
        residuals = members - centroid
        sigma2 = residuals.var(axis=0) + 1e-10
        # Gaussian code-length: N · d · 0.5 · log2(2πe·σ²)
        log_terms.append(0.5 * len(members) * d * np.sum(np.log2(2 * np.pi * np.e * sigma2)))

    L_residual = float(np.sum(log_terms))
    L_assignments = N * math.log2(k) if k > 1 else 0

    return {
        "k": k,
        "L_model": L_model,
        "L_data": L_residual + L_assignments,
        "L_total": L_model + L_residual + L_assignments,
    }
```

**Correct (Step 2 — sweep K and pick by minimum description length):**

```python
from sklearn.cluster import KMeans

def pick_k_by_mdl(X, k_range=range(2, 30)):
    results = []
    for k in k_range:
        km = KMeans(n_clusters=k, n_init=10, random_state=42).fit(X)
        dl = description_length_kmeans(X, km.labels_, k)
        results.append(dl)
        print(f"k={k:2d}  L_model={dl['L_model']:>10.0f}  "
              f"L_data={dl['L_data']:>10.0f}  L_total={dl['L_total']:>10.0f}")
    best = min(results, key=lambda d: d["L_total"])
    return best["k"], results

k_star, curve = pick_k_by_mdl(X)
print(f"MDL-optimal k = {k_star}")
```

**Correct (Step 3 — generalise to LDA / topic models via posterior log-likelihood):**

```python
def description_length_lda(lda, X) -> dict:
    """
    Two-part code MDL for LDA:
      L(model) = (K · |V|) · log2(precision)   [topic-word distributions]
                + (D · K)  · log2(precision)   [doc-topic distributions]
      L(data | model) = -log p(corpus | θ, β)  in bits
    """
    K = lda.n_components
    D, V = X.shape
    PRECISION = 256
    L_model = (K * V + D * K) * math.log2(PRECISION)
    # Log-likelihood of corpus under fitted model (sklearn returns it in nats):
    log_likelihood = lda.score(X)  # sum over docs, in nats
    L_data = -log_likelihood / math.log(2)
    return {"K": K, "L_model": L_model, "L_data": L_data,
            "L_total": L_model + L_data}

# Sweep K for LDA, pick MDL minimum — alternative to coherence
# (see topic-pick-topic-count-by-coherence-not-perplexity).
```

**Why MDL is principled:**

Description length composes naturally: if you have model M and data D, total compressed size is **L(M) + L(D | M)**. Adding parameters to M lowers L(D | M) (better fit) but raises L(M). MDL says: find the trade-off that minimises the total. **It is mathematically equivalent to maximising posterior probability under a uniform prior** — a fully Bayesian justification. Unlike AIC and BIC (which approximate it under stronger assumptions), MDL works for any model class where you can compute code-lengths.

**Practical notes:**

| Pitfall | Workaround |
|---------|------------|
| Continuous parameters need "precision" — what bit-width? | Use 8-bit (256 values per parameter) as default; the choice usually doesn't change K* by more than ±1 |
| Two-part code is an *upper bound* on MDL | For tighter, use **NML (Normalized Maximum Likelihood)** or **stochastic complexity** — see Grünwald book |
| Different model classes use different code books | Compare *like with like*: kmeans vs kmeans across K, LDA vs LDA across K. Cross-family comparison needs careful normalization |

**Empirical baseline:** Rissanen (Annals of Statistics 1986, "Stochastic complexity and modeling") proved MDL is consistent — it picks the right model with probability 1 as N → ∞. For finite-data clustering: Hansen-Yu (J. Amer. Statist. Assoc. 2001) showed MDL beats AIC and BIC on simulation studies for choosing the number of mixture components. Peixoto's hierarchical SBM uses MDL throughout and produces decompositions that match expert ground truth within MoJoFM = 75–90% on standard software benchmarks.

**When NOT to use MDL:**

- You actively prefer a fixed K from external constraints (target architecture has 5 services — fit K = 5 even if MDL says 7).
- Cross-validation is available and computationally feasible — CV is often easier to explain and roughly equivalent for clustering.
- The model class doesn't have a natural code book (kernel methods, deep networks) — MDL is hard to apply; use cross-validation or held-out likelihood.

**Production:** MDL is implicit in Peixoto's `graph-tool`, Rosvall-Bergstrom's Infomap, Andritsos-Tzerpos's Limbo. Direct MDL libraries: `mdl-pca` for PCA component selection; `pymdl` for general MDL applications. The Grünwald book (*The Minimum Description Length Principle*, MIT 2007) is the canonical reference.

Reference: [Modeling by Shortest Data Description (Rissanen, Automatica 1978)](https://www.sciencedirect.com/science/article/abs/pii/0005109878900055)
