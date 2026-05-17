---
title: Use Non-Negative Matrix Factorization When You Need Strictly-Positive Topic Weights
impact: MEDIUM-HIGH
impactDescription: deterministic alternative to LDA; 5× faster convergence with parts-based additive interpretation
tags: topic, nmf, lee-seung, additive, parts-based
---

## Use Non-Negative Matrix Factorization When You Need Strictly-Positive Topic Weights

**Non-negative Matrix Factorization** (Lee & Seung, "Learning the parts of objects by non-negative matrix factorization," Nature 1999) factorises a non-negative matrix V (your TF-IDF or count matrix) as V ≈ W · H where W (file × topic) and H (topic × term) are *also non-negative*. The non-negativity constraint forces an **additive parts-based representation**: each file is a positive combination of topics, and each topic is a positive combination of words. No cancellation, no signed dimensions like LSI, no probabilistic interpretation pretence like LDA.

For software clustering, NMF has three practical advantages over LDA: (1) **deterministic** — same input + seed always yields same output, useful for reproducible analyses, (2) **fast** — converges in seconds where LDA takes minutes, (3) **interpretable additive topics** — a file's topic weights are straightforward "how much of each topic", no probabilistic conditioning. The trade-off: no principled way to pick K (no perplexity, no MDL), and the loss function (Frobenius or KL) is non-convex, so initialization matters.

**Incorrect (LDA when you don't actually need probabilistic semantics):**

```python
from sklearn.decomposition import LatentDirichletAllocation

lda = LatentDirichletAllocation(n_components=30, random_state=42, max_iter=100)
W_lda = lda.fit_transform(X)
# Topic-distributions sum to 1 per file (probability). Across runs, topic IDS
# permute even with same seed in some libraries. The "Topic 7" of run A is
# the "Topic 14" of run B — making reproducibility a pain.
```

**Correct (Step 1 — fit NMF on the TF-IDF matrix):**

```python
from sklearn.decomposition import NMF
from sklearn.feature_extraction.text import TfidfVectorizer

vec = TfidfVectorizer(min_df=3, max_df=0.4, sublinear_tf=True, norm="l2")
X = vec.fit_transform(documents)        # F × T

# init="nndsvd" — non-negative double SVD initialization (Boutsidis-Gallopoulos 2008)
# beats random init by ~5-10% on reconstruction loss; deterministic.
# l1_ratio=0.5 — half L1 (sparsity) half L2 — produces sparser, more
# interpretable topic distributions.
nmf = NMF(
    n_components=30,
    init="nndsvd",
    beta_loss="kullback-leibler",   # KL is for count-like data; "frobenius" for general
    solver="mu",                     # multiplicative-update, works with KL
    max_iter=400,
    l1_ratio=0.5,
    alpha_W=0.001,
    alpha_H=0.001,
    random_state=42,
)
W = nmf.fit_transform(X)   # F × K — file's topic weights
H = nmf.components_         # K × T — each topic's word weights
```

**Correct (Step 2 — extract topics and file assignments):**

```python
import numpy as np

def nmf_topic_words(H, feature_names, n_top: int = 10):
    """Each topic = top-n highest-weight terms. Unlike LDA there's no
    probability — these are just additive weights, but they rank meaningfully."""
    topics = []
    for k in range(H.shape[0]):
        top_indices = H[k].argsort()[::-1][:n_top]
        topics.append([feature_names[i] for i in top_indices])
    return topics

def nmf_top_topics_per_file(W, files, top_k: int = 3):
    """Each file's top-k topics by weight. Threshold low weights to noise."""
    result = {}
    for i, f in enumerate(files):
        ranked = sorted(enumerate(W[i]), key=lambda x: -x[1])
        result[f] = [(k, float(w)) for k, w in ranked[:top_k] if w > 0.01]
    return result

topics = nmf_topic_words(H, vec.get_feature_names_out())
for i, t in enumerate(topics):
    print(f"Topic {i:>3}: {', '.join(t)}")
```

**Correct (Step 3 — use NMF coefficients as a dense file embedding):**

```python
# The NMF W matrix IS a low-dimensional embedding of each file.
# Use it directly for downstream clustering / similarity / search.

from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import normalize

W_normalized = normalize(W, norm="l2", axis=1)
file_similarity = cosine_similarity(W_normalized)

# Cluster on the NMF embedding — much smaller than TF-IDF, captures
# the same topic structure that LDA would but deterministically.
from sklearn.cluster import KMeans
clusters = KMeans(n_clusters=15, n_init=10, random_state=42).fit_predict(W_normalized)
```

**Why parts-based additivity matters for code:**

Software files often *literally* combine concerns — a `payment_controller.py` mixes routing + payment + auth + logging. With LSI's signed dimensions, you might find that file weighted high on "payment" but slightly *negative* on "logging" (because of LSI's bipolar structure) which doesn't match the additive reality. NMF gives strictly-positive weights: this file is 0.4 payments + 0.3 routing + 0.15 auth + 0.10 logging — which *is* the parts-based composition.

This is why Lee & Seung titled their paper "Learning the parts of objects" — NMF discovers parts that *add up* to make wholes, exactly like a file adds up multiple concerns.

**Empirical baseline:** Aletras & Stevenson ("Evaluating topic coherence using distributional semantics," IWCS 2013) compared LDA and NMF coherence on the news domain; NMF was within 5% and often higher with l1 regularisation. For software: Asuncion et al. (Information Sciences 2010) and Tian et al. (MSR 2012) reported NMF matching LDA on concept-location F1 (~65–80%) while being ~5× faster to fit and fully reproducible.

**When to use NMF vs LDA:**

| Situation | Choice |
|-----------|--------|
| Need probabilistic per-file topic distributions | LDA |
| Need deterministic, reproducible runs | NMF |
| Need fast iteration (sweeping K) | NMF |
| Need additive parts-based interpretation | NMF |
| Need uncertainty quantification | LDA |
| Hugely-imbalanced topic prior expected | LDA with informative α |

**When NOT to use:**

- You need probability semantics (sampling files from topics, computing held-out likelihood) — LDA is purpose-built; NMF is a regression.
- Very sparse data with few non-zero entries — NMF can converge to degenerate factors. LDA's Dirichlet smoothing handles sparsity better.
- You need hierarchical topics — NMF is flat. Use HDP (`topic-hdp-for-nonparametric-topic-count`) or hierarchical LDA.

**Production:** scikit-learn `NMF` is the workhorse; `nimfa` (Python) has more variants (rank estimation, sparse NMF). Used in image processing (Lee-Seung's original Nature paper used face images), audio source separation, and increasingly in single-cell biology.

Reference: [Learning the parts of objects by non-negative matrix factorization (Lee & Seung, Nature 1999)](https://www.nature.com/articles/44565)
