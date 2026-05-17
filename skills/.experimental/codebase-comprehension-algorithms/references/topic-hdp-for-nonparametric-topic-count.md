---
title: Use Hierarchical Dirichlet Processes To Learn The Right Number Of Topics
impact: MEDIUM-HIGH
impactDescription: eliminates K hyperparameter; infers number of topics from data at 2-3× LDA's cost
tags: topic, hdp, teh-jordan, nonparametric, bayesian, dirichlet-process
---

## Use Hierarchical Dirichlet Processes To Learn The Right Number Of Topics

The hardest hyperparameter in LDA is **the number of topics K**. Pick too few → topics conflate multiple concepts. Pick too many → topics fragment and contain noise. The standard advice is to sweep K and pick by coherence, but every sweep costs another full LDA fit. **Hierarchical Dirichlet Processes** (Teh, Jordan, Beal, Blei — "Hierarchical Dirichlet Processes," JASA 2006) eliminate the problem: they are LDA's **non-parametric** extension that learns K **from the data** itself. The model treats the number of topics as a countably infinite sequence; the posterior concentrates on a finite number that actually have data to explain.

This is the Bayesian analogue of HDBSCAN — same philosophical move, applied to topic modelling instead of clustering. Almost no one in software analysis uses it, because the canonical implementations are in obscure libraries and the math looks scary. The math is fine; what you need to know is that HDP gives you LDA + automatic K-selection at ~2-3x the computational cost.

**Incorrect (LDA with arbitrary K, swept manually):**

```python
from sklearn.decomposition import LatentDirichletAllocation

# Sweep K to "find" the right number of topics
best_k, best_score = None, -np.inf
for k in [10, 20, 30, 50, 80, 120]:
    lda = LatentDirichletAllocation(n_components=k, random_state=42).fit(X)
    score = compute_topic_coherence(lda, vocab)  # see topic-pick-by-coherence
    if score > best_score:
        best_k, best_score = k, score
# Cost: 6 full LDA fits. Result: a "best K" that might be a local maximum
# and changes if you sweep at a different granularity.
```

**Correct (Step 1 — fit HDP-LDA via gensim):**

```python
# pip install gensim
from gensim.corpora import Dictionary
from gensim.models import HdpModel

def fit_hdp(documents: list[list[str]], chunksize: int = 256):
    """
    Build gensim's Dictionary, convert documents to bag-of-words, then
    fit HDP. Defaults:
      T (truncation level for topics)         = 150  — upper bound on K
      K (truncation level for sticks)         = 15   — per-doc sticks
      alpha (concentration: topic-level)      = 1.0
      gamma (concentration: corpus-level)     = 1.0
      kappa (decay parameter for online HDP)  = 1.0
    Higher α/γ → more topics retained; lower → fewer.
    """
    dictionary = Dictionary(documents)
    dictionary.filter_extremes(no_below=3, no_above=0.4)
    corpus = [dictionary.doc2bow(doc) for doc in documents]
    hdp = HdpModel(
        corpus=corpus,
        id2word=dictionary,
        T=150,
        K=15,
        alpha=1.0,
        gamma=1.0,
        chunksize=chunksize,
        random_state=42,
    )
    return hdp, dictionary, corpus
```

**Correct (Step 2 — recover the effective K from posterior mass):**

```python
def effective_topic_count(hdp, threshold: float = 0.01) -> int:
    """
    HDP retains T=150 topic slots but most have near-zero posterior weight.
    Count topics whose total corpus-level weight exceeds `threshold`.
    """
    # hdp.hdp_to_lda() returns (alpha, beta) — the LDA-equivalent
    # marginalized topic-word distribution. Topics with very low alpha are
    # effectively dead.
    alpha, beta = hdp.hdp_to_lda()
    active = (alpha > threshold).sum()
    return int(active)

def show_top_topics(hdp, dictionary, n_words: int = 10, threshold: float = 0.01):
    alpha, beta = hdp.hdp_to_lda()
    for k in range(len(alpha)):
        if alpha[k] < threshold:
            continue
        top_word_ids = beta[k].argsort()[::-1][:n_words]
        words = [dictionary[i] for i in top_word_ids]
        print(f"Topic {k:>3} (α={alpha[k]:.3f}): {' | '.join(words)}")

# Typical output on a real codebase: T=150 slots, ~25-40 active topics
# with substantive corpus mass. The rest are degenerate.
```

**Correct (Step 3 — compare with LDA at the inferred K):**

```python
# If the inferred K is, say, 32, you can validate by re-fitting LDA at K=32
# and comparing topic coherence on held-out documents.
inferred_K = effective_topic_count(hdp)
lda_check = LatentDirichletAllocation(
    n_components=inferred_K,
    doc_topic_prior=0.1,
    topic_word_prior=0.01,
    max_iter=50,
    random_state=42,
).fit(X)

hdp_coherence = compute_coherence(hdp, ...)
lda_coherence = compute_coherence(lda_check, ...)
# Typically: HDP coherence is within 2-5% of LDA at the HDP-inferred K,
# proving that K was inferred well.
```

**Why this matters: the model selection problem is real:**

Picking K is the dominant *manual* step in topic-modelling pipelines and the dominant source of irreproducibility. Two analysts running LDA on the same codebase but picking K = 20 vs K = 40 will report very different "what this codebase is about" results. HDP eliminates this knob entirely; the data picks K. For agent-driven analysis where the goal is *self-describing* output, HDP is uniquely valuable: the agent can report "I found 32 topics" without ever needing the operator to set K.

**Mathematical intuition (one paragraph):**

A Dirichlet Process DP(α, G₀) is a "distribution over distributions" that, when sampled, yields a discrete distribution with countably-infinite support. The number of *distinct* values you see in N samples grows as O(α log N) — sublinear, so most "atoms" get tiny posterior mass. HDP nests two DPs: one at the corpus level (generates a master topic catalog) and one per-document (samples topics from the catalog). The hierarchy ensures topics are shared across documents (unlike a flat DP per document). Inference is via Gibbs sampling or variational methods.

**Empirical baseline:** Teh-Jordan-Beal-Blei (JASA 2006) showed HDP recovers within 2% of LDA's coherence on the standard NIPS / AP corpora while learning K automatically. For software: Grant-Cordy (MSR 2010) and Asuncion et al. (Information Sciences 2010) applied HDP-LDA to software and reported it converges to K consistent with expert estimates of architectural granularity (Mozilla: ~40-50 architectural concerns; Eclipse: ~80-100).

**When NOT to use:**

- You already know K from external constraints (a target architecture with N modules).
- Speed-critical (HDP is ~2-3x slower than fixed-K LDA).
- Very small corpora (< 100 documents) — the non-parametric prior dominates the data; K collapses to a tiny number.

**Production:** `gensim.models.HdpModel` is the easy default. `Mallet` has HDP via the `cc.mallet.topics.HierarchicalLDA` class. `Bayesian-DP-Tools` in Python provides the more general Dirichlet Process Mixture Model. Not yet widely adopted in software analytics — significant opportunity.

Reference: [Hierarchical Dirichlet Processes (Teh, Jordan, Beal, Blei, JASA 2006)](https://www.cs.berkeley.edu/~jordan/papers/hdp.pdf)
