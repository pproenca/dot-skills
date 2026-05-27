---
title: Reject Improvements That Violate the Construct's Invariants
impact: MEDIUM
impactDescription: prevents the optimizer from buying invariant violations with score
tags: game, constraints, soft-penalty, invariants
---

## Reject Improvements That Violate the Construct's Invariants

The strongest anti-gaming defense is a hard constraint the optimizer cannot trade against. A soft penalty (`score − λ·violations`) can always be outweighed by a large enough raw gain, so a determined optimizer will simply buy violations with score. If a size reduction that breaks observational equivalence is unacceptable, it must be rejected outright — gate first, then score — so the construct's invariant is never on the bargaining table.

**Incorrect (soft penalty the optimizer can outbid):**

```python
score = nodes_removed - LAMBDA * tests_failing   # agent learns to fail a few tests for many removals
```

**Correct (gate, then score — the invariant is inviolable):**

```python
def score(before, after, O):
    if not behavior_preserved(before, after, O):   # gate: a broken behavior is not a candidate
        return REJECT                              # cannot be bought back by any number of removals
    return nodes_removed(before, after)            # only ≈-preserving changes are even scored
```

The gate also keeps the metric a sound lower bound on real reducibility (see `comp-design-a-proxy-with-a-proven-error-direction`): every accepted change is genuinely behavior-preserving.

Reference: [Amodei et al., "Concrete Problems in AI Safety" (2016) — reward hacking](https://arxiv.org/abs/1606.06565)
