---
title: Build A Bipartite File × Term Graph When Identifiers Carry The Signal
impact: HIGH
impactDescription: 10-20 MoJoFM points on heavily-DI codebases where static call-graph misses 30-60% of edges
tags: graph, bipartite, file-term, lsi, lexical
---

## Build A Bipartite File × Term Graph When Identifiers Carry The Signal

A call graph misses every edge that goes through a DI container, every dynamic dispatch through an interface, every event-bus subscription, every YAML-wired handler. In a heavily DI-ed Java or TypeScript codebase, the *static* call graph can show 30–60% of the runtime edges (Bavota et al., ICPC 2013). The signal you're losing — *what concept does this file belong to?* — is sitting in the identifiers and comments. A **bipartite graph with files on one side and identifier terms on the other** (after lexical preprocessing, see the `lex-` rules) captures it directly, and can be clustered with co-clustering / bi-clustering algorithms designed exactly for this shape.

Bipartite-aware methods are the right tool: regular Louvain on a projection loses information. Use **Stochastic Block Models for bipartite graphs** (Peixoto's `graph-tool`), **bipartite spectral co-clustering** (Dhillon, KDD 2001), or **Latent Semantic Indexing** (Deerwester 1990, applied to software by Maletic-Marcus, ICSE 2001) — all of which produce *paired* clusters: which files belong together AND which terms describe them.

**Incorrect (call graph only — missing the lexical signal entirely):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = build_call_graph("./src")
comms = nxc.louvain_communities(G.to_undirected())

# Files that share a domain ("payments", "billing", "invoicing") but never
# directly call each other — because they all go through a shared event bus —
# end up in different clusters. The agent reports them as unrelated.
```

**Correct (bipartite file × term graph with TF-IDF weighting):**

```python
import re
import math
from collections import defaultdict
import networkx as nx

CAMEL = re.compile(r"(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|_")
STOPWORDS = {"get", "set", "is", "to", "from", "do", "make", "the", "and",
             "value", "data", "result", "item", "list", "map", "obj", "tmp"}

def tokenize_identifiers(source: str) -> list[str]:
    """camelCase + snake_case split, lowercase, drop stop-words and 1-char tokens.
    See lex-split-identifiers-with-samurai for the harder cases."""
    tokens = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", source)
    out = []
    for tok in tokens:
        for piece in CAMEL.split(tok):
            piece = piece.lower()
            if len(piece) > 1 and piece not in STOPWORDS:
                out.append(piece)
    return out

def build_bipartite(repo: str) -> nx.Graph:
    """
    G = (Files ∪ Terms, Edges) with TF-IDF edge weights.
    Files are bipartite=0, terms are bipartite=1.
    """
    tf = defaultdict(lambda: defaultdict(int))  # tf[file][term]
    df = defaultdict(int)                        # df[term]

    for f in iter_source_files(repo):
        terms_in_file = set()
        for term in tokenize_identifiers(open(f).read()):
            tf[f][term] += 1
            terms_in_file.add(term)
        for term in terms_in_file:
            df[term] += 1

    N = len(tf)
    G = nx.Graph()
    for f in tf:
        G.add_node(f, bipartite=0)
        for term, count in tf[f].items():
            idf = math.log(N / (1 + df[term]))
            if idf < 0.5:        # near-universal terms ("user", "get") drop out
                continue
            G.add_node(term, bipartite=1)
            G.add_edge(f, term, weight=count * idf)
    return G
```

**Correct (Step 2 — bipartite spectral co-clustering, Dhillon KDD 2001):**

```python
from sklearn.cluster.bicluster import SpectralCoclustering
from scipy.sparse import lil_matrix

def bipartite_coclustering(G: nx.Graph, k: int = 8):
    """
    Builds the file × term weight matrix and finds k joint clusters of
    (files that use these terms) × (terms used by these files).
    The SVD-based algorithm runs in O((F+T)² · k) — feasible up to ~10⁴ files.
    """
    files = [n for n, d in G.nodes(data=True) if d["bipartite"] == 0]
    terms = [n for n, d in G.nodes(data=True) if d["bipartite"] == 1]
    f_idx = {f: i for i, f in enumerate(files)}
    t_idx = {t: i for i, t in enumerate(terms)}

    M = lil_matrix((len(files), len(terms)))
    for u, v, d in G.edges(data=True):
        if u in f_idx and v in t_idx:
            M[f_idx[u], t_idx[v]] = d["weight"]
        elif v in f_idx and u in t_idx:
            M[f_idx[v], t_idx[u]] = d["weight"]

    model = SpectralCoclustering(n_clusters=k, random_state=42)
    model.fit(M.tocsr())

    # Each cluster i gets a set of files AND a set of terms.
    clusters = []
    for i in range(k):
        cluster_files = [files[j] for j in range(len(files)) if model.row_labels_[j] == i]
        cluster_terms = [terms[j] for j in range(len(terms)) if model.column_labels_[j] == i]
        clusters.append({"files": cluster_files, "label_terms": cluster_terms})
    return clusters
```

**Alternative (Stochastic Block Model for bipartite — principled and learns k):**

```python
# graph-tool's bipartite SBM (Peixoto) infers BOTH the number of blocks AND
# the block structure under a Bayesian prior. No k to pick; runs in
# O(V · ln² V) for the hierarchical variant.
#
# import graph_tool.all as gt
# g = gt.Graph(directed=False)
# # ... populate g from G ...
# state = gt.minimize_blockmodel_dl(g, deg_corr=True, layers=False)
# blocks = state.get_blocks()
```

**Why this is the right shape:**

The structural call graph and the lexical bipartite graph encode *different* equivalence relations. Co-clustering forces them to agree, and the disagreement reveals interesting cases: files that talk about the same things but don't call each other (cross-cutting concerns: logging, auth, validation) and files that call each other but don't share vocabulary (data-mapping layers — they translate between domains).

**Empirical baseline:** Corazza et al. (ICSM 2010, "LDA-based topic model for software architecture recovery") report bipartite/lexical methods produce decompositions ~10–20 MoJoFM points better than structural-only on Java systems where DI is heavy; for codebases with little DI (C, Go, low-level Rust) the structural graph wins.

**When NOT to use:**

- Identifier vocabulary is poor — generated code, minified, or non-English-named projects. Pre-check Type-Token Ratio (TTR) < 0.05 ⇒ skip lexical methods.
- Tiny codebase (< 50 files) — the term vocabulary doesn't have enough degrees of freedom for SVD.
- Polyglot codebase without a shared vocabulary — cluster within each language first.

**Production:** Apache OpenNLP's source-code-analysis tooling builds bipartite term-document matrices for cross-repo recommendation; GitHub's "see related files" feature uses TF-IDF + bipartite projection at lower-than-Sourcegraph fidelity but the same shape.

Reference: [Co-clustering documents and words using bipartite spectral graph partitioning (Dhillon, KDD 2001)](https://dl.acm.org/doi/10.1145/502512.502550)
