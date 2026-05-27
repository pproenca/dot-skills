---
title: Prove the Claimed Bounds and Handle the Empty Case
impact: MEDIUM-HIGH
impactDescription: prevents NaN/inf and out-of-range values on real inputs
tags: prop, boundedness, normalization, edge-cases
---

## Prove the Claimed Bounds and Handle the Empty Case

If you advertise a metric as lying in [0, 1], prove it cannot exceed 1 or go negative on any real input, and prove the normalizing denominator is never zero. An empty module, a file with no functions, or a single-node AST are inputs that occur constantly and break naive ratios with division by zero or values outside the stated range. The proof is small; skipping it ships NaNs into dashboards and silently corrupts any threshold comparison downstream.

**Incorrect (denominator can be zero; range unproven):**

```python
def comment_density(fn):
    return comment_lines(fn) / code_lines(fn)   # code_lines == 0 for an abstract/empty method → ZeroDivisionError
```

**Correct (empty case defined; bound proven):**

```python
def comment_density(fn):
    code = code_lines(fn)
    if code == 0:
        return 0.0                              # defined convention: no code → density 0
    return comment_lines(fn) / (comment_lines(fn) + code)   # provably in [0, 1)
```

State the bound and the empty-case convention in the spec, not just the code — consumers set thresholds against the claimed range.

Reference: [Fenton & Bieman, *Software Metrics* — measurement validity and scales](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
