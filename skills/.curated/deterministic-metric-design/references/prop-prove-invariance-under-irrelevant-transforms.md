---
title: Prove Invariance Under Transformations That Shouldn't Matter
impact: HIGH
impactDescription: prevents the metric from measuring surface text instead of structure
tags: prop, invariance, alpha-equivalence, normalization
---

## Prove Invariance Under Transformations That Shouldn't Matter

A code metric that claims to measure structure must be invariant to renaming, formatting, and comment edits — programs that differ only by those should get the identical number. This is Weyuker's renaming property: if P is a renaming of Q, then |P| = |Q|. If renaming a variable changes the score, the metric is partly measuring identifier text, and an agent can move it without changing anything real. Establish invariance by computing on a normalized representation where the irrelevant differences are erased.

**Incorrect (token-length sensitivity):**

```python
def complexity(src):
    return len(tokenize(src))     # renaming `x` to `customer_account_balance` raises "complexity"
```

**Correct (compute on a normalized AST — invariant to renaming and formatting):**

```python
# Alpha-rename to canonical names and drop formatting/comments, THEN measure.
def complexity(src):
    tree = canonicalize(parse_to_ast(src))   # alpha-equivalent inputs map to the same tree
    return count_decision_points(tree)        # identical for renamed / reformatted variants
```

Pair this with `prop-ensure-sensitivity-to-relevant-change` — invariance to the irrelevant is only half the requirement.

Reference: [Weyuker, "Evaluating Software Complexity Measures," *IEEE TSE* 14(9) (1988) — property 8 (renaming)](https://doi.org/10.1109/32.6178)
