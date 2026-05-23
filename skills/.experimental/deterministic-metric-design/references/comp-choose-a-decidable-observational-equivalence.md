---
title: Replace Undecidable Equivalence With a Checkable Observational Relation
impact: CRITICAL
impactDescription: prevents relying on undecidable full program equivalence
tags: comp, observational-equivalence, decidability, property-testing
---

## Replace Undecidable Equivalence With a Checkable Observational Relation

Full program equivalence is undecidable (a direct corollary of Rice's theorem), so "the app still works the same" cannot be verified in general. But you rarely need full equivalence — you need equivalence *with respect to a fixed, finite set of observations*. Pinning behavior to a decidable relation — a fixed test suite passing plus identical recorded I/O over the public interface on a fixed corpus — yields a relation checkable in bounded time. It is sound for the transformations you apply and incomplete (two genuinely equivalent programs may be judged different), which is the safe direction.

**Incorrect (relies on undecidable full equivalence):**

```python
def safe_to_apply(refactor, program):
    return semantically_equivalent(program, refactor(program))   # UNDECIDABLE
```

**Correct (decidable observational relation over a fixed observation set O):**

```python
# ≈ over O = test suite S ∪ public-API I/O traces on corpus C.
# Bounded-time checkable; incomplete (may reject a valid refactor) but never accepts
# one that breaks an observed behavior.
def observationally_equivalent(program, candidate, O):
    return run_observations(candidate, O) == run_observations(program, O)

def safe_to_apply(refactor, program, O):
    return observationally_equivalent(program, refactor(program), O)
```

Strengthen ≈ by enlarging O — add property-based generators and recorded production traces — not by reasoning about equivalence abstractly. The strength of O *is* the strength of your behavior-preservation guarantee.

Reference: [Claessen & Hughes, "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs" (ICFP 2000)](https://dl.acm.org/doi/10.1145/351240.351266)
