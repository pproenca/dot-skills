---
title: Make the Metric a Pure Function of Declared Inputs
impact: HIGH
impactDescription: prevents irreproducible scores from hidden time, network, or globals
tags: det, purity, reproducibility, side-effects
---

## Make the Metric a Pure Function of Declared Inputs

Any dependence on wall-clock time, environment variables, network calls, or global mutable state makes a score irreproducible — and an irreproducible score cannot be an optimization target, because the agent cannot tell whether its change or the environment moved the number. Pass every input explicitly, including the reference time for any recency weighting, and forbid hidden I/O inside the metric. Purity is what lets you cache, parallelize, and trust the gradient.

**Incorrect (hidden time and network dependence):**

```python
def freshness(module):
    age_days = (datetime.now() - module.last_commit).days     # depends on WHEN you run it
    stars = github.get_repo(module.repo).stargazers_count     # depends on the network, today
    return weight(age_days, stars)
```

**Correct (pure function; all inputs declared):**

```python
def freshness(module, as_of: date, stars: int):
    age_days = (as_of - module.last_commit).days     # reference time is an explicit input
    return weight(age_days, stars)                   # no I/O, no globals → reproducible
```

Reference: [ACM, "Artifact Review and Badging" — reproducibility criteria](https://www.acm.org/publications/policies/artifact-review-and-badging-current)
