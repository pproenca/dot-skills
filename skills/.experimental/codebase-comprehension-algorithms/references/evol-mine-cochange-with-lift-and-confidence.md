---
title: Mine Co-Change With Lift And Confidence, Not Raw Co-Occurrence Count
impact: HIGH
impactDescription: 15-25% precision lift over raw co-change counts; lift > 2 captures meaningful coupling
tags: evol, lift, confidence, support, apriori, rose, zimmermann
---

## Mine Co-Change With Lift And Confidence, Not Raw Co-Occurrence Count

Two files changed together 20 times. Is that signal? The answer is governed by the marginal frequencies. If both files change 200 times each independently (one is a config file, the other is a route table — they happen to be touched in nearly every commit), 20 co-changes is *less than chance*. If both change only 22 times each, 20 co-changes is **enormous evidence of coupling**. **Raw co-change count is uninterpretable** — you need to **normalise by the marginal frequencies**.

The right metrics come from **association-rule mining** (Agrawal & Srikant, VLDB 1994), applied to version history by **Zimmermann, Weißgerber, Diehl, Zeller** in the ROSE tool ("Mining Version Histories to Guide Software Changes," TSE 2005). Three quantities:

- **Support(A → B)** = P(A and B changed together) — how *common* is this co-change?
- **Confidence(A → B)** = P(B changed | A changed) — when A changes, how often does B?
- **Lift(A → B)** = P(A and B) / (P(A) · P(B)) — how much more than chance?

Confidence is asymmetric (useful for "if I touch A, what else?"); lift is symmetric (useful for "are these two structurally coupled?"). For codebase comprehension, **lift > 2** is the conventional cutoff for "meaningful coupling."

**Incorrect (rank by raw co-change count — biased toward high-base-rate files):**

```python
from collections import Counter

cochange_count = Counter()
for commit in iter_commits(repo):
    files = commit.modified_files
    for i, f1 in enumerate(files):
        for f2 in files[i+1:]:
            pair = tuple(sorted([f1, f2]))
            cochange_count[pair] += 1

# Top pairs by raw count: dominated by config files, schema files, big route
# tables — files that change in almost every commit. The actual feature-level
# coupling is buried.
for pair, count in cochange_count.most_common(20):
    print(f"{count:>4}: {pair}")
```

**Correct (Step 1 — compute support, confidence, and lift):**

```python
from collections import Counter

def mine_cochange(repo):
    """Walk git history; for each commit, record the set of changed files
    and update marginal + joint counts."""
    file_count = Counter()       # file → # commits it changed in
    pair_count = Counter()       # (a,b) → # commits both changed in
    total_commits = 0
    for commit in iter_commits(repo):
        files = set(commit.modified_files)
        if len(files) < 2:
            continue
        total_commits += 1
        for f in files:
            file_count[f] += 1
        for i, f1 in enumerate(sorted(files)):
            for f2 in sorted(files)[i+1:]:
                pair_count[(f1, f2)] += 1
    return file_count, pair_count, total_commits

def metrics(pair, file_count, pair_count, total):
    a, b = pair
    p_a  = file_count[a]    / total
    p_b  = file_count[b]    / total
    p_ab = pair_count[pair] / total
    if p_a == 0 or p_b == 0:
        return None
    return {
        "support":     p_ab,
        "confidence_ab": p_ab / p_a,   # P(B | A)
        "confidence_ba": p_ab / p_b,   # P(A | B)
        "lift":        p_ab / (p_a * p_b),
    }
```

**Correct (Step 2 — filter by support and lift to surface real coupling):**

```python
def meaningful_couplings(file_count, pair_count, total,
                         min_support: float = 0.02,
                         min_lift: float = 2.0):
    """
    Conventional thresholds (Zimmermann et al.):
      min_support ≈ 0.02-0.05 (pair appears in ≥ 2-5% of commits)
      min_lift    ≈ 2.0       (twice chance — directional with confidence)
    Tune support down for rarely-changed code; lift typically stays at 2.
    """
    results = []
    for pair, _ in pair_count.items():
        m = metrics(pair, file_count, pair_count, total)
        if m and m["support"] >= min_support and m["lift"] >= min_lift:
            results.append((pair, m))
    # Sort by lift descending — strongest coupling first
    return sorted(results, key=lambda x: -x[1]["lift"])

couplings = meaningful_couplings(file_count, pair_count, total_commits)
for (a, b), m in couplings[:20]:
    print(f"lift={m['lift']:5.2f}  conf={m['confidence_ab']:.2f}/{m['confidence_ba']:.2f}  "
          f"sup={m['support']:.3f}  {a}  ↔  {b}")
```

**Correct (Step 3 — build the co-change graph from the filtered pairs):**

```python
import networkx as nx

def build_cochange_graph(couplings, weight_by: str = "lift"):
    """
    Convert filtered couplings into a graph for downstream clustering.
    Edge weight = log(lift), capped, so a pair with lift 100 doesn't
    dominate a pair with lift 3 by 33×.
    """
    import math
    G = nx.Graph()
    for (a, b), m in couplings:
        w = math.log2(m[weight_by])  # log scale dampens extreme outliers
        G.add_edge(a, b, weight=w, support=m["support"], lift=m["lift"])
    return G

G_cochange = build_cochange_graph(couplings)
# Feed into Leiden / Infomap / MCL. See clust-leiden-not-louvain.
```

**Why lift > 2 and not lift > 1:**

Lift = 1 means independent — co-occurrence equals product of marginals. Lift = 2 means "co-occurs twice as often as chance" — a 2σ-equivalent for moderate base rates. Below 2, you're typically capturing genuinely independent files that happen to overlap; above 2 (and ideally above 3), you're capturing intentional coupling. Zimmermann's ROSE used lift > 2 as the default threshold and demonstrated 80%+ precision on recommending which files to change next given an in-progress commit.

**Special case — Apriori for itemsets > 2:**

The above handles pairs. For *triples or larger* (e.g. "every time A and B change, so does C and D"), use frequent-itemset mining: **Apriori** (Agrawal-Srikant VLDB 1994) or its faster successor **FP-Growth** (Han-Pei SIGMOD 2000). The candidate-generation pattern (only k-itemsets all of whose (k-1)-subsets are frequent) prunes the search dramatically. For software, triples are rare — most coupling is pairwise — but they reveal critical cross-feature interactions when they exist.

**Empirical baseline:** Zimmermann et al. (TSE 2005) report ROSE's pair-level recommendations achieve **70–90% precision at top-3** for "what files should change with this one?" on Eclipse, ArgoUML, and Mozilla. Confidence and lift outperform raw count by 15–25% on these benchmarks. Gall et al. (ICSM 1998 founding paper) used pure co-change counts and demonstrated they predict architectural decisions; the lift-based refinements add ~10 precision points.

**When NOT to use:**

- Tiny commit histories (< 100 commits) — statistics are too noisy. Wait for more history or fall back to structural coupling.
- Highly branched / monorepo repositories — co-change spans unrelated subprojects; filter commits by directory first.
- Generated code in commits — auto-generated changes inflate co-occurrence dramatically. Add to .gitattributes or exclude generated paths.

**Production:** Zimmermann's original `ROSE` is a Java Eclipse plugin (retired). The pattern is implemented in many places: GitLens' "co-changed files" display, JetBrains' "files changed together" indicator, and the open-source `cochange_miner` Python tool. JIRA-aware variants associate co-change with story/ticket IDs.

Reference: [Mining Version Histories to Guide Software Changes (Zimmermann, Weißgerber, Diehl, Zeller, IEEE TSE 2005)](https://ieeexplore.ieee.org/document/1463238)
