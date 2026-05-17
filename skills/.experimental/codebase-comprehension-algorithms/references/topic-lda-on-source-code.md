---
title: Use LDA On Source Code To Surface Latent Domain Topics
impact: HIGH
impactDescription: 60-85% topic-domain alignment with expert labels on Java systems (Linstead ICSM 2007)
tags: topic, lda, blei, gibbs, maletic-marcus, source-code
---

## Use LDA On Source Code To Surface Latent Domain Topics

**Latent Dirichlet Allocation** (Blei, Ng, Jordan, JMLR 2003) is the probabilistic topic model. Each document (file) is treated as a mixture of K topics; each topic is a distribution over words (after the lexical preprocessing pipeline — splitting, stopwords, stemming). The Gibbs-sampler inference recovers both **the per-file topic distribution** ("this file is 60% payments, 30% logging, 10% testing") and **the per-topic word distribution** ("Topic 7 is high on (charge, refund, invoice, stripe, payment_method)"). For codebase comprehension this is the missing piece: clustering tells you *which files belong together*; LDA tells you *what they're about*, in a few interpretable English words.

LDA on source code was pioneered by **Maletic & Marcus** (ICSM 2003 with LSI; ICSE 2004 extension); **Linstead et al.** (ICSM 2007, "Mining concepts from code with probabilistic topic models") applied LDA specifically and showed topics correspond well to domain concepts. The non-obvious parts: (1) treat identifier tokens *plus comments* as the document, (2) use a number of topics K **larger than expected** (~50–100 even for medium codebases) and let topics specialise, (3) measure quality with **coherence**, not perplexity (see `topic-pick-topic-count-by-coherence-not-perplexity`).

**Incorrect (LDA on raw source text with default English settings — produces topic noise):**

```python
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer

# Feeding raw source code; default English stopwords don't filter "void",
# "int", "function". Identifiers like "userId" become one opaque token.
docs = [open(f).read() for f in iter_source_files(repo)]
X = CountVectorizer(stop_words="english", max_features=5000).fit_transform(docs)
lda = LatentDirichletAllocation(n_components=10, random_state=42).fit(X)
# Topics look like:
#   Topic 0: function, int, void, return, if, else, void, return, int, function
#   Topic 1: void, return, function, int, ...
# Useless.
```

**Correct (Step 1 — preprocess identifiers properly before LDA):**

```python
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer

# Use the lex- pipeline:
#   1) Samurai split             (lex-split-identifiers-with-samurai)
#   2) Expand abbreviations      (lex-expand-abbreviations-with-context)
#   3) Programming stop-words    (lex-build-programming-language-stop-words)
#   4) Porter stem               (lex-stem-versus-subword-tokenization)

def preprocess(file_path):
    raw_tokens = extract_identifier_and_comment_tokens(file_path)
    tokens = samurai_split_all(raw_tokens)
    tokens = expand_tokens(tokens, mined_expansions)
    tokens = [t for t in tokens if t not in stopwords]
    tokens = [porter.stem(t) for t in tokens]
    return " ".join(tokens)

documents = [preprocess(f) for f in iter_source_files(repo)]

# CountVectorizer with conservative min_df / max_df:
# min_df=3   — drop terms appearing in only 1-2 files (hapaxes)
# max_df=0.4 — drop terms appearing in over 40% of files (residual stop-words)
vec = CountVectorizer(min_df=3, max_df=0.4, max_features=10000)
X = vec.fit_transform(documents)
```

**Correct (Step 2 — fit LDA with sane hyperparameters and inspect topics):**

```python
def fit_lda(X, n_topics: int = 50, max_iter: int = 50, seed: int = 42):
    """
    Hyperparameter notes:
    - n_topics: start at 50 for ~500-2000 files; 100+ for larger.
                Underspecifying produces "junk topics" of mixed concepts.
    - doc_topic_prior (α): 0.1 (sparse — each file has few dominant topics)
    - topic_word_prior (η): 0.01 (sparse — each topic has few dominant words)
    - learning_method: "batch" for accuracy; "online" for >50K docs
    Sparse priors (α < 1, η < 1) are critical: defaults of 1.0 make every
    topic about everything.
    """
    return LatentDirichletAllocation(
        n_components=n_topics,
        doc_topic_prior=0.1,
        topic_word_prior=0.01,
        max_iter=max_iter,
        learning_method="batch",
        random_state=seed,
        n_jobs=-1,
    ).fit(X)

lda = fit_lda(X, n_topics=50)
```

**Correct (Step 3 — extract top words per topic and top topics per file):**

```python
import numpy as np

def print_top_words(lda_model, feature_names, n_top=10):
    for topic_idx, topic in enumerate(lda_model.components_):
        top_indices = topic.argsort()[: -n_top - 1 : -1]
        top_words = [feature_names[i] for i in top_indices]
        print(f"Topic {topic_idx:3d}: {' | '.join(top_words)}")

# After preprocessing, real software topics look like:
#   Topic 13: charg | invoic | refund | stripe | payment | method | pay | bill
#                  (the payments domain — clearly recognizable)
#   Topic 27: index | search | query | aggreg | filter | sort | facet | retriev
#                  (search/indexing domain)
#   Topic 41: log | metric | trace | span | observ | telemetri | gauge | counter

def top_topics_per_file(lda_model, X, files, top_k=3):
    """For each file: the top-k topics with their probability."""
    doc_topics = lda_model.transform(X)  # F × K
    return {
        files[i]: sorted(enumerate(doc_topics[i]), key=lambda x: -x[1])[:top_k]
        for i in range(len(files))
    }
```

**Why LDA works for source code despite being designed for prose:**

The Dirichlet-multinomial setup makes no assumption that the documents are English — only that documents have bags of *tokens* drawn from a small number of latent topics. Software documents have *more* concentrated topic structure than typical news articles (a file about payments uses payment terminology, not random vocabulary), which is actually beneficial: LDA converges faster and topics are more interpretable. The main caveat is the *vocabulary preparation*: garbage in, garbage topics.

**Empirical baseline:** Linstead et al. (ICSM 2007) reported topic-domain alignment accuracy of 65–85% on five Java systems compared with expert-labelled domain concepts. Lukins et al. (TSE 2010, "Bug localization using latent Dirichlet allocation") used LDA topic distributions to *locate bug-fix files* with 60–75% top-10 accuracy on Eclipse and Mozilla — directly useful for "which files implement feature X?" queries.

**When NOT to use:**

- Very small codebase (< ~50 files) — not enough corpus for sparse priors to do their job.
- Polyglot mono-repo — fit one LDA per language; mixing produces topics dominated by language-specific stop-words you didn't filter.
- You want a *deterministic* result — LDA's Gibbs sampler / variational inference can produce different topics across runs even with the same seed in some libraries. Use NMF (`topic-nmf-non-negative-factorization`) if reproducibility matters more than probabilistic interpretation.

**Production:** scikit-learn `LatentDirichletAllocation` is the easy default; `gensim.models.LdaMulticore` is faster for large corpora; `Mallet` (CLI) has the gold-standard Gibbs sampler with hyperparameter optimization. Apache Spark has distributed LDA for very large corpora.

Reference: [Latent Dirichlet Allocation (Blei, Ng, Jordan, JMLR 2003)](https://www.jmlr.org/papers/v3/blei03a.html)
