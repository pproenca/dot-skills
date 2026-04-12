---
title: Alert on Decision-Triggering Metrics, Not Just Error Rates
impact: MEDIUM
impactDescription: enables early quality regression detection
tags: monitor, alerts, decision-triggers
---

## Alert on Decision-Triggering Metrics, Not Just Error Rates

Traditional alerting fires on error rates, timeouts and service unavailability — the catastrophic failure modes. Search quality regressions almost never show up as catastrophes; they show up as slow drifts that are invisible until booking rate moves weeks later. Alerts on decision-triggering metrics — a 20% rise in zero-result rate, a 15% rise in reformulation rate, a 5% drop in NDCG against a frozen golden set, a 30% rise in exposure Gini — fire hours or days earlier and give the team time to diagnose before damage spreads. The alert payload should include the gotchas.md pointer for the likely diagnosis.

**Incorrect (only infrastructure error rates alert):**

```python
alerts.create(name="search_error_rate", metric="search.5xx_rate", threshold=0.01)
alerts.create(name="search_latency_p99", metric="search.p99_ms", threshold=500)
```

**Correct (decision-triggering quality alerts alongside infrastructure ones):**

```python
alerts.create(name="search_error_rate", metric="search.5xx_rate", threshold=0.01)
alerts.create(name="search_latency_p99", metric="search.p99_ms", threshold=500)

alerts.create(
    name="zero_result_spike",
    metric="search.zero_result_rate",
    threshold=Threshold(value=0.12, direction="above", window="15m"),
    runbook="references/playbooks/improving.md#zero-result-spike",
)
alerts.create(
    name="reformulation_spike",
    metric="search.reformulation_rate_60s",
    threshold=Threshold(value=0.25, direction="above", window="1h"),
    runbook="references/playbooks/improving.md#reformulation-spike",
)
alerts.create(
    name="ndcg_regression",
    metric="search.ndcg_at_10_vs_baseline",
    threshold=Threshold(value=-0.05, direction="below", window="24h"),
    runbook="references/playbooks/improving.md#ndcg-regression",
)
```

Reference: [Google — Rules of Machine Learning, Rule 8: Know the Freshness Requirements](https://developers.google.com/machine-learning/guides/rules-of-ml)
