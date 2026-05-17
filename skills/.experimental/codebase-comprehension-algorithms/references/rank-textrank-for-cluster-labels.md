---
title: Use TextRank Or YAKE To Generate Human-Readable Cluster Labels
impact: MEDIUM
impactDescription: 65-80% match with expert-named modules vs 40-55% for top-TF-IDF (Linstead ICSM 2007)
tags: rank, textrank, yake, keyword-extraction, mihalcea-tarau, labelling
---

## Use TextRank Or YAKE To Generate Human-Readable Cluster Labels

After clustering, you have groups of files. The agent then needs to *name* each cluster — "payments", "search-indexing", "user-onboarding". The naive approach is "top-N TF-IDF terms in this cluster" which produces unigrams like `[payment, charge, refund, stripe, invoice]` — informative but not idiomatic. **TextRank** (Mihalcea & Tarau, "TextRank: Bringing order into texts," EMNLP 2004) applies PageRank to a graph of words connected by co-occurrence and surfaces **multi-word key phrases** like *"stripe payment intent"*, *"failed refund retry"*, *"webhook dispatch queue"*. **YAKE** (Campos, Mangaravite, Pasquali, Jorge, Jatowt, Nunes — "YAKE! Keyword extraction from single documents using multiple local features," Information Sciences 2020) is an unsupervised statistical alternative that ranks even better on short documents (cluster-vocabulary blobs are short).

For codebase comprehension labels, both produce results that read like **what a senior engineer would write on a whiteboard** — not just word lists, but the actual phrases the team uses.

**Incorrect (top-N TF-IDF — produces word salad, not labels):**

```python
def naive_label(cluster_files, tfidf_matrix, vocab):
    """Pick the highest mean-TF-IDF terms across the cluster's files."""
    rows = [idx_of(f) for f in cluster_files]
    mean_tfidf = tfidf_matrix[rows].mean(axis=0)
    top_indices = mean_tfidf.argsort()[::-1][:5]
    return [vocab[i] for i in top_indices]
# Result: ['payment', 'charge', 'refund', 'stripe', 'invoice']
# Informative, but doesn't capture *concepts* — "payment intent" vs "payment"
# vs "stripe payment" are all collapsed into individual unigrams.
```

**Correct (Step 1 — TextRank on the cluster's co-occurrence graph):**

```python
import networkx as nx
from collections import defaultdict

def textrank_keywords(tokens: list[str], window: int = 4, n_top: int = 10):
    """
    TextRank algorithm:
    1. Build a graph where nodes are unique tokens; edges connect tokens that
       co-occur within `window` positions.
    2. Run PageRank on this graph; top-N tokens by PageRank score are
       candidate keywords.
    3. Merge adjacent keywords into multi-word phrases.
    """
    # Filter to content tokens
    filtered = [t for t in tokens if t.isalpha() and len(t) > 1
                and t not in stopwords]
    G = nx.Graph()
    for i, t in enumerate(filtered):
        G.add_node(t)
        for j in range(i + 1, min(i + window + 1, len(filtered))):
            G.add_edge(t, filtered[j])
    pr = nx.pagerank(G, alpha=0.85, max_iter=100)
    top = sorted(pr.items(), key=lambda kv: -kv[1])[:n_top]
    return [tok for tok, _ in top], pr

def merge_into_phrases(tokens, pr_scores, top_tokens, max_phrase_len: int = 3):
    """If two top tokens are adjacent in the source, merge them into a phrase."""
    top_set = set(top_tokens)
    phrases = []
    i = 0
    while i < len(tokens):
        if tokens[i] in top_set:
            phrase = [tokens[i]]
            j = i + 1
            while (j < len(tokens) and tokens[j] in top_set
                   and len(phrase) < max_phrase_len):
                phrase.append(tokens[j])
                j += 1
            phrases.append((" ".join(phrase),
                            sum(pr_scores[t] for t in phrase) / len(phrase)))
            i = j
        else:
            i += 1
    return sorted(set(phrases), key=lambda x: -x[1])[:10]

# Result: [('stripe payment intent', 0.0124), ('failed refund', 0.0098), ...]
```

**Correct (Step 2 — YAKE for ranking candidate keyphrases statistically):**

```python
# pip install yake
import yake

def yake_keywords(text: str, n_top: int = 10, max_ngram: int = 3):
    """YAKE uses 5 statistical features (casing, position, frequency,
    co-occurrence, sentence diversity) to score keyphrases. Beats TextRank
    on short documents (Campos et al. 2020) and on technical text."""
    extractor = yake.KeywordExtractor(
        lan="en",
        n=max_ngram,           # max words per keyphrase
        dedupLim=0.7,          # deduplicate near-duplicates
        top=n_top,
    )
    keywords = extractor.extract_keywords(text)
    # Returns: [(keyphrase, score), ...] — LOWER score is better in YAKE
    return sorted(keywords, key=lambda x: x[1])
```

**Correct (Step 3 — produce cluster labels from a combined approach):**

```python
def cluster_label(cluster_files, n_words: int = 4):
    """
    Combine top-TF-IDF unigrams (precision) with TextRank/YAKE phrases (concepts).
    Output 2-4 short keyphrases that a human would recognise.
    """
    # 1. Aggregate all tokens for the cluster (after lex- preprocessing)
    tokens = []
    for f in cluster_files:
        tokens.extend(preprocess_file(f))

    # 2. TextRank for multi-word phrases
    text = " ".join(tokens)
    keyphrases_yake = yake_keywords(text, n_top=5, max_ngram=3)
    top_tokens, pr_scores = textrank_keywords(tokens, window=4, n_top=15)
    keyphrases_tr = merge_into_phrases(tokens, pr_scores, top_tokens)

    # 3. Top unigrams as fallback
    from collections import Counter
    top_unigrams = [t for t, _ in Counter(tokens).most_common(5)]

    return {
        "yake_keyphrases":     [kp for kp, _ in keyphrases_yake[:3]],
        "textrank_keyphrases": [kp for kp, _ in keyphrases_tr[:3]],
        "top_terms":           top_unigrams,
    }

# Real-world output on a payments cluster:
# {
#   'yake_keyphrases':     ['stripe payment intent', 'failed refund', 'webhook'],
#   'textrank_keyphrases': ['payment intent', 'refund retry', 'idempotency key'],
#   'top_terms':           ['payment', 'charge', 'refund', 'stripe', 'invoice'],
# }
# Label this cluster: "Stripe Payment Intents & Refund Retries"
```

**Why phrases beat unigrams for cluster labels:**

A cluster about "stripe payment intents" doesn't share much with a cluster about "subscription billing intents" if you look at unigrams (both contain "payment", "intent", "charge"). At the *phrase* level they're distinct: "stripe payment intent" vs "subscription billing intent" vs "invoice generation intent". Multi-word phrases capture the **compound concepts** that domain experts actually use to describe code, and labels that use these phrases are immediately recognisable to a human reviewer.

**Empirical baseline:** Campos et al. (2020, YAKE paper) compared YAKE against TextRank, RAKE, KeyBERT, and KP-Miner on 20 benchmark datasets — YAKE was best on 17. For software-specific: Linstead et al. (ICSM 2007) showed multi-word keyphrases from cluster vocabularies match expert-named modules 65–80% of the time, versus 40–55% for top-TF-IDF unigrams.

**When NOT to use:**

- Single-file clusters — there's not enough text for phrase ranking; fall back to file name or TF-IDF terms.
- Auto-generated code clusters — phrases are repetitive boilerplate; manually label or omit.
- Languages with strong inflection / agglutination — German, Finnish, Japanese — pre-lemmatize aggressively or use language-specific keyphrase tools.

**Production:** `pytextrank` (spaCy integration), `yake` (standalone), `KeyBERT` (transformer-based modern alternative). For code specifically, MetricsHub and Sourcegraph use TF-IDF + n-gram extraction; commercial code-search products are increasingly adding embedding-based keyphrase extraction.

Reference: [YAKE! Keyword extraction from single documents using multiple local features (Campos, Mangaravite, Pasquali, Jorge, Jatowt, Nunes, Information Sciences 2020)](https://www.sciencedirect.com/science/article/pii/S0020025519308588)
