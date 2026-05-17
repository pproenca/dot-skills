---
title: Use LSI / Truncated SVD When You Need Deterministic Semantic Embeddings
impact: HIGH
impactDescription: 5-10× faster than LDA; produces deterministic embeddings for similarity queries
tags: topic, lsi, lsa, svd, deerwester, maletic-marcus
---

## Use LSI / Truncated SVD When You Need Deterministic Semantic Embeddings

**Latent Semantic Indexing** (Deerwester, Dumais, Furnas, Landauer, Harshman — "Indexing by latent semantic analysis," JASIS 1990) was the first method to project documents into a low-dimensional **semantic space** via truncated singular value decomposition of the term × document matrix. It's older than LDA, deterministic (no Gibbs sampler), and produces dense **document embeddings** you can use with k-means, HDBSCAN, or cosine similarity. **Maletic & Marcus** applied LSI to source code in two seminal papers (ICSM 2001, ICSE 2003), launching the IR-on-source-code subfield. LSI is still the right tool for several cases LDA mishandles.

The non-obvious property: **the LSI embedding captures *synonymy* and *polysemy*** — if `auth` and `authentication` appear in overlapping contexts (after expansion), they end up nearby in the LSI space, while if `transaction` appears in both payment and database contexts it gets two distinct projections you can disambiguate. This is exactly the property you want for codebase comprehension: it makes the *concept-level* signal explicit.

**Incorrect (TF-IDF + cosine similarity — no semantic dimension reduction):**

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

X = TfidfVectorizer().fit_transform(documents)
# X is sparse, ~10⁴ dimensions. Cosine similarity captures literal vocabulary
# overlap. Two files that talk about "payment" and "billing" — synonyms in
# this codebase — get ZERO similarity if they never share a token.
sim = cosine_similarity(X)
```

**Correct (Step 1 — fit truncated SVD on the TF-IDF matrix):**

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD

# Step 1: TF-IDF (see lex-tf-idf-and-bm25-on-identifiers)
vec = TfidfVectorizer(min_df=3, max_df=0.4, sublinear_tf=True, norm="l2")
X = vec.fit_transform(documents)           # F × T sparse

# Step 2: Truncated SVD. k = 100–300 dimensions is standard.
# Below 50 = lossy; above 500 = noise + cost without benefit.
svd = TruncatedSVD(n_components=200, n_iter=10, random_state=42)
lsi_embedding = svd.fit_transform(X)        # F × k dense
print(f"Explained variance: {svd.explained_variance_ratio_.sum():.3f}")
```

**Correct (Step 2 — interpret topic dimensions via word loadings):**

```python
import numpy as np

def lsi_topic_words(svd, feature_names, n_top: int = 8):
    """
    Each LSI dimension is a linear combination of terms. Top positive terms
    give the "topic"; top negative terms give the "anti-topic" (LSI is signed,
    unlike LDA). For software, the bi-polar structure is informative —
    "payment vs search" is a clean signed dimension.
    """
    for i, component in enumerate(svd.components_[:20]):  # show first 20 dims
        top_pos = component.argsort()[-n_top:][::-1]
        top_neg = component.argsort()[:n_top]
        pos_words = [feature_names[j] for j in top_pos]
        neg_words = [feature_names[j] for j in top_neg]
        print(f"Dim {i:>3}  +: {pos_words}")
        print(f"        −: {neg_words}\n")
```

**Correct (Step 3 — use the LSI space for clustering and similarity queries):**

```python
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.cluster import KMeans  # or use HDBSCAN — see clust-hdbscan-density-based

# Cluster directly in LSI space — denser than TF-IDF, faster, more semantic.
km = KMeans(n_clusters=15, n_init=10, random_state=42)
cluster_labels = km.fit_predict(lsi_embedding)

# Pairwise file similarity: O(F²) cosine on the dense embedding. Very fast.
# "Most similar to src/payments/charge.py" becomes a one-liner.
sim_matrix = cosine_similarity(lsi_embedding)

# Find the 10 most-similar files to a target
def top_k_similar(file_idx, sim_matrix, files, k=10):
    sims = sim_matrix[file_idx]
    top = sims.argsort()[::-1][1:k+1]  # exclude self
    return [(files[i], float(sims[i])) for i in top]
```

**Why LSI is still useful in the era of LDA and neural embeddings:**

| Property | LSI | LDA | Neural (CodeBERT) |
|----------|-----|-----|-------------------|
| Deterministic | yes | no (Gibbs sampler) | yes (after training) |
| Fast to fit | fast (SVD) | medium (sampling) | slow (training) |
| Interpretable topic | partial (signed dimensions) | yes (word distributions) | no |
| Embedding for downstream tasks | excellent | OK (topic distributions) | excellent |
| Sensitive to vocabulary choice | yes | yes | mostly tokenizer-driven |
| Works with small corpora | yes | so-so | no (needs pre-training) |

**Use LSI when:** you need deterministic, reproducible embeddings + the ability to query "most similar files" efficiently. **Use LDA when:** you want interpretable, named topics. **Use neural embeddings when:** you have enough compute and a relevant pre-trained model.

**Empirical baseline:** Maletic-Marcus (ICSE 2001) showed LSI matches LDA on concept-location tasks while being 5–10× faster to fit; Marcus, Sergeyev, Rajlich, Maletic (TSE 2004, "An information retrieval approach to concept location in source code") demonstrated LSI-based feature location with ~70% top-10 accuracy on Mozilla. Modern neural embeddings beat LSI by 5–15% on code search, but LSI remains competitive when training data isn't available.

**When NOT to use:**

- You need probabilistic topic assignments per file — LDA is purpose-built for that.
- Very small corpora (< 100 files, < 1000 unique terms after preprocessing) — SVD truncation loses signal.
- You have access to a strong pre-trained code embedding (CodeBERT, GraphCodeBERT, OpenAI text-embedding) — use those instead; LSI is the small-data choice.

**Production:** scikit-learn `TruncatedSVD` is the workhorse. `gensim.models.LsiModel` is a fast alternative with streaming support. Bing's original retrieval ranking and Microsoft Research's Semantic Search both used LSI variants until neural-embedding replacement around 2018.

Reference: [Indexing by Latent Semantic Analysis (Deerwester, Dumais, Furnas, Landauer, Harshman, JASIS 1990)](https://wordvec.colorado.edu/papers/Deerwester_1990.pdf)
