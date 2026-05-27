---
title: Prove Composability Before Aggregating, or Disclaim It
impact: MEDIUM-HIGH
impactDescription: prevents invalid system-level totals from non-additive metrics
tags: prop, composability, additivity, aggregation
---

## Prove Composability Before Aggregating, or Disclaim It

Rolling module-level metrics up to a system number assumes a composition law — usually additivity. Many metrics are not additive: the coupling of a system is not the sum of its modules' couplings (cross-module edges are shared and would be double-counted), and a ratio of ratios is meaningless. Either prove the composition law you rely on, or refuse to aggregate and report the distribution instead. Summing a non-additive metric produces a confident, wrong system number that nobody questions because it has a single tidy value.

**Incorrect (summing a non-additive metric):**

```python
system_coupling = sum(coupling(m) for m in modules)   # double-counts shared edges; unbounded nonsense
```

**Correct (additive metric summed; non-additive metric kept as a distribution):**

```python
# The cyclomatic number is additive over disjoint control-flow graphs, so decision points compose:
system_decisions = sum(decision_points(m) for m in modules)     # valid aggregation
# Coupling is NOT additive → do not sum it; report the distribution and act per-module.
coupling_dist = {m.name: coupling(m) for m in modules}          # see agg-respect-scale-in-aggregation.md
```

Reference: [Briand, Morasca & Basili, "Property-Based Software Engineering Measurement," *IEEE TSE* 22(1) (1996) — additivity](https://doi.org/10.1109/32.481535)
