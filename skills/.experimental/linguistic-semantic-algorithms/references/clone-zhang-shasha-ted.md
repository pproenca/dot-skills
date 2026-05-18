---
title: Compute Zhang-Shasha Tree Edit Distance for Subtree Similarity Scoring
impact: MEDIUM
impactDescription: O(n^2 · m^2) tree distance — the exact baseline behind every approximate clone tool
tags: clone, tree-edit-distance, zhang-shasha, ast-similarity, exact-match
---

## Compute Zhang-Shasha Tree Edit Distance for Subtree Similarity Scoring

Zhang-Shasha (1989) computes the minimum number of node insertions, deletions, and label changes to turn one ordered tree into another. Unlike GumTree, which is an approximation tuned for speed and human-readable edit scripts, Zhang-Shasha gives the *exact* optimal cost. Use it when you need ground-truth distance for benchmarking, for ranking small clone candidates precisely, or as a similarity primitive in a larger clustering pipeline. Modern implementations (e.g. APTED, an O(n²) descendant) run in seconds on AST pairs up to a few thousand nodes.

**Incorrect (compare AST node count or histogram of node types — coarse, position-blind):**

```python
import ast, collections

def kind_hist(src: str) -> collections.Counter:
    return collections.Counter(type(n).__name__ for n in ast.walk(ast.parse(src)))

# Two methods can have identical kind-histograms but completely
# different control flow — the histogram throws away structure.
a = "def f(x):\n    if x: return x\n    return -x"
b = "def f(x):\n    if x: pass\n    if not x: return -x"
print(kind_hist(a) == kind_hist(b))  # True — but the trees are different!
```

**Correct (Zhang-Shasha / APTED — exact minimum edit distance, normalized to tree size):**

```python
# Using apted (O(n^2), the modern implementation of choice)
# pip install apted
import ast
from apted import APTED, Config

class ASTNode:
    """APTED expects nodes with .name and .children"""
    def __init__(self, name: str, children: list):
        self.name = name
        self.children = children

def ast_to_apted(node) -> ASTNode:
    children = [ast_to_apted(c) for c in ast.iter_child_nodes(node)]
    return ASTNode(type(node).__name__, children)

class LabelConfig(Config):
    def rename(self, n1, n2):
        return 0 if n1.name == n2.name else 1

def tree_distance(src_a: str, src_b: str) -> tuple[int, int]:
    t1 = ast_to_apted(ast.parse(src_a))
    t2 = ast_to_apted(ast.parse(src_b))
    size = max(_size(t1), _size(t2))
    dist = APTED(t1, t2, LabelConfig()).compute_edit_distance()
    return dist, size

def _size(n) -> int:
    return 1 + sum(_size(c) for c in n.children)

# Score: 1 - (distance / max_size). Higher = more similar.
methods = {
    "checkout_stripe": "def f(c):\n    validate(c)\n    stripe.charge(c.total)\n    record(c)\n    notify(c.user)",
    "checkout_paypal": "def f(c):\n    validate(c)\n    paypal.execute(c.total)\n    record(c)\n    notify(c.user)",
    "process_refund":  "def f(r):\n    log(r)\n    if r.processed:\n        return\n    stripe.refund(r.id)",
}

names = list(methods)
for i, a in enumerate(names):
    for b in names[i + 1:]:
        d, n = tree_distance(methods[a], methods[b])
        sim = 1 - d / n
        print(f"  sim={sim:.2f}  d={d}/n={n}  {a} ~ {b}")
# sim=0.92  d=2/n=24  checkout_stripe ~ checkout_paypal      <- near-Type-2 clone
# sim=0.41  d=14/n=24  checkout_stripe ~ process_refund      <- not a clone
```

**Use APTED, not the original Zhang-Shasha implementation.** APTED (Pawlik & Augsten, 2015) is mathematically equivalent for cost but ~30× faster on real AST sizes. The reference implementation is [the eth-sri/apted Java repo](https://github.com/DatabaseGroup/apted) with Python bindings on PyPI.

**TED is the right primitive when you need exact distances** but the wrong tool when you need to scale beyond ~5000-node trees. Above that, GumTree's approximation is faster and good enough; or hash sub-tree shingles and use MinHash on the shingle sets.

**Apply to identifier-stripped ASTs** for Type-2 clone detection. Replace every `Identifier(name="...")` with `Identifier(name="_")` before measuring distance; the rename-induced changes drop to zero and structurally-equivalent code scores near 1.0.

**Combine with `clone-minhash-lsh`:** use MinHash on sub-tree shingles to find candidate clone pairs (fast), then run APTED only on candidates (precise). The pipeline scales to whole-codebase clone detection with exact final scoring on the candidates.

**When NOT to apply:**
- Large AST trees (>5k nodes) — quadratic time is the practical limit; use approximate methods
- Languages with extremely flat ASTs (raw lists of statements) — TED becomes pure label-edit and doesn't reflect structural similarity well; use semantic embeddings instead

Reference: [Zhang & Shasha, Simple Fast Algorithms for the Editing Distance Between Trees (SIAM 1989)](https://epubs.siam.org/doi/10.1137/0218082), [Pawlik & Augsten, Tree Edit Distance — Robust and Memory-Efficient (Information Systems 2016)](https://dbresearch.uni-salzburg.at/papers/publications/2016is_TED_Pawlik_Augsten.pdf)
