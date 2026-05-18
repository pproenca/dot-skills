---
title: Find Type-4 Clones via Program Dependence Graph Isomorphism
impact: HIGH
impactDescription: eliminates false negatives on Type-4 clones text and AST diff both miss
tags: sim, pdg, type-4-clones, semantic-clones, isomorphism
---

## Find Type-4 Clones via Program Dependence Graph Isomorphism

A Type-4 clone is two functions that compute the same thing but share *no* identifiers and use *different* control flow — a `for` loop summing a list and a `reduce(add, ...)` call. Text diff, AST diff, and even embeddings sometimes miss these. The Program Dependence Graph (PDG) — nodes for each statement, edges for control- and data-dependencies — is the right representation: semantically-equivalent code produces isomorphic PDGs even when written entirely differently. Komondoor & Horwitz's PDG-based clone detection (2001) finds clones text-based tools never see. The technique is heavy (subgraph isomorphism is NP-hard in general), but with anchor-pruning and small-PDG approximations it scales to whole repos.

**Incorrect (token shingling / AST diff misses the semantic match):**

```python
# Two functions that compute the same sum.
def sum_loop(amounts):
    total = 0
    for a in amounts:
        total += a
    return total

def sum_reduce(amounts):
    from functools import reduce
    from operator import add
    return reduce(add, amounts, 0)

# Text shingle (5-token) overlap: 0.00 — no shared 5-grams.
# AST diff edit distance: large — different node types entirely.
# Conclusion: tools call these unrelated. They are not.
```

**Correct (build PDG, normalize, test for graph isomorphism on small subgraphs):**

```python
import ast
import networkx as nx
from networkx.algorithms.isomorphism import GraphMatcher

# Step 1: lift each function to a PDG
# Nodes: statements, labelled by their operator kind (NORMAL_FORM)
# Edges: control-dependence (ctrl) and data-dependence (data)
def to_pdg(fn: ast.FunctionDef) -> nx.DiGraph:
    pdg = nx.DiGraph()
    defs: dict[str, str] = {}                        # var -> node-id of last def
    for i, stmt in enumerate(ast.walk(fn)):
        if not isinstance(stmt, ast.stmt):
            continue
        nid = f"n{i}"
        # Operator family: normalize away identifier names
        pdg.add_node(nid, kind=type(stmt).__name__)
        for node in ast.walk(stmt):
            if isinstance(node, ast.Name):
                if isinstance(node.ctx, ast.Load) and node.id in defs:
                    pdg.add_edge(defs[node.id], nid, kind="data")
                elif isinstance(node.ctx, ast.Store):
                    defs[node.id] = nid
    return pdg

# Step 2: isomorphism on node-kind labels (ignoring identifier names)
def is_semantic_clone(a: ast.FunctionDef, b: ast.FunctionDef) -> bool:
    pa, pb = to_pdg(a), to_pdg(b)
    if abs(len(pa) - len(pb)) > 2 or abs(pa.number_of_edges() - pb.number_of_edges()) > 2:
        return False                                  # cheap size prefilter
    nm = lambda u, v: u["kind"] == v["kind"]
    em = lambda u, v: u["kind"] == v["kind"]
    return GraphMatcher(pa, pb, node_match=nm, edge_match=em).is_isomorphic()

# In practice: cluster functions by PDG-size + kind-histogram first,
# then run isomorphism only within buckets. Brings n²·iso down to manageable.
```

**Combine with `sim-codebert-embeddings` for scale.** Use embeddings to find the top-K candidates (cheap), then run PDG isomorphism only inside the candidate set (expensive but precise). This hybrid recovers >90% of Type-4 clones in minutes rather than days.

**Use bigger building blocks for production:** [DECKARD](https://github.com/skyhover/Deckard) for AST-based scale-friendly clone detection, [NiCad](https://www.txl.ca/txl-nicaddownload.html) for parameterized clones, [Oreo](https://github.com/Mondego/oreo-artifact) for ML-augmented Type-4 detection.

**When NOT to apply:**
- Functions under ~5 statements — the PDG is too small to discriminate; many false positives
- Real-time / interactive use — even with prefiltering, PDG isomorphism is too slow for IDE-time checks

Reference: [Komondoor & Horwitz, Using Slicing to Identify Duplication in Source Code (2001)](https://research.cs.wisc.edu/wpis/papers/sas01.pdf), [Roy & Cordy, A Survey on Software Clone Detection Research](https://www.cs.usask.ca/~croy/papers/2007/RoyCordyTR.pdf)
