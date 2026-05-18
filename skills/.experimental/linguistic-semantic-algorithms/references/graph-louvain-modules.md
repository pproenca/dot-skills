---
title: Apply Louvain Community Detection to Reveal Natural Module Boundaries
impact: HIGH
impactDescription: reduces O(N^2) modularity search to O(N log N) for module discovery
tags: graph, louvain, community-detection, modularity, refactoring
---

## Apply Louvain Community Detection to Reveal Natural Module Boundaries

The folder structure of a 5-year-old codebase rarely matches its actual modular structure. Files that used to belong together have drifted across directories; files that share no real coupling sit next to each other. Louvain community detection (Blondel et al., 2008) maximizes graph modularity in O(N log N) — fast enough for million-node graphs — and partitions the import/call graph into communities that *actually* coheres. Differences between this partition and the directory tree are a directly-actionable list of files to move.

**Incorrect (use directory structure as the modular partition — assumes folders match reality):**

```python
# Treat each top-level directory as a module.
# Wrong on any codebase older than ~2 years.
import pathlib

modules = {p.name: list(p.rglob("*.py")) for p in pathlib.Path("src").iterdir() if p.is_dir()}
# Files have been moved, renamed, split, merged for years —
# directories no longer reflect the actual coupling structure.
```

**Correct (Louvain on the file-import graph — communities = real modules):**

```python
import ast, pathlib
import networkx as nx

G = nx.Graph()
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): str(p) for p in files}

for p in files:
    G.add_node(str(p))
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(str(p), mod_map[node.module])

communities = nx.community.louvain_communities(G, resolution=1.0, seed=42)
modularity = nx.community.modularity(G, communities)
print(f"Communities: {len(communities)}  Modularity Q: {modularity:.3f}")

# Compare against directory partition: files in same community but different directory
# are misplaced; files in same directory but different communities are leaky.
from collections import Counter
for i, comm in enumerate(sorted(communities, key=len, reverse=True)[:6]):
    dir_dist = Counter(str(pathlib.Path(f).parent) for f in comm)
    top_dirs = dir_dist.most_common(3)
    print(f"Community {i}: |{len(comm)}|  directories: {top_dirs}")
# Community 0: |42|  directories: [('src/billing', 18), ('src/admin', 14), ('src/api', 10)]
#   -> billing + admin + api all share a community — billing logic leaked into admin & api
```

**Tune `resolution`.** Higher (≥1.5) produces more, smaller communities; lower (≤0.7) produces fewer, larger ones. Sweep and pick the level that maximizes intuitive understanding — modularity Q is a useful signal but not the goal.

**A modularity Q above ~0.4 means the codebase has real modular structure;** below 0.2 means it is a "ball of mud" — the algorithm finds little to partition. Knowing this upfront sets expectations for any refactoring effort.

**Pair with `concept-tfidf-rare-terms` per community** to *name* the communities. A community's top TF-IDF domain terms are usually a coherent label.

**Combine with `mine-change-coupling`:** Louvain on the *temporal* coupling graph (files that change together) often differs sharply from Louvain on the *static* import graph. The difference points to architectural drift: places where structure says one thing and history says another.

**When NOT to apply:**
- Codebases where one giant file imports everything — Louvain collapses into one community
- When you need stable community membership across runs — Louvain is non-deterministic without `seed=`; use Leiden ([leidenalg](https://leidenalg.readthedocs.io/)) for guaranteed convergence

Reference: [Blondel et al., Fast unfolding of communities in large networks (2008)](https://arxiv.org/abs/0803.0476), [Traag et al., From Louvain to Leiden (2019)](https://www.nature.com/articles/s41598-019-41695-z)
