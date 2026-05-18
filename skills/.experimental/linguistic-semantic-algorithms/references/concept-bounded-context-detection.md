---
title: Detect DDD Bounded Contexts via Louvain Communities Plus Vocabulary Divergence
impact: HIGH
impactDescription: automatic detection of bounded-context candidates without manual partitioning
tags: concept, ddd, bounded-context, louvain, community-detection
---

## Detect DDD Bounded Contexts via Louvain Communities Plus Vocabulary Divergence

A bounded context (Evans, Domain-Driven Design) is a region of the codebase where a shared term has a single, internally consistent meaning. Real codebases don't declare their bounded contexts — they emerge from naming and call-graph topology. Two signals identify them with high precision: (1) Louvain community detection on the file-level import graph identifies densely-connected clusters; (2) Jensen-Shannon divergence on the per-cluster identifier-vocabulary distribution confirms the clusters use *different* vocabularies. When both signals agree, you have a bounded context. The output is a partition of the codebase that maps to real domain boundaries — for refactoring, micro-service extraction, or just for orientation.

**Incorrect (use the directory structure as bounded contexts — assumes folders match domains):**

```python
# Treat every top-level directory under src/ as a bounded context.
# Wrong: legacy codebases often have a single "models" directory
# containing entities from 4 different contexts.
import pathlib

contexts = {p.name: list(p.rglob("*.py")) for p in pathlib.Path("src").iterdir() if p.is_dir()}
# {"models": [user.py, invoice.py, sitter.py, listing.py, ...],
#  "services": [user_service.py, billing_service.py, ...],
#  "controllers": [...]}
# Every "context" is actually a layer, not a bounded context.
```

**Correct (Louvain on import graph + Jensen-Shannon divergence on vocabularies):**

```python
import ast, re, pathlib, collections, math
import networkx as nx

WORD = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")

# 1. Build the file-level import graph
G = nx.Graph()
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): p for p in files}

for p in files:
    G.add_node(str(p))
    for node in ast.walk(ast.parse(p.read_text(errors="ignore"))):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(str(p), str(mod_map[node.module]))

# 2. Louvain communities = dense clusters in the import graph
communities = nx.community.louvain_communities(G, seed=42)

# 3. For each community, build its identifier-token distribution
def vocab(files: list[str]) -> collections.Counter:
    c = collections.Counter()
    for f in files:
        c.update(w.lower() for w in WORD.findall(pathlib.Path(f).read_text(errors="ignore")))
    return c

dists = [vocab(c) for c in communities]

# 4. Jensen-Shannon divergence between every pair of communities
def js_divergence(p: dict, q: dict) -> float:
    keys = set(p) | set(q)
    sp, sq = sum(p.values()), sum(q.values())
    div = 0.0
    for k in keys:
        pi, qi = p.get(k, 0) / sp, q.get(k, 0) / sq
        m = 0.5 * (pi + qi)
        if pi > 0: div += 0.5 * pi * math.log(pi / m)
        if qi > 0: div += 0.5 * qi * math.log(qi / m)
    return div

# A community is a true bounded context if mean JS-divergence to others > 0.25
for i, comm in enumerate(communities):
    other = collections.Counter()
    for j, d in enumerate(dists):
        if j != i: other.update(d)
    div = js_divergence(dists[i], other)
    if div > 0.25:
        top_terms = [w for w, _ in dists[i].most_common(8)]
        print(f"Context {i}: |files|={len(comm)} JS={div:.2f} top_terms={top_terms}")
# Context 0: |files|=42 JS=0.41 top_terms=['sitter', 'listing', 'host', 'application', 'stay', ...]
# Context 2: |files|=18 JS=0.38 top_terms=['invoice', 'subscription', 'plan', 'charge', ...]
# Context 5: |files|=27 JS=0.31 top_terms=['user', 'session', 'auth', 'token', 'login', ...]
```

**Validate against the team's mental model.** The output is a *candidate* partition — show it to a domain expert and ask "does this match how you think about the system?". Real bounded contexts that the algorithm misses signal places where the code's structure has drifted from the domain.

**Combined with `mine-change-coupling`:** files that change together across contexts are leaky abstractions. Co-change between bounded contexts is a refactoring signal — those files belong in a shared kernel.

**When NOT to apply:**
- Monolithic codebases with no internal module boundaries — Louvain returns one giant community
- Codebases following strict layered architecture — the layers will be detected as "contexts" but they aren't; weight by `concept-tfidf-rare-terms` to confirm domain divergence

Reference: [Evans, Domain-Driven Design](https://www.domainlanguage.com/ddd/), [Blondel et al., Fast unfolding of communities (Louvain, 2008)](https://arxiv.org/abs/0803.0476), [Lin, Divergence Measures Based on Shannon Entropy](https://ieeexplore.ieee.org/document/61115)
