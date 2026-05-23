---
title: Operationalize "Behavior-Preserving Size Reduction" Concretely
impact: CRITICAL
impactDescription: prevents measuring something a code formatter can move for free
tags: def, behavior-preservation, observational-equivalence, size
---

## Operationalize "Behavior-Preserving Size Reduction" Concretely

"Reduce codebase size without changing how the app works" names two constructs that are useless until operationalized: *behavior* ("how the app works") and *size*. Behavior must become an observational equivalence relation over a fixed set of observations; size must become a counting unit that a formatter cannot move. Get these two definitions right and the computable proxy (see `comp-`) follows; get them wrong and you will "measure" something a code formatter can shift for free.

**Incorrect (both constructs left gameable / unfalsifiable):**

```python
size = count_lines(repo)                       # LOC: a formatter or minifier moves this freely
behavior_preserved = "looks the same to me"    # not an observation set, not checkable
```

Reformatting drops `size` with zero real reduction; "behavior" cannot be tested or falsified.

**Correct (behavior = observational equivalence; size = AST nodes):**

```python
# Behavior: observational equivalence (≈) over a FIXED observation set O.
#   O = recorded public-API I/O traces on corpus C  ∪  the project's test suite S
#   P ≈ P'  iff  P and P' agree on every observation in O
def behavior_preserved(before, after, O):
    return run_observations(after, O) == run_observations(before, O)

# Size: AST node count on the parsed, comment-stripped tree (not source bytes or lines)
def size(program):
    return count_nodes(parse_to_ast(program))  # invariant to whitespace and comments
```

"Smaller while ≈-equivalent" is now a falsifiable, formatter-proof claim. The choice of `O` is the metric's most important parameter — a weak `O` (one smoke test) makes ≈ easy to satisfy and the metric easy to game; record `O` as part of the metric's definition.

Reference: [Fowler, *Refactoring* — behavior-preserving transformation](https://martinfowler.com/books/refactoring.html)
