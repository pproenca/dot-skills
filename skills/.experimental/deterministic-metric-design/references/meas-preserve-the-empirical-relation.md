---
title: Make the Metric a Homomorphism of the Real Relation
impact: HIGH
impactDescription: prevents a metric whose ordering contradicts the real ordering
tags: meas, representational-theory, homomorphism, anchor-cases
---

## Make the Metric a Homomorphism of the Real Relation

The representational theory of measurement says a valid measure is a homomorphism from an empirical relational structure into a numerical one: if A genuinely has more of the property than B, then `metric(A) > metric(B)`. Before trusting a metric, check this representation condition on anchor cases everyone agrees on. If a module the whole team calls "more coupled" scores lower, the mapping does not preserve the relation, and the metric is invalid no matter how principled the formula looks.

**Incorrect (representation never checked):**

```python
score = coupling_formula(module)   # shipped without verifying it orders known cases correctly
```

**Correct (verify order preservation on anchor cases):**

```python
# Anchor pairs the team agrees on. The metric MUST reproduce their ordering.
ANCHORS = [("god_object", "leaf_logger"), ("payment_gateway", "string_helpers")]
for more_coupled, less_coupled in ANCHORS:
    assert coupling(more_coupled) > coupling(less_coupled), "representation condition violated"
```

A metric that fails an anchor case is not "a bit noisy" — it is measuring a different relation than the one you named.

Reference: [Fenton & Bieman, *Software Metrics* — the representation condition](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
