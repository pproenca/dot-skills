---
title: Pin Exactly Which Representation You Measure
impact: HIGH
impactDescription: prevents incomparable numbers across source, AST, and bytecode
tags: det, representation, ast, normalization
---

## Pin Exactly Which Representation You Measure

"The code" is ambiguous: raw source, formatted source, token stream, parse tree, desugared AST, post-macro expansion, and bytecode each yield different counts for the "same" program. Two tools that both claim to measure "size" but operate on different representations produce numbers that cannot be compared, and a single tool that changes representation between versions breaks its own history. Pin one representation in the operational definition, name the exact stage, and version it.

**Incorrect (representation unstated → tools disagree):**

```python
size_a = len(open(path).read().split("\n"))   # raw lines, includes blanks and comments
size_b = count_nodes(parse(path))              # AST nodes
# Both get reported as "size"; they disagree by ~3x and nobody can reconcile them.
```

**Correct (one named representation, fixed stage):**

```python
# Definition: size = number of nodes in the CPython AST from ast.parse, comments excluded,
# measured BEFORE any optimization pass. Grammar/tool version recorded with the value.
def size(path):
    return count_nodes(ast.parse(Path(path).read_text()))   # one canonical representation
```

Reference: [Python docs — `ast` (Abstract Syntax Trees)](https://docs.python.org/3/library/ast.html)
