---
title: Run PageRank on the Import Graph to Find the Codebase Core
impact: HIGH
impactDescription: ranks the 1% of files that everything depends on
tags: graph, pagerank, import-graph, centrality, networkx
---

## Run PageRank on the Import Graph to Find the Codebase Core

When you join a new codebase, the highest-leverage move is to read the ~20 files that everything else depends on — the "core" — *before* reading any features. PageRank on the directed import graph identifies these files automatically. A file imported by many other important files gets a high score. The eigenvector behind the algorithm bakes in the recursive property: importance is conferred by other important things. The output is a ranked file list; reading the top 20 gives you the codebase's mental model in an afternoon, not three weeks.

**Incorrect (sort by in-degree — confuses popular with central):**

```python
# Naive: count how many files import each file.
import ast, pathlib, collections

in_degree: collections.Counter = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            in_degree[node.module] += 1

# Top results: "logging" (imported 800x), "typing", "os".
# These are popular but not *central* — they are leaves of the
# import DAG, not hubs. Importing them tells you nothing.
for mod, n in in_degree.most_common(10):
    print(f"  {n:>5}  {mod}")
```

**Correct (PageRank — importance propagates through the graph):**

```python
import ast, pathlib
import networkx as nx

# Build directed graph: edge A -> B means A imports B
G = nx.DiGraph()
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): str(p) for p in files}

for p in files:
    src_node = str(p)
    G.add_node(src_node)
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(src_node, mod_map[node.module])

# PageRank — damping 0.85 is the standard from Brin & Page
pr = nx.pagerank(G, alpha=0.85)
top = sorted(pr.items(), key=lambda kv: -kv[1])[:20]
for path, score in top:
    print(f"  {score:.4f}  {path}")
# 0.0421  src/core/db/session.py        <- everything goes through this
# 0.0398  src/core/auth/context.py
# 0.0367  src/domain/listing/repository.py
# 0.0341  src/api/response.py
# 0.0289  src/domain/sitter/repository.py
```

**Reverse the edge direction** to find files that *use* the most rather than files that *are used* the most — useful for finding the top-level entry points of the system. `nx.pagerank(G.reverse())`.

**Weight by import frequency** if your language allows multiple imports from the same module (Python's `from x import a, b, c`). Counting each `import` statement as edge weight slightly improves precision on heavily-fanned-in modules.

**Read the top-20 in order on day one.** This is the single highest-ROI orientation activity in a new codebase — far more than reading READMEs or top-level directories.

**Combine with `mine-hotspots-churn-complexity`:** files high on PageRank *and* high on churn × complexity are the architectural debt magnets. Reading them tells you where the codebase's pain lives.

**When NOT to apply:**
- Monorepos with many independent packages — run PageRank per package, not globally; otherwise low-coupling packages dilute the score
- Dynamic-import-heavy codebases (factory patterns) — static import graph misses runtime dependencies; use a runtime call profile instead

Reference: [Brin & Page, The Anatomy of a Large-Scale Hypertextual Web Search Engine](http://infolab.stanford.edu/~backrub/google.html), [NetworkX pagerank](https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.link_analysis.pagerank_alg.pagerank.html)
