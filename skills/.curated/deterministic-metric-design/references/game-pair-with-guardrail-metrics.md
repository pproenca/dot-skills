---
title: Pair Every Target With Guardrail Metrics
impact: MEDIUM
impactDescription: prevents unmeasured regressions when one metric is optimized
tags: game, guardrail, side-effects, reward-hacking
---

## Pair Every Target With Guardrail Metrics

Optimizing one metric degrades dimensions it does not measure — the "negative side effects" failure of reward design. A guardrail (counter-)metric makes the sacrifice visible and vetoable: reduce size, but not by dropping test coverage, exploding coupling, or breaking behavior. Without guardrails, an agent told to minimize one number will trade away everything that number ignores, and the single objective will look like a triumph while the system rots around it.

**Incorrect (single objective, unguarded side effects):**

```python
optimize(objective=lambda m: removable_redundancy(m))   # agent inlines everything;
# coupling explodes and the public API shifts — both invisible to this objective.
```

**Correct (objective plus hard guardrails):**

```python
GUARDRAILS = [
    lambda before, after: coverage(after) >= coverage(before),    # coverage non-decreasing
    lambda before, after: coupling(after) <= coupling(before),    # coupling not worsened
    lambda before, after: behavior_preserved(before, after, O),   # ≈ holds
]
def accept(before, after):
    return all(g(before, after) for g in GUARDRAILS) and size(after) < size(before)
```

Reference: [Amodei et al., "Concrete Problems in AI Safety" (2016) — avoiding negative side effects & reward hacking](https://arxiv.org/abs/1606.06565)
