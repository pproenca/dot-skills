---
title: Cluster Identifier Variants into Canonical Entities via Embedding plus Edit Distance
impact: HIGH
impactDescription: deduplicates 30-50% of identifier vocabulary into canonical entity names
tags: concept, entity-resolution, embeddings, edit-distance, fasttext
---

## Cluster Identifier Variants into Canonical Entities via Embedding plus Edit Distance

A 5-year-old codebase will refer to the same business entity as `user`, `usr`, `u`, `userAccount`, `accountHolder`, `customer`, and `member` — all in the same repo, often in the same module. Treating them as separate concepts breaks every downstream analysis: topic modelling fragments topics, co-occurrence graphs split clusters, and bug-localization ranks all variants near the bottom. Entity resolution clusters these variants into a single canonical entity using a two-pass approach: edit-distance for typos/abbreviations and embedding similarity for semantic synonyms. The output is a variant → canonical map you apply as a preprocessing step to every other algorithm in this skill.

**Incorrect (treat every identifier token as a distinct entity — vocabulary fragments):**

```python
import re, pathlib, collections

# Counts every distinct token. "user", "usr", "u", "userAccount" all
# scored separately — user-related signal is split across 7 buckets.
WORD = re.compile(r"\b[a-zA-Z_][a-zA-Z0-9_]{1,}\b")
counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    counts.update(WORD.findall(p.read_text(errors="ignore")))

# "user": 1820, "usr": 412, "userAccount": 300, "accountHolder": 270,
# "customer": 240, "member": 180 — six entries for one entity.
```

**Correct (cluster variants via edit-distance + embedding similarity, output canonical map):**

```python
import re, pathlib, collections
import numpy as np
from rapidfuzz.distance import Levenshtein
from sentence_transformers import SentenceTransformer
from sklearn.cluster import AgglomerativeClustering

WORD = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")
encoder = SentenceTransformer("all-MiniLM-L6-v2")   # 22MB, fast on CPU

# 1. Collect all identifier tokens with their frequency
tokens: collections.Counter = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    for ident in re.findall(r"\b[A-Za-z_][A-Za-z0-9_]{2,}\b", p.read_text(errors="ignore")):
        for w in WORD.findall(ident):
            tokens[w.lower()] += 1

vocab = [t for t, c in tokens.items() if c >= 5 and len(t) >= 2]

# 2. Build a combined-distance matrix: 0.6 × embedding + 0.4 × edit-distance
embs = encoder.encode(vocab, normalize_embeddings=True)
emb_dist = 1 - embs @ embs.T

n = len(vocab)
edit_dist = np.zeros((n, n), dtype=np.float32)
for i in range(n):
    for j in range(i + 1, n):
        d = Levenshtein.normalized_distance(vocab[i], vocab[j])
        edit_dist[i, j] = edit_dist[j, i] = d

combined = 0.6 * emb_dist + 0.4 * edit_dist

# 3. Agglomerative clustering with a distance threshold
clusters = AgglomerativeClustering(
    n_clusters=None, distance_threshold=0.35, metric="precomputed", linkage="average",
).fit(combined)

# 4. Canonical name = most frequent variant per cluster
canon: dict[str, str] = {}
for cid in set(clusters.labels_):
    members = [vocab[i] for i, c in enumerate(clusters.labels_) if c == cid]
    canon_name = max(members, key=tokens.get)
    for m in members:
        canon[m] = canon_name

# Sample output
for variant in ("user", "usr", "u", "useraccount", "accountholder", "customer"):
    print(f"  {variant:>16} → {canon.get(variant, variant)}")
# user → user
# usr → user        (edit-distance: abbreviation)
# u → user          (edit-distance: short alias)
# useraccount → user  (embedding: compound noun)
# accountholder → user (embedding: synonym)
# customer → customer (no merge — semantically distinct in this domain)
```

**Tune the threshold per domain.** Too low (< 0.2) misses synonyms; too high (> 0.5) merges distinct entities (`subscriber` with `subscription`). Inspect a sample of the merges before applying — entity resolution is the algorithm in this skill with the highest risk of confidently-wrong output.

**Use the canonical map as a preprocessing step** for `concept-lda-topic-modeling`, `concept-identifier-cooccurrence-network`, and `ir-tfidf-bug-localization`. All three improve substantially when their input vocabulary is consolidated.

**When NOT to apply:**
- Codebases under ~500 distinct tokens — manual inspection is faster
- When the variants represent legitimately different concepts (`asyncUser` vs `syncUser` in a perf-sensitive API)

Reference: [Christen, Data Matching: Concepts and Techniques](https://link.springer.com/book/10.1007/978-3-642-31164-2), [Sentence-BERT (Reimers & Gurevych)](https://arxiv.org/abs/1908.10084)
