---
title: Control Floating-Point Order and Rounding
impact: MEDIUM-HIGH
impactDescription: prevents float drift from flipping threshold decisions
tags: det, floating-point, accumulation, rounding
---

## Control Floating-Point Order and Rounding

Floating-point addition is not associative, so summing the same values in a different order yields different low-order bits; when the result is compared to a threshold, that drift can flip a decision between runs. A metric that aggregates many weighted terms in hash-iteration order and then compares at full precision is non-deterministic exactly at the boundary cases that decisions hinge on. Sum in a fixed order (or use integer/rational arithmetic) and round to a defined precision before any comparison.

**Incorrect (order-dependent sum, full-precision compare):**

```python
score = sum(w[k] * feature[k] for k in feature)     # dict order + FP non-associativity
flagged = score > 0.80000000                          # boundary cases flip between runs
```

**Correct (fixed order, defined precision):**

```python
terms = [w[k] * feature[k] for k in sorted(feature)]  # deterministic summation order
score = round(math.fsum(terms), 6)                    # fsum is order-stable; fix the precision
flagged = score > 0.800000                             # compare at the same precision
```

Where exactness matters more than speed, accumulate in integers or `fractions.Fraction` and convert once at the end.

Reference: [Python docs — Floating-Point Arithmetic: Issues and Limitations](https://docs.python.org/3/tutorial/floatingpoint.html)
