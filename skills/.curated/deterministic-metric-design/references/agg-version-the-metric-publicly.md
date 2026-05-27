---
title: Version and Changelog the Metric for Its Consumers
impact: LOW-MEDIUM
impactDescription: prevents broken cross-consumer comparisons across definition changes
tags: agg, versioning, changelog, adoption
---

## Version and Changelog the Metric for Its Consumers

Once others depend on a metric, a silently changed definition breaks their dashboards and invalidates their historical comparisons without warning. Treat the definition as a public interface: version it with semver, keep a changelog, mark any change that shifts existing values as a major bump, and either recompute history or label the discontinuity — so a trend spanning the change is not misread as real movement. This is the consumer-facing twin of recording provenance per value (`det-version-and-record-the-toolchain`).

**Incorrect (silent redefinition):**

```python
# Tweak the formula, redeploy. Every consumer's trend line jumps overnight; nobody knows why.
def churn_risk(m):
    return new_formula(m)
```

**Correct (versioned, changelogged, discontinuity marked):**

```python
# CHANGELOG: churn_risk 2.0.0 — denominator now size-weighted (BREAKING; values shift down).
CHURN_RISK_VERSION = "2.0.0"
emit(value=churn_risk(m), version=CHURN_RISK_VERSION)   # consumers compare only within a major version
```

Reference: [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
