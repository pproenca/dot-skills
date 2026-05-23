---
title: Name the Latent Construct Before Writing Any Formula
impact: CRITICAL
impactDescription: prevents measuring a convenient proxy and calling it the property you care about
tags: def, construct, operationalization, validity
---

## Name the Latent Construct Before Writing Any Formula

A formula written before its construct is named measures whatever was easy to compute, and then gets *interpreted* as the thing you wanted — the gap between "lines containing TODO" and "technical debt" never gets examined because the construct was never stated. Naming the latent construct first (the unobservable property you actually care about) forces every later choice — indicators, scale, validation — to answer to it, and makes the eventual question "does this number track that property?" askable at all.

**Incorrect (formula first, construct only implied):**

```python
# "Code health score" — but health is never defined, so the weights are arbitrary
def code_health(module):
    return (0.4 * normalized(module.lines)
            + 0.3 * normalized(module.cyclomatic)
            + 0.3 * normalized(module.comment_ratio))
# What does 0.72 mean? Nobody can say — "health" was never tied to anything observable.
```

**Correct (construct named, then operationalized):**

```python
# Construct: change-failure risk — P(a change to this module introduces a defect).
# Each indicator is included because it is argued to relate to THAT probability.
def change_failure_risk(module):
    return logistic(
        B0
        + B1 * module.recent_churn         # more recent change → more risk
        + B2 * module.past_defect_density  # historically buggy → more risk
    )
# 0.72 now means an estimated 72% defect probability — a falsifiable claim.
```

**When NOT to over-formalize:**
- Exploratory dashboards where you are still discovering which construct matters can track raw indicators — but label them *indicators*, not a named metric, until the construct is fixed.

Reference: [Cronbach & Meehl, "Construct Validity in Psychological Tests" (1955)](https://psychclassics.yorku.ca/Cronbach/construct.htm)
