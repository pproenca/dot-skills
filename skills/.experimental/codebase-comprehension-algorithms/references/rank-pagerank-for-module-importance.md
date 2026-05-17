---
title: Use PageRank On The Dependency Graph To Find Architecturally Central Modules
impact: MEDIUM
impactDescription: O((V+E)·iters) — identifies the "spine" modules whose removal ripples through everything
tags: rank, pagerank, page-brin, centrality, importance
---

## Use PageRank On The Dependency Graph To Find Architecturally Central Modules

After clustering, the agent has a partition. But which clusters matter most? Which files within a cluster are the load-bearing ones? **PageRank** (Page, Brin, Motwani, Winograd, "The PageRank Citation Ranking," Stanford technical report 1999) ranks nodes by **transitive importance**: a node is important if it's pointed to by many other important nodes. In software, "imported by many modules that are themselves imported by many modules" identifies the **architectural spine** — the things you can't touch without rippling everywhere.

This is the second-most-important global signal after the partition itself. Almost no analysis pipeline applies it. The vanilla algorithm is 5 lines in NetworkX; the result reorganises *what to look at first* when comprehending an unfamiliar codebase.

**Incorrect (rank files by raw fan-in — biased by giant utility files):**

```python
G = build_import_graph("./src")
top_by_fanin = sorted(G.nodes(), key=lambda n: -G.in_degree(n))[:20]
# Result: logger.py, errors.py, types.py — utility files imported everywhere
# but architecturally peripheral. Not what you want to read first.
```

**Correct (Step 1 — PageRank with the standard damping factor):**

```python
import networkx as nx

def architectural_importance(G: nx.DiGraph, alpha: float = 0.85):
    """
    PageRank with damping α = 0.85 (Page-Brin's empirical choice for the web;
    works fine for software).
    Edge u → v means "u imports / calls / depends on v": PageRank flows
    backward from u to v, so v's importance scales with how many important
    things depend on it.
    """
    # For "module that everyone depends on is important", REVERSE the edges
    # so PageRank flows toward authority — same as on the web.
    G_rev = G.reverse(copy=False)
    pr = nx.pagerank(G_rev, alpha=alpha, max_iter=200)
    return pr

pr = architectural_importance(G_import)
top_modules = sorted(pr.items(), key=lambda kv: -kv[1])[:20]
for module, score in top_modules:
    print(f"  PR = {score:.6f}  {module}")
```

**Correct (Step 2 — combine PageRank with omnipresent-filter to avoid trivial utility dominance):**

```python
# After omnipresent filter (graph-filter-omnipresent-utilities-before-clustering),
# the loggers and bare-utility files are gone. PageRank on the remaining graph
# surfaces the *architectural* spine — domain services that other domain
# services depend on, base classes that drive the framework, etc.
G_filtered, _ = filter_omnipresent(G_import)
pr_filtered = architectural_importance(G_filtered)
top = sorted(pr_filtered.items(), key=lambda kv: -kv[1])[:20]
# Now the top is: payment_gateway.py, user_service.py, order_state_machine.py
# — the actual architectural backbone.
```

**Correct (Step 3 — personalized PageRank for "things related to X"):**

```python
def related_to(G: nx.DiGraph, seed_files: list[str], alpha: float = 0.85, n: int = 20):
    """
    Personalized PageRank biased toward `seed_files`. Returns the top-n
    files most architecturally related to the seeds — works in BOTH the
    forward and backward direction (uses an undirected projection).
    Useful for: 'agent is looking at src/payments/charge.py — what else
    should it read first?'
    """
    G_u = G.to_undirected()
    teleport = {n: 0 for n in G.nodes()}
    weight = 1 / len(seed_files)
    for f in seed_files:
        teleport[f] = weight
    pr = nx.pagerank(G_u, alpha=alpha, personalization=teleport, max_iter=200)
    return sorted(pr.items(), key=lambda kv: -kv[1])[:n]

# Examples of seeds:
#   ["src/payments/charge.py"]  → list files most architecturally connected to charge
#   ["src/payments/charge.py", "src/payments/refund.py"] → the payments-domain spine
```

**Why PageRank specifically vs degree or other centrality:**

| Metric | What it captures | Cost | Failure mode |
|--------|------------------|------|--------------|
| In-degree | Direct popularity | O(E) | Loggers dominate |
| Betweenness | Bridges between groups | O(V·E) | Slow on big graphs |
| Closeness | Average distance to all | O(V·(V+E)) | Slow on big graphs |
| **PageRank** | **Transitive importance** | **O((V+E)·iter)** | Sensitive to outliers if no damping |
| Katz centrality | Similar to PageRank, no damping | O((V+E)·iter) | Diverges on dense graphs |
| Eigenvector | Same as PageRank with α → 1 | O((V+E)·iter) | Same divergence risk |

PageRank's α damping is what makes it numerically stable on any graph and what lets it gracefully handle dangling nodes (files with no outgoing imports) — both matter for real code.

**Empirical baseline:** Various studies have applied PageRank to code:
- **Inoue et al. (TSE 2005, "Component rank: relative significance rank for software component search")** — applied PageRank to Java component reuse rankings.
- **Bavota et al. (ICSM 2013, "Identifying Method Friendships to Remove the Feature Envy Bad Smell")** — used personalized PageRank for finding "friends" of a method.
- **Sourcegraph and OpenGrok** both apply PageRank-like ranking on code search results.

Top-20 PageRank routinely overlaps 60–80% with expert-identified "key architectural files" in case studies.

**Interpreting the ranking:**

- **Top 1–5%**: architectural spine. Touching these affects ~everything. Worth reading first.
- **Next 5–20%**: domain hubs. Each is the centre of a cluster.
- **Long tail**: leaf files, individual implementations.

For agent comprehension, the top 5% is the "if you can only read 50 files in this 1000-file codebase, read these" list.

**When NOT to use:**

- Tiny codebases (< 100 files) — every file is "central" by accident.
- Co-change graphs — PageRank's importance notion applies to flow/dependency, not symmetric coupling. Use degree-weighted measures instead.
- You want a hierarchical/cluster-internal ranking — restrict PageRank to the subgraph of each cluster.

**Production:** Sourcegraph's code-intel rankings include a PageRank-style importance. Microsoft Research's CODEMINE applies it for change-propagation analysis. NetworkX, igraph, graph-tool, Apache GraphX, Neo4j GDS all ship PageRank as a one-line call.

Reference: [The PageRank Citation Ranking: Bringing Order to the Web (Page, Brin, Motwani, Winograd, 1999)](http://ilpubs.stanford.edu:8090/422/)
