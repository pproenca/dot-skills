---
title: Detect Reward-Hacking With Spot Audits and Drift Checks
impact: LOW-MEDIUM
impactDescription: prevents undetected reward-hacking from accumulating over time
tags: game, auditing, drift, campbells-law
---

## Detect Reward-Hacking With Spot Audits and Drift Checks

Even with guardrails and hard gates, optimizers find loopholes the designer did not foresee — Campbell's law warns that the more a quantitative indicator drives decisions, the more it gets gamed and the more it distorts what it was meant to measure. Treat the metric as needing ongoing surveillance: sample top-scoring changes for human review, and monitor the proxy↔outcome correlation over time. If the proxy keeps improving while the real outcome does not, it is being gamed and needs re-tightening.

**Incorrect (trust the metric indefinitely):**

```python
# Shipped six months ago; the score keeps rising; nobody has looked at WHAT raised it.
deploy_metric_optimizer(objective=removable_redundancy)
```

**Correct (audit sample + drift monitor):**

```python
sample = top_scoring_changes(n=20)
human_review(sample)                       # are these genuine improvements, or exploits?
drift = correlation(proxy_history, outcome_history)
if drift < DRIFT_FLOOR:                     # proxy and outcome have decoupled
    pause_and_retighten()                   # the metric is being gamed — fix before trusting it again
```

Reference: [Manheim & Garrabrant, "Categorizing Variants of Goodhart's Law" (2018)](https://arxiv.org/abs/1803.04585)
