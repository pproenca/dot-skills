---
title: Use Normalized Compression Distance For Feature-Free Similarity
impact: MEDIUM-HIGH
impactDescription: eliminates feature engineering; approximates Kolmogorov-complexity similarity in O(n) via gzip
tags: info, ncd, cilibrasi, vitanyi, kolmogorov, compression
---

## Use Normalized Compression Distance For Feature-Free Similarity

**Normalized Compression Distance** (NCD; **Cilibrasi & Vitanyi, "Clustering by Compression," IEEE TIT 2005**) is one of the most elegant algorithms in clustering: it approximates **Kolmogorov complexity-based similarity** between two files via off-the-shelf compression. The formula is startlingly simple:

`NCD(x, y) = (C(xy) − min(C(x), C(y))) / max(C(x), C(y))`

where `C(·)` is the compressed length of a string (gzip, bzip2, zstd, xz — any will do). The intuition: if files x and y are similar, compressing them together produces a much smaller output than the sum of their individual compressions (the compressor exploits shared substrings). If they're unrelated, joint compression equals the sum. NCD is bounded in [0, 1+]: ~0 = identical; ~1 = unrelated.

NCD requires **no feature engineering** — no tokenization, no preprocessing, no vocabulary. It works on raw bytes. This makes it uniquely valuable for: (1) cross-language comparison (Python file vs Go file representing the same concept), (2) similarity in **non-textual code** (protobuf, AVRO, generated code, binary blobs), (3) baseline comparison when you don't trust your feature engineering. The downside: it's an order of magnitude slower than feature-based methods and the absolute distances aren't interpretable in semantic terms.

**Incorrect (designing custom features when NCD would work out of the box):**

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# You spent a week engineering identifier splitting, stop words, etc.
# For some questions, this is overkill — NCD would have given you 80% of
# the answer with zero feature engineering.
files_text = [open(f).read() for f in iter_source_files(repo)]
X = TfidfVectorizer().fit_transform(files_text)
sim = cosine_similarity(X)
```

**Correct (Step 1 — implement NCD with gzip):**

```python
import gzip

def C(data: bytes) -> int:
    """Compressed length using gzip. zstd/bzip2 also work; results barely differ.
    Use compresslevel=9 for tightest compression, =6 for speed."""
    return len(gzip.compress(data, compresslevel=9))

def ncd(x: bytes, y: bytes) -> float:
    """Normalized Compression Distance.
    Returns ≈ 0 for identical, ≈ 1 for unrelated, > 1 occasionally for very
    different sizes (just clip)."""
    c_x = C(x)
    c_y = C(y)
    # Concatenate. Add a separator that's unlikely to appear naturally to
    # avoid spurious cross-file pattern matches.
    c_xy = C(x + b"\xff\x00\xff\x00" + y)
    return (c_xy - min(c_x, c_y)) / max(c_x, c_y)

# Single-pair example:
file_a = open("src/payments/charge.py", "rb").read()
file_b = open("src/payments/refund.py",  "rb").read()
file_c = open("src/search/index.py",     "rb").read()
print(f"charge vs refund:  NCD = {ncd(file_a, file_b):.3f}")  # ≈ 0.55
print(f"charge vs index:   NCD = {ncd(file_a, file_c):.3f}")  # ≈ 0.85
```

**Correct (Step 2 — build the full pairwise NCD matrix):**

```python
import numpy as np

def ncd_matrix(file_contents: list[bytes]) -> np.ndarray:
    """O(n²) pairwise NCD. Each cell costs ~3 gzip calls; with 1KB-100KB
    files, that's ~10-200 µs per pair. n=1000 → ~10-200 seconds total.
    For n>1000, parallelize or use LSH on compressed signatures."""
    n = len(file_contents)
    M = np.zeros((n, n))
    # Pre-compute individual compressed lengths
    c = [C(x) for x in file_contents]
    for i in range(n):
        for j in range(i + 1, n):
            c_ij = C(file_contents[i] + b"\xff\x00\xff\x00" + file_contents[j])
            d = (c_ij - min(c[i], c[j])) / max(c[i], c[j])
            M[i, j] = M[j, i] = d
    return M

contents = [open(f, "rb").read() for f in files]
D = ncd_matrix(contents)
```

**Correct (Step 3 — cluster on the NCD distance matrix):**

```python
from sklearn.cluster import AgglomerativeClustering

# AgglomerativeClustering with a precomputed metric is the canonical choice
# — NCD is a distance, so 'average' or 'ward' linkage both work.
agg = AgglomerativeClustering(
    n_clusters=15,            # or set distance_threshold and let it pick
    metric="precomputed",
    linkage="average",
)
labels = agg.fit_predict(D)

# Alternatives:
#   - HDBSCAN on NCD: hdbscan.HDBSCAN(metric="precomputed").fit_predict(D)
#   - MDS / t-SNE on D for visualisation: sklearn.manifold.MDS(n_components=2,
#     dissimilarity="precomputed").fit_transform(D)
```

**The Kolmogorov-complexity argument (one paragraph):**

Kolmogorov complexity K(x) is the length of the shortest program that produces x. The conditional complexity K(x | y) is the length of the shortest program that produces x given y. **Universal similarity** is defined as `max(K(x|y), K(y|x)) / max(K(x), K(y))` — if y "explains" most of x's information, they're similar. K(·) is uncomputable, but it can be **approximated** from above by any real-world compressor: C(x) ≥ K(x) within a constant. The NCD formula above is the practical approximation; Li-Vitanyi proved it converges to the true universal similarity as the compressor improves.

**Why this matters: NCD is a *universal* distance metric:**

It works on text, source code, audio, DNA sequences, binary files — anywhere a string-compressor works. The same NCD code that clusters source files also clusters Bach fugues (Cilibrasi-Vitanyi did this), DNA sequences (Li et al. PNAS 2001), and SARS-CoV-2 genomes (Lu et al. 2020). For software analysis, the universality means you can compare *across types of artefacts*: source files, build configs, schema files, generated code — all with the same metric.

**Empirical baseline:** Cilibrasi-Vitanyi (2005) classified 36 mammal mitochondrial DNA sequences with 100% accuracy versus the gold-standard phylogenetic tree. On source code: Cohen-Sayer et al. (2010) compared NCD with TF-IDF on a JavaScript repository, NCD matched TF-IDF on classification accuracy while requiring zero feature engineering. Specifically for cross-language similarity, NCD is the only viable feature-free method.

**When NOT to use:**

- Very large files (> 1 MB each) — gzip is O(n) but the n² file pairs become expensive. Pre-filter or use signature-based variants (Cebrián et al. "The normalized compression distance is resistant to noise," IEEE TIT 2007).
- Files with widely different sizes — NCD penalises size differences. Truncate or pad to similar length first.
- You need an *interpretable* distance — NCD = 0.6 doesn't translate to anything semantic. Use only when you don't need to *explain* the distance.

**Production:** The `python-complearn` library implements NCD with multiple compressors. CompLearn (C++) is the canonical Vitanyi-lab tool. Bioinformatics uses NCD extensively (`alfpy` for sequence comparison). Modern variant: **gzip-based text classification** (Jiang et al., ACL 2023, "Less is More: Parameter-Free Text Classification with Gzip") showed NCD-based kNN beats BERT on several benchmark tasks — a stunning revival of the technique.

Reference: [Clustering by Compression (Cilibrasi & Vitanyi, IEEE Transactions on Information Theory 2005)](https://ieeexplore.ieee.org/document/1412045)
