---
title: Use the GumTree Algorithm for Fine-Grained AST Differencing
impact: MEDIUM-HIGH
impactDescription: reduces a 240-line text diff to 4 semantic AST actions on typical refactors
tags: clone, gumtree, ast-diff, edit-script, falleri
---

## Use the GumTree Algorithm for Fine-Grained AST Differencing

`git diff` works on lines; it shows reformatting as a massive change and reorderings as deletions-plus-insertions. The GumTree algorithm (Falleri et al., 2014) works on AST nodes and produces a *node-level edit script* — "method `processOrder` was moved from class `A` to class `B`, then 3 statements were swapped". The same machinery detects fine-grained syntactic clones: two methods are clones if the edit script between their ASTs is small. This is the right tool for behavioural diff in code review, refactoring impact analysis, and Type-2/Type-3 clone detection.

**Incorrect (line-based diff — confuses reformatting and movement with substantive change):**

```bash
# A formatter run shows up as the entire file changed.
# A method-move shows up as a delete + an insert in a different place,
# losing the link that this is the SAME method.
git diff src/orders.py
# 240 lines changed — but the actual semantic change is one move + 2 statements.
```

**Correct (GumTree — AST-level move/insert/delete/update operations):**

```python
# GumTree has implementations in Java (reference), Python, JS, and many wrappers.
# Below: gumtree-python invocation, then interpretation of the edit script.
import subprocess, json

# 1. Run gumtree between two versions of a file (or two clone candidates)
def gumtree_diff(left: str, right: str) -> list[dict]:
    out = subprocess.check_output([
        "gumtree", "textdiff", left, right, "--output", "json",
    ]).decode()
    return json.loads(out)["actions"]

actions = gumtree_diff("src/orders.py@v1", "src/orders.py@v2")
for a in actions:
    print(f"  {a['action']:>8}  node={a['tree']:>20}  at {a['at']}")
# Output (compressed):
# move      MethodDecl:processOrder    class A -> class B
# update    Identifier:gateway         old="stripe" new="paypal"
# insert    Statement:return           in method:abort
# delete    Statement:log              in method:abort
# A 240-line text diff reduces to 4 semantic actions.
```

**As a clone detector**, compare every pair of method ASTs and rank pairs by edit-script length normalized to subtree size:

```python
# Clone score = 1 - (|edit_script| / |subtree_size|)
# 1.0 = identical; 0.9+ = near-Type-2; 0.7-0.9 = Type-3; <0.7 = behavioural divergence
def clone_score(left_method: str, right_method: str, tree_size: int) -> float:
    actions = gumtree_diff(left_method, right_method)
    return 1 - len(actions) / tree_size
```

**Use [GumTree's standard library implementations](https://github.com/GumTreeDiff/gumtree)** — Java is the reference, but Python (`gumtree-python`) and JS (`gumtree-js`) wrappers exist for whichever runtime fits your tooling.

**Better than `tree-sitter`-based diff for many cases.** Tree-sitter gives you the AST; GumTree gives you the *mapping between two ASTs*. The mapping is the hard part, and GumTree's top-down + bottom-up matching is the best general-purpose algorithm available.

**Combine with `mine-change-coupling`:** when two files change together (high coupling) AND their AST diffs are *symmetric* (the same logical change in both), they're cousin-clones that should share an abstraction. The combined signal directly proposes a refactor.

**Use the edit script in PR review** for cleaner reviewer experience. A change with 240 text-diff lines but only 4 GumTree actions is a low-risk refactor. A change with 30 text-diff lines but 50 GumTree actions is a deceptively-small commit with broad semantic impact. Both are misleading on text-diff alone.

**When NOT to apply:**
- Tiny snippets (<10 AST nodes) — every clone-score sits near 1.0 and discrimination fails
- Languages without a robust parser in the GumTree ecosystem — fall back to tree-sitter + Zhang-Shasha (see `clone-zhang-shasha-ted`)

Reference: [Falleri et al., Fine-grained and Accurate Source Code Differencing (ASE 2014)](https://hal.science/hal-01054552/document), [GumTree GitHub](https://github.com/GumTreeDiff/gumtree)
