---
title: Filter Omnipresent Utilities Before Clustering
impact: CRITICAL
impactDescription: removes ~5–15% of files that absorb 50%+ of edges and dominate every cluster
tags: graph, preprocessing, omnipresent, tzerpos, noise-filtering
---

## Filter Omnipresent Utilities Before Clustering

Every non-trivial codebase has files that *everyone* imports — `logger`, `errors`, `constants`, `utils/string`, `db/connection`, `i18n`, base classes, type-stubs. **Tzerpos & Holt (ACDC, WCRE 2000) called these "omnipresent" files** and showed they are the single largest source of clustering noise: they pull every cluster toward themselves, merge unrelated domains via shared imports, and inflate modularity scores while destroying semantic meaning. On a 5,000-file codebase, the top 50–100 most-imported modules typically account for **50–80% of total edges** in the import graph; leave them in and your "communities" are mostly "things that use the logger."

The cure is mechanical: before running any clustering algorithm, identify omnipresent files and either remove them entirely or attach them to every cluster post-hoc. Use a fan-in threshold (e.g. files in the top 1–2% by fan-in), a percentage-of-modules threshold (imported by > N% of files), or — best — a TF-IDF-style inverse-document-frequency cutoff that lets the data choose.

**Incorrect (running Louvain on the raw import graph — every cluster contains the logger):**

```python
import networkx as nx
import networkx.algorithms.community as nxc

G = nx.DiGraph()
for src, dst in iter_imports("./src"):
    G.add_edge(src, dst)

# Louvain on the raw graph. The 50 most-imported files have fan-in > 500 each
# in a 3,000-file codebase. They act as super-attractors: every community
# centres on a utility, and "real" domains (payments, search, billing) fragment.
communities = nxc.louvain_communities(G.to_undirected())
```

**Correct (drop omnipresent files via fan-in z-score before clustering):**

```python
import math
import networkx as nx
import networkx.algorithms.community as nxc

def filter_omnipresent(G: nx.DiGraph, z_threshold: float = 2.5) -> nx.DiGraph:
    """
    Tzerpos-style omnipresent filter: drop files whose fan-in is z_threshold
    standard deviations above the mean (log-transformed, since fan-in is
    long-tailed). 2.5 σ on a log scale matches the empirical 1–2% top tail
    that ACDC reports for production codebases.
    """
    fan_in = {n: G.in_degree(n) for n in G.nodes if G.in_degree(n) > 0}
    log_fi = [math.log1p(v) for v in fan_in.values()]
    mu = sum(log_fi) / len(log_fi)
    var = sum((x - mu) ** 2 for x in log_fi) / len(log_fi)
    sigma = math.sqrt(var)
    cutoff = math.exp(mu + z_threshold * sigma) - 1

    omnipresent = {n for n, fi in fan_in.items() if fi >= cutoff}
    H = G.copy()
    H.remove_nodes_from(omnipresent)
    return H, omnipresent

G_pruned, dropped = filter_omnipresent(G)
print(f"dropped {len(dropped)} omnipresent nodes:", sorted(dropped)[:10])
communities = nxc.louvain_communities(G_pruned.to_undirected())

# Post-hoc: re-attach each omnipresent file to every cluster (it really does
# belong everywhere) or to its own "utilities" cluster — ACDC's convention.
```

**Alternative (data-driven cutoff via IDF — no hand-picked threshold):**

```python
# Treat each importing module as a "document". Inverse Document Frequency
# discounts widely-imported files automatically — same idea as TF-IDF for words.
# Files imported by > 50% of modules end up with IDF < 1.0 and drop out
# naturally once you weight edges by IDF (see graph-weight-edges-by-information-content).

N = G.number_of_nodes()
idf = {n: math.log(N / (1 + G.in_degree(n))) for n in G.nodes}
KEEP_THRESHOLD = math.log(20)  # files imported by ≤ N/20 modules
keep = {n for n, v in idf.items() if v >= KEEP_THRESHOLD}
H = G.subgraph(keep).copy()
```

**Why this matters more than the algorithm choice:**

ACDC (Tzerpos & Holt, WCRE 2000) and Bunch (Mancoridis et al., ICSM 1999) both report that omnipresent filtering changes MoJoFM (cluster similarity to ground truth) by **20–40 points out of 100** — a larger swing than the choice between Louvain, Leiden, and Infomap on the same input. Mitchell & Mancoridis (TSE 2006) reproduce this on the SwingBunch corpus. If you do nothing else from this skill, do this.

**When NOT to filter:**

- You're recovering *layer* structure (kernel → util → app) — omnipresent files ARE the lower layers and you need them in.
- You're explicitly hunting for cross-cutting concerns (logging, auth, i18n) — those *are* the omnipresent files. Use FCA (Snelting-Tip, FSE 1998) instead of community detection.
- The codebase is small enough (< 200 files) that the top-1% tail is 0–2 files.

**Production:** ACDC ships with a configurable omnipresent threshold; SonarQube's Architecture view applies a similar fan-in cutoff before drawing dependency cycles; Sourcegraph's code-intel skips well-known stdlib modules entirely when building cross-repo graphs.

Reference: [ACDC: An Algorithm for Comprehension-Driven Clustering (Tzerpos & Holt, WCRE 2000)](https://www.cs.yorku.ca/~bil/papers/wcre00.pdf)
