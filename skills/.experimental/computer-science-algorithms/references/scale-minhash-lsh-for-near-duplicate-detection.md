---
title: Use MinHash + LSH For Near-Duplicate Detection At Billion-Doc Scale
impact: MEDIUM-HIGH
impactDescription: O(n²) pairwise Jaccard to O(n) — find similar pairs in 10⁹ documents
tags: scale, minhash, lsh, similarity, deduplication
---

## Use MinHash + LSH For Near-Duplicate Detection At Billion-Doc Scale

"Find all pairs of documents with Jaccard similarity > 0.8" by computing pairwise Jaccard is O(n²) — at n = 10⁶, that's 10¹² comparisons. **MinHash** (Broder, 1997) compresses each document's shingle set to a fixed-size signature (typically 128 ints, ~512 bytes) such that the **fraction of matching positions ≈ Jaccard similarity** of the original sets. **Locality-Sensitive Hashing (LSH)** then buckets signatures so similar documents collide in the same bucket — turning "find all pairs above threshold" from O(n²) into ~O(n) by only comparing items that share a bucket.

This is how Google does near-duplicate web page detection, how DataSketches / Apache Hudi deduplicate, how academic plagiarism detection scales, how recommendation systems find similar items, how dataset cleaning pipelines remove near-duplicates before training LLMs.

**Incorrect (pairwise Jaccard — O(n²) sets, dominated by comparison cost):**

```python
def near_duplicates_naive(docs, threshold: float = 0.8):
    # n² Jaccard comparisons. n = 10⁵ → 10¹⁰ ops → hours.
    shingles = [set(_shingles(d)) for d in docs]
    pairs = []
    for i in range(len(docs)):
        for j in range(i + 1, len(docs)):
            inter = len(shingles[i] & shingles[j])
            union = len(shingles[i] | shingles[j])
            if union and inter / union >= threshold:
                pairs.append((i, j))
    return pairs

def _shingles(text: str, k: int = 5):
    return (text[i:i+k] for i in range(len(text) - k + 1))
```

**Correct (Step 1: the MinHash signature):**

```python
import mmh3

class MinHash:
    def __init__(self, num_perm: int = 128):
        # Each "permutation" is a different hash seed.
        # Standard error of Jaccard estimate ≈ 1 / sqrt(num_perm).
        # 128 perms → ~9% error; 256 → ~6%.
        self.num_perm = num_perm
        self.hashes = [(1 << 64) - 1] * num_perm

    def update(self, item: str) -> None:
        for i in range(self.num_perm):
            h = mmh3.hash64(item, seed=i, signed=False)[0]
            if h < self.hashes[i]:
                self.hashes[i] = h

    def jaccard(self, other: "MinHash") -> float:
        # Estimated Jaccard = fraction of matching positions.
        return sum(a == b for a, b in zip(self.hashes, other.hashes)) / self.num_perm
```

**Alternative (Step 2: the LSH index):**

```python
from collections import defaultdict

class MinHashLSH:
    def __init__(self, threshold: float = 0.8, num_perm: int = 128):
        # Bands × rows = num_perm. For threshold ≈ 0.8 and num_perm = 128,
        # bands=32 rows=4 gives P(collision) ≈ 1 - (1 - s^4)^32 — an S-curve
        # whose inflection lands near the threshold.
        self.threshold = threshold
        self.bands = 32
        self.rows = num_perm // self.bands
        self.buckets: list[dict[tuple, list[str]]] = [defaultdict(list) for _ in range(self.bands)]
        self.signatures: dict[str, MinHash] = {}

    def insert(self, doc_id: str, mh: MinHash) -> None:
        self.signatures[doc_id] = mh
        for b in range(self.bands):
            band = tuple(mh.hashes[b * self.rows : (b + 1) * self.rows])
            self.buckets[b][band].append(doc_id)

    def query(self, mh: MinHash) -> list[str]:
        # Candidates: docs sharing at least one band; verify with full Jaccard.
        seen = set()
        for b in range(self.bands):
            band = tuple(mh.hashes[b * self.rows : (b + 1) * self.rows])
            seen.update(self.buckets[b].get(band, []))
        return [d for d in seen if self.signatures[d].jaccard(mh) >= self.threshold]
```

**Alternative (Step 3: near-duplicate detection over a corpus):**

```python
def near_duplicates(docs, threshold: float = 0.8):
    # Build signatures: O(|doc| · num_perm) per doc. Then bucket-query each.
    sigs = []
    for d in docs:
        mh = MinHash()
        for sh in _shingles(d):
            mh.update(sh)
        sigs.append(mh)

    lsh = MinHashLSH(threshold=threshold)
    pairs = []
    for i, mh in enumerate(sigs):
        for matched_id in lsh.query(mh):
            pairs.append((int(matched_id), i))
        lsh.insert(str(i), mh)
    return pairs

def _shingles(text: str, k: int = 5):
    return [text[i:i+k] for i in range(len(text) - k + 1)]
```

**LSH parameter tuning (the "S-curve"):** with b bands × r rows = num_perm signature positions, the probability two docs of similarity s end up in the same bucket is approximately `1 - (1 - s^r)^b`. Pick (b, r) so the S-curve has its inflection point near your threshold:

| Threshold | num_perm | bands | rows |
|-----------|----------|-------|------|
| 0.5 | 128 | 64 | 2 |
| 0.7 | 128 | 32 | 4 |
| 0.8 | 128 | 16 | 8 |
| 0.9 | 128 | 8 | 16 |

Lower threshold → more bands, fewer rows per band → more collisions, more candidates to verify, more recall, less precision.

**Alternatives:**

- **SimHash** (Charikar, used by Google) — for high-dimensional vector similarity (e.g. document embeddings). Sign-bit encoding instead of min-hashing. Better for dense vectors; MinHash is better for sparse sets.
- **HNSW / IVF (FAISS)** — approximate nearest neighbour for dense embeddings; the standard tool for vector search.
- **Simhash + Hamming distance** — works well when documents are bag-of-words; small Hamming distance ⇔ high similarity.

**When NOT to use:**

- Few documents (n ≤ ~10⁴) — pairwise Jaccard is fast enough
- Exact duplicates only — content-hashing (SHA-256) is simpler
- Dense vector similarity (embeddings) — use SimHash or FAISS instead

**Production:** Google near-duplicate web pages (Henzinger et al.), Common Crawl deduplication, GitHub code search near-duplicate filter, large-scale LLM training-data dedup (RedPajama, FineWeb), Apache DataSketches.

Reference: [MinHash and LSH — Mining of Massive Datasets, ch. 3 (Leskovec, Rajaraman, Ullman)](http://www.mmds.org/)
