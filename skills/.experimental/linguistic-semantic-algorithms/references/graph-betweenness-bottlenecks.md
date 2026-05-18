---
title: Use Betweenness Centrality to Find Bottleneck Modules
impact: HIGH
impactDescription: prevents brittle refactors by surfacing bottleneck modules
tags: graph, betweenness, centrality, bottleneck, refactoring-targets
---

## Use Betweenness Centrality to Find Bottleneck Modules

Betweenness centrality measures how often a node sits on the shortest path between other pairs of nodes. In a code graph, a high-betweenness file is a *bottleneck*: changes to it ripple across the graph, and removing it would shatter the dependency structure. These files are rarely the most-imported (PageRank already finds those) — they're typically modest-import-count files sitting on critical paths between sub-systems. They are exactly the files where one careless refactor breaks five seemingly-unrelated features.

**Incorrect (look at imports / lines-of-code — both miss path-criticality):**

```python
# Files ranked by LoC and import count. A file with 30 imports
# and 2000 LoC looks "big" but might be a leaf service.
# Meanwhile a 200-LoC adapter that bridges two large sub-systems
# scores low here — yet it is the actual bottleneck.
import pathlib

stats = []
for p in pathlib.Path("src").rglob("*.py"):
    src = p.read_text(errors="ignore")
    loc = len([l for l in src.splitlines() if l.strip()])
    imports = src.count("import ")
    stats.append((loc + 10 * imports, p))
for score, p in sorted(stats, reverse=True)[:10]:
    print(f"  {score:>5}  {p}")
```

**Correct (betweenness centrality on the file graph — bottlenecks surface):**

```python
import ast, pathlib
import networkx as nx

G = nx.Graph()                                       # undirected for shortest paths
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): str(p) for p in files}

for p in files:
    G.add_node(str(p))
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(str(p), mod_map[node.module])

# Exact betweenness is O(V·E); use the approximation for large graphs
if len(G) > 5000:
    bc = nx.betweenness_centrality(G, k=500, seed=42)   # k=500 sample
else:
    bc = nx.betweenness_centrality(G)

top = sorted(bc.items(), key=lambda kv: -kv[1])[:15]
for path, score in top:
    print(f"  {score:.4f}  {path}")
# 0.142  src/adapters/payments/gateway.py     <- bridges billing & ledger
# 0.118  src/core/events/bus.py               <- the bus everything goes over
# 0.097  src/integrations/stripe/client.py
# 0.084  src/adapters/messaging/dispatch.py
```

**Compare with PageRank.** A file high on PageRank but low on betweenness is a popular dependency (e.g., a logging helper). A file high on betweenness but low on PageRank is a *bridge* — far more dangerous to refactor without care, because its callers are diverse.

**Use edge-betweenness for cycle-breaking decisions.** `nx.edge_betweenness_centrality(G)` ranks *edges* the same way; the highest-scoring edges are the import statements you should delete first when breaking a tangle (see `graph-feedback-arcs`).

**Combine with `mine-change-coupling`:** a high-betweenness file that also has high temporal coupling with many others is a refactoring target — it carries architectural load *and* changes constantly.

**When NOT to apply:**
- Densely-connected graphs (everything imports everything) — betweenness scores all converge and the ranking is uninformative
- Real-time use — betweenness on a 50k-node graph takes minutes even with sampling; precompute and store

Reference: [Freeman, A set of measures of centrality based on betweenness (Sociometry 1977)](https://www.jstor.org/stable/3033543), [Brandes, A faster algorithm for betweenness centrality (2001)](http://www.algo.uni-konstanz.de/publications/b-fabc-01.pdf)
