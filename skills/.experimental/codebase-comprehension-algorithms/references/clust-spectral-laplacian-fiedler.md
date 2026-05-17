---
title: Use Spectral Clustering When Cuts And Algebraic Connectivity Matter
impact: MEDIUM
impactDescription: computes optimal k-way normalized cut in O(N²) eigendecomp; reveals algebraic connectivity λ₂
tags: clust, spectral, laplacian, fiedler, ng-jordan-weiss, normalized-cut
---

## Use Spectral Clustering When Cuts And Algebraic Connectivity Matter

**Spectral clustering** is fundamentally different from modularity, MDL, or flow-based methods: it treats clustering as a **graph-cut problem**. The graph Laplacian L = D − A (where D is the degree matrix, A the adjacency) has a deep property: its **second-smallest eigenvalue λ₂** (the Fiedler value, also called *algebraic connectivity*) measures how well-connected the graph is, and the **corresponding eigenvector** (the Fiedler vector) gives the optimal **2-way normalized cut**. Extend to k eigenvectors and you get the optimal k-way cut (Shi-Malik 2000; Ng-Jordan-Weiss, NIPS 2001).

For software analysis, spectral clustering shines in three cases: (1) when you want the *minimum-disruption* decomposition (where can you cut the codebase with the fewest cross-cluster dependencies?), (2) when you want to *measure* how cleanly decomposable the codebase is (λ₂ is a quantitative answer), and (3) when you want to visualise the codebase by embedding nodes into low-dimensional space via the top-k eigenvectors (the spectral embedding is what t-SNE / UMAP would call the "good" projection of the graph).

**Incorrect (Louvain when you actually want to *cut* the graph):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = build_import_graph("./src")
# You want to know "where would I split this codebase into two services?"
# Louvain answers a different question — modularity maximization — and might
# produce 7 clusters, none of which is a clean 2-way split.
communities = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — compute the Fiedler vector for the optimal 2-way cut):**

```python
import numpy as np
import scipy.sparse.linalg as sla
import networkx as nx

def fiedler_split(G):
    """
    Returns: (left_nodes, right_nodes, λ₂)
    The Fiedler vector's sign gives the optimal 2-way normalized cut.
    λ₂ near 0 → the graph is barely connected (easy split).
    λ₂ large → the graph is robustly connected (no clean split).
    """
    nodes = list(G.nodes())
    L = nx.normalized_laplacian_matrix(G, nodelist=nodes).asfptype()
    # Compute the 2 smallest eigenvalues. The smallest is always 0 (constant vector).
    eigvals, eigvecs = sla.eigsh(L, k=2, which="SM")
    fiedler_value = eigvals[1]
    fiedler_vector = eigvecs[:, 1]
    left = [n for n, v in zip(nodes, fiedler_vector) if v < 0]
    right = [n for n, v in zip(nodes, fiedler_vector) if v >= 0]
    return left, right, fiedler_value

left, right, lam2 = fiedler_split(G.to_undirected())
print(f"Algebraic connectivity λ₂ = {lam2:.4f}")
print(f"Optimal 2-cut: {len(left)} vs {len(right)} nodes")
# λ₂ < 0.05 → the codebase is two loosely coupled halves — strong candidate
#             for a service split along the Fiedler cut.
# λ₂ > 0.5 → the codebase is tightly woven. Any cut creates many cross-edges.
```

**Correct (Step 2 — k-way spectral clustering via Ng-Jordan-Weiss):**

```python
import numpy as np
import scipy.sparse.linalg as sla
from sklearn.cluster import KMeans

def spectral_kway(G, k: int):
    """
    Ng-Jordan-Weiss 2001:
    1) Compute the k smallest eigenvectors of the normalized Laplacian.
    2) Stack as columns → n×k matrix.
    3) Normalize each row to unit length.
    4) k-means on the rows.
    """
    nodes = list(G.nodes())
    L = nx.normalized_laplacian_matrix(G, nodelist=nodes).asfptype()
    eigvals, eigvecs = sla.eigsh(L, k=k, which="SM")
    embed = eigvecs / np.linalg.norm(eigvecs, axis=1, keepdims=True).clip(min=1e-10)
    labels = KMeans(n_clusters=k, n_init=10, random_state=42).fit_predict(embed)
    return {n: int(c) for n, c in zip(nodes, labels)}

assignment = spectral_kway(G.to_undirected(), k=8)
```

**Correct (Step 3 — pick k from the eigenvalue gap):**

```python
def estimate_k_from_eigengap(G, k_max: int = 20):
    """
    The "eigengap heuristic" (Ng-Jordan-Weiss 2001 §4): k* is where the gap
    between consecutive eigenvalues of the Laplacian is largest. Eigenvalues
    1..k* are small (intra-cluster), eigenvalues > k* are large (inter-cluster).
    """
    L = nx.normalized_laplacian_matrix(G).asfptype()
    eigvals, _ = sla.eigsh(L, k=k_max + 1, which="SM")
    eigvals = sorted(eigvals)
    gaps = [(i + 1, eigvals[i + 1] - eigvals[i]) for i in range(k_max)]
    return max(gaps, key=lambda x: x[1])[0]

k_star = estimate_k_from_eigengap(G.to_undirected())
print(f"Eigengap suggests k = {k_star}")
# Often k* matches what an expert would have picked. When it doesn't, the
# graph has unclear cluster boundaries.
```

**Why this is theoretically grounded:**

Normalized cut (Shi-Malik) is NP-hard in general. The spectral relaxation — minimising xᵀLx subject to ||x||=1, x ⊥ 1 — has a closed-form solution: the Fiedler vector. The thresholded vector gives the cut. NJW extends this to k clusters via the top-k Laplacian eigenvectors and k-means. The whole thing reduces to **eigendecomposition + k-means**, both well-understood, both fast. λ₂ is the **algebraic connectivity** (Fiedler 1973) — a single scalar that measures how cuttable the graph is.

**Empirical baseline:** Shi-Malik (PAMI 2000) showed spectral clustering beats heuristic graph partitioning (METIS) on image segmentation; transfers to software analysis where Andritsos-Tzerpos (ICSE 2005) compared spectral to Bunch on TOBEY and Mozilla — spectral matches Bunch on MoJoFM but provides interpretable λ₂ that Bunch's MQ score doesn't.

**When NOT to use:**

- Very large graphs (n > 10⁴) — eigendecomposition is O(n²) memory; use Lanczos / power iteration for sparse cases.
- Sparse, almost-disconnected graphs — multiple eigenvalues at 0 means multiple connected components; cluster each independently first.
- Graphs where weighted-cut isn't the right cost (e.g. flow-meaningful directed graphs — use Infomap).

**Production:** scikit-learn's `SpectralClustering`; ARPACK / SciPy's `eigsh`; the workhorse of image segmentation, document clustering, and bioinformatics. The Fiedler vector and λ₂ also appear in network robustness analysis (a low-λ₂ network is fragile) — see Albert-Barabási reviews.

Reference: [Normalized Cuts and Image Segmentation (Shi & Malik, IEEE PAMI 2000)](https://people.eecs.berkeley.edu/~malik/papers/SM-ncut.pdf)
