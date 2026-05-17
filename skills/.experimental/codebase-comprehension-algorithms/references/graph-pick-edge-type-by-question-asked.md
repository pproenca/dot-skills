---
title: Pick The Edge Type By The Question You're Asking
impact: CRITICAL
impactDescription: 30-50% disagreement between structural and co-change clusterings on the same codebase (Beck-Diehl 2013)
tags: graph, edge-semantics, call-graph, import-graph, co-change, bipartite
---

## Pick The Edge Type By The Question You're Asking

A codebase is not "a graph." It's at least four overlapping graphs, and each surfaces a different structure:

| Graph | Edge | Surfaces | Best for |
|-------|------|----------|----------|
| **Call graph** | `f` calls `g` | Runtime behaviour, control flow | "What does this feature *execute*?" |
| **Import / dependency graph** | module A imports B | Static coupling | "What modules form a unit?" |
| **Co-change graph** | A and B changed in same commit | Evolutionary coupling (developer intent) | "What do humans treat as one feature?" |
| **File × identifier bipartite** | file F mentions term T | Lexical / semantic | "What's this code *about*?" |

Generic community detection (Louvain, Leiden, Infomap) doesn't care which one you give it. *You* care, because each surfaces a different decomposition and the agent's job determines which is right. Building a single combined graph and clustering it (without thinking) is the worst of all worlds — signals contradict, noise dominates, and the result is unstable across runs.

The non-obvious finding from the SAR literature (Shtern-Tzerpos survey, ASE 2012; Beck-Diehl, EMSE 2013): **co-change clustering disagrees with structural clustering on 30–50% of file assignments** in mature codebases, and *both* are right — they answer different questions.

**Incorrect (build "a dependency graph", cluster, present as truth):**

```python
import networkx as nx
import ast

G = nx.DiGraph()
for f in iter_python_files("./src"):
    tree = ast.parse(open(f).read())
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            G.add_edge(f, resolve_module(node.module))

# Cluster and present. But: this graph misses runtime polymorphism, misses
# co-change coupling, misses lexical similarity. The agent is now confidently
# wrong about the architecture.
clusters = list(nx.algorithms.community.louvain_communities(G.to_undirected()))
```

**Correct (choose the graph for the question, or build multiple and compare):**

```python
def build_graph_for(question: str, repo: str):
    if question in {"feature-boundaries", "what-is-one-unit-of-change"}:
        # Developer intent: files changed together over the last 6 months
        return build_cochange_graph(repo, since="6 months ago")
    elif question in {"runtime-impact", "what-does-this-execute"}:
        # Call graph from a static analyser (pyan, jedi, tree-sitter)
        return build_call_graph(repo)
    elif question in {"static-coupling", "what-must-deploy-together"}:
        return build_import_graph(repo)
    elif question in {"domain-themes", "what-is-this-about"}:
        return build_bipartite_file_term_graph(repo)
    else:
        raise ValueError(f"Pick a question; got {question!r}")

# When unsure, build several and compare clusterings via NMI / MoJoFM
# (see valid-mojofm-as-software-clustering-distance). Disagreement is signal:
# it tells you where the static structure doesn't match developer intent.
```

**Alternative (multilayer graph when you really need to combine signals — see also `graph-combine-signals-in-multilayer-graphs`):**

```python
# Don't sum edge weights from different graphs naively — they live on different
# scales. Normalize each layer's weights to [0,1] by max-weight, then combine
# with explicit per-layer α weights you can ablate.
def multilayer(G_call, G_import, G_cochange, alpha=(0.3, 0.3, 0.4)):
    H = nx.Graph()
    for layer, a in zip([G_call, G_import, G_cochange], alpha):
        wmax = max((d.get("weight", 1) for _, _, d in layer.edges(data=True)), default=1)
        for u, v, d in layer.edges(data=True):
            w_norm = d.get("weight", 1) / wmax * a
            if H.has_edge(u, v):
                H[u][v]["weight"] += w_norm
            else:
                H.add_edge(u, v, weight=w_norm)
    return H
```

**Empirical findings worth knowing:**

- Beck & Diehl (EMSE 2013, "Evaluating the impact of software evolution on software clustering") — co-change clustering produces decompositions ~20 MoJoFM points closer to expert ground truth than import-graph clustering on Java open-source systems.
- Maletic & Marcus (ICSE 2001, "Supporting program comprehension using semantic and structural information") — combining LSI (lexical) with import edges beats either alone by 15–25 MoJoFM points.
- Murphy et al. (TSE 2001 reflexion follow-up) — runtime call graphs disagree with static import graphs on 25%+ of edges in OO codebases due to dynamic dispatch.

**When NOT to mix:**

- Tiny commit history (< ~200 commits) — co-change is dominated by initial scaffolding commits and is useless.
- No test coverage — runtime call graph is unreliable; fall back to static.
- Polyglot mono-repo — separate by language first, *then* cluster within each, then stitch.

**Production:** Microsoft CodeBook (Begel et al.) and IBM CodeStation (Bull et al.) both let users pick the edge type interactively for exactly this reason. Sourcegraph maintains call, import, and co-change graphs separately; jQAssistant exposes them as separate Neo4j relationship types.

Reference: [Clustering Methodologies for Software Engineering (Shtern & Tzerpos, ASE 2012 survey)](https://www.hindawi.com/journals/ase/2012/792024/)
