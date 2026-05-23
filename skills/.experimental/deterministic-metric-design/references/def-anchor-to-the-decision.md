---
title: Anchor the Metric to the Decision It Will Drive
impact: HIGH
impactDescription: prevents orphan metrics that accrete and get misread
tags: def, decision, threshold, actionability
---

## Anchor the Metric to the Decision It Will Drive

A metric with no decision attached becomes a number people stare at and argue about; worse, an agent told to "optimize" an actionless metric has no defined good outcome and will chase the formula off a cliff. Define, with the metric, the decision it serves and the action its values trigger. That decision dictates the required precision and scale — and sometimes reveals you need a boolean check, not a metric at all.

**Incorrect (metric with no attached decision):**

```python
record_metric("tech_debt_score", compute_tech_debt(repo))
# Nothing consumes it. It trends; people debate the trend; no action is ever defined.
```

**Correct (decision and trigger defined alongside the metric):**

```python
# Decision: should the agent open a behavior-preserving reduction PR for this module?
# Trigger:  removable_redundancy_ratio > 0.15  AND  module is not frozen.
ratio = removable_redundancy_ratio(module)          # proxy defined in comp-*.md
if ratio > REDUCTION_THRESHOLD and not module.frozen:
    propose_reduction_pr(module)                     # the metric earns its keep here
```

The threshold (0.15) is now a calibratable knob with a meaning attached, not a vibe — and you know exactly what a more precise metric would buy you (fewer wrong-side-of-threshold decisions).

Reference: [Hubbard, *How to Measure Anything: Finding the Value of Intangibles in Business*](https://www.howtomeasureanything.com/)
