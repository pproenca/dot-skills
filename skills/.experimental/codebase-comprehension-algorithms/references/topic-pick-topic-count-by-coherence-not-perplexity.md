---
title: Pick The Number Of Topics By Coherence, Not Perplexity
impact: HIGH
impactDescription: perplexity is 43% anti-correlated with human topic quality; C_V coherence correlates 79% (Röder 2015)
tags: topic, coherence, npmi, umass, roder, chang
---

## Pick The Number Of Topics By Coherence, Not Perplexity

Every LDA tutorial recommends choosing K by **perplexity** on held-out documents. **This is wrong**, in a way that has been quantitatively demonstrated since **Chang, Boyd-Graber, Gerrish, Wang, Blei** ("Reading tea leaves: how humans interpret topic models," NIPS 2009) — perplexity is **anti-correlated** with human judgements of topic quality. Optimising for perplexity makes topics statistically tight but **harder to interpret**; conversely, the topics humans find most useful are those with strong **co-occurrence patterns** among top words — captured by **coherence** metrics. **Röder, Both, Hinneburg** ("Exploring the Space of Topic Coherence Measures," WSDM 2015) compared dozens of coherence formulations against human judgement and recommended **C_V** (a sliding-window NPMI variant) as the best single metric, with **U-Mass** as a fast intrinsic alternative.

For codebase comprehension: never pick K by perplexity. Pick by C_V coherence on identifier+comment corpus. The difference in agent-usable output is the difference between *"Topic 13: charge, refund, invoice, stripe, payment"* and *"Topic 13: token, void, function, return, int"*.

**Incorrect (sweep K by perplexity — produces unreadable topics):**

```python
from sklearn.decomposition import LatentDirichletAllocation

# Hold out 20% of the corpus
X_train, X_test = train_test_split(X, test_size=0.2, random_state=42)

best_k, best_perp = None, np.inf
for k in [10, 20, 30, 50, 80, 120]:
    lda = LatentDirichletAllocation(n_components=k, random_state=42).fit(X_train)
    perp = lda.perplexity(X_test)
    if perp < best_perp:
        best_perp, best_k = perp, k
# best_k is typically very large (100-200) — perplexity rewards fine-grained
# topics that fit the data tightly. Topics at K=200 contain ~5 unrelated words
# each — useless.
```

**Correct (Step 1 — implement C_V coherence properly):**

```python
import numpy as np
from collections import Counter, defaultdict

def build_word_cooccurrence(docs: list[list[str]], window: int = 10):
    """
    Sliding-window co-occurrence: for each pair of words appearing within
    `window` tokens of each other, count co-occurrence. C_V uses window=110
    in the original Röder paper; 10-20 works for code documents.
    """
    word_count = Counter()
    pair_count = defaultdict(int)
    n_windows = 0
    for doc in docs:
        for i in range(len(doc)):
            end = min(len(doc), i + window)
            window_words = set(doc[i:end])
            for w in window_words:
                word_count[w] += 1
            for w1 in window_words:
                for w2 in window_words:
                    if w1 < w2:
                        pair_count[(w1, w2)] += 1
            n_windows += 1
    return word_count, pair_count, n_windows

def npmi(w1: str, w2: str, word_count, pair_count, n_windows, eps: float = 1e-12) -> float:
    """
    Normalised Pointwise Mutual Information:
      NPMI(w1, w2) = log(p(w1,w2) / (p(w1)·p(w2))) / -log(p(w1,w2))
    Bounded in [-1, 1]: 1 = always co-occur; 0 = independent; -1 = never.
    """
    p1 = word_count[w1] / n_windows
    p2 = word_count[w2] / n_windows
    key = tuple(sorted([w1, w2]))
    p12 = pair_count.get(key, 0) / n_windows + eps
    if p1 == 0 or p2 == 0 or p12 == eps:
        return 0
    return np.log(p12 / (p1 * p2)) / -np.log(p12)
```

**Correct (Step 2 — compute topic coherence for one topic):**

```python
def topic_coherence_cv(topic_top_words: list[str], word_count, pair_count, n_windows) -> float:
    """
    C_V coherence: pairwise NPMI averaged over (top-word, top-word) pairs.
    Uses the simplified pairwise variant (the full C_V also includes vector
    cosine — see Röder 2015 §3.3 for both).
    """
    pairs = [(topic_top_words[i], topic_top_words[j])
             for i in range(len(topic_top_words))
             for j in range(i + 1, len(topic_top_words))]
    if not pairs:
        return 0
    return float(np.mean([
        npmi(w1, w2, word_count, pair_count, n_windows) for w1, w2 in pairs
    ]))

def model_coherence(topic_model, vocab, word_count, pair_count, n_windows, n_top: int = 10) -> float:
    """Average coherence across all topics."""
    feature_names = vocab
    scores = []
    for k in range(topic_model.components_.shape[0]):
        top_indices = topic_model.components_[k].argsort()[-n_top:][::-1]
        top_words = [feature_names[i] for i in top_indices]
        scores.append(topic_coherence_cv(top_words, word_count, pair_count, n_windows))
    return float(np.mean(scores))
```

**Correct (Step 3 — sweep K by coherence):**

```python
def sweep_k_by_coherence(documents, X, k_values=(5, 10, 20, 30, 50, 80, 120)):
    """For each candidate K, fit LDA and compute mean C_V coherence.
    Pick the K at the coherence maximum (or a plateau)."""
    tokens_per_doc = [d.split() for d in documents]
    wc, pc, nw = build_word_cooccurrence(tokens_per_doc, window=15)
    vocab = vectorizer.get_feature_names_out()

    results = []
    for k in k_values:
        lda = LatentDirichletAllocation(
            n_components=k, random_state=42, max_iter=30,
            doc_topic_prior=0.1, topic_word_prior=0.01,
        ).fit(X)
        coh = model_coherence(lda, vocab, wc, pc, nw)
        results.append((k, coh))
        print(f"K = {k:>3}: C_V coherence = {coh:+.4f}")
    return results

# Typical software-corpus output:
# K =   5: C_V coherence = +0.183
# K =  10: C_V coherence = +0.241
# K =  20: C_V coherence = +0.298   ← peak
# K =  30: C_V coherence = +0.291
# K =  50: C_V coherence = +0.252
# K = 100: C_V coherence = +0.180   ← fragmenting
# Pick K = 20 (or 30; the plateau).
```

**Why perplexity fails:**

Perplexity measures how *predictable* held-out documents are under the model. A model with very many narrow topics can predict held-out documents well (each held-out doc shares a few rare narrow topics with training docs). But narrow topics don't correspond to coherent concepts — they're often noise correlations. Chang et al. demonstrated this with **word intrusion** tasks: hide one word inside a topic's top-10 and ask humans to find it. The human accuracy was *highest* at coherence-optimal K and *lowest* at perplexity-optimal K.

**Empirical baseline:** Röder-Both-Hinneburg (WSDM 2015) compared C_V, NPMI, U-Mass, C_NPMI, C_P, C_A coherence variants across 21 datasets against human judgement: C_V correlated at r = 0.79 with human ratings; perplexity correlated at r = -0.43 (negative!). For software specifically, Mei et al. (2007) and Lukins et al. (TSE 2010) recommended NPMI for software-corpus topic evaluation.

**When NOT to use coherence:**

- You're using LDA as a black-box feature extractor (only the W matrix matters, not the topics themselves) — perplexity is fine since you don't need interpretable topics.
- You don't have a corpus to compute co-occurrence — coherence requires the original tokenised documents.
- Single-topic-per-document setups (collapsed Gibbs LDA with α → 0) — coherence still works but is less informative.

**Production:** `gensim.models.CoherenceModel` implements C_V, U-Mass, C_NPMI, C_UCI. `tmtoolkit` provides a sklearn-compatible wrapper. The original Palmetto Java tool (Röder et al.) is the reference implementation. `octis` is a unified Python framework comparing topic models on coherence — recommended for systematic studies.

Reference: [Exploring the Space of Topic Coherence Measures (Röder, Both, Hinneburg, WSDM 2015)](https://dl.acm.org/doi/10.1145/2684822.2685324)
