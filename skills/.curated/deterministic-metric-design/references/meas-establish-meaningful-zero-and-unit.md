---
title: Establish a Meaningful Zero and a Named Unit
impact: HIGH
impactDescription: prevents invalid ratio claims made without a true zero and unit
tags: meas, ratio-scale, unit, zero
---

## Establish a Meaningful Zero and a Named Unit

Ratio statements ("module A is twice as reducible as B") require a true, non-arbitrary zero, and any cross-artifact comparison requires a fixed unit. A bare 0–100 "score" with no stated meaning for 0 or for one point supports neither — you cannot say what doubling it means, and two teams will anchor it differently. Define the unit (what one increment counts) and the zero (the genuine absence of the property); ratio reasoning then becomes valid and portable.

**Incorrect (scoreless scale):**

```python
def complexity(fn):
    return min(100, raw_score(fn))   # what is 0? what is one point? "twice as complex" of what?
```

**Correct (named unit, true zero):**

```python
# Unit  = one AST node a behavior-preserving rewrite can remove.
# Zero  = nothing removable (a genuine zero) → ratio scale, so "twice as reducible" is meaningful.
def removable_nodes(module, T, O):
    return size(module) - size(apply_all(module, T))   # count; unit = node; zero = 0 removable
```

Reference: [Fenton & Bieman, *Software Metrics*, Ch. 2 — measurement scales](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
