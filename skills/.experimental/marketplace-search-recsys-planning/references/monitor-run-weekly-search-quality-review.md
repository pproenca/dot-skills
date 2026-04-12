---
title: Run a Weekly Search-Quality Review Ritual
impact: MEDIUM
impactDescription: enables calendar-driven decision making
tags: monitor, ritual, review
---

## Run a Weekly Search-Quality Review Ritual

Incident-driven quality reviews (the team meets when something breaks) are too late — by then the regression has been live for days. Calendar-driven weekly reviews are the structural fix: a 30-minute meeting every Monday where the team walks through the dashboard, the decisions log updated since last week, new gotchas captured from the last incident, and the top five queries with the largest zero-result, reformulation, or NDCG deltas. The review produces a set of tickets for the week's work, or an explicit "no action needed" decision that gets recorded.

**Incorrect (ad-hoc review only when an alarm fires):**

```python
def on_alert_fired(alert: Alert) -> None:
    slack.post(f"Alert: {alert.name}")
    oncall_engineer.page()
```

**Correct (weekly review scheduled, structured artefact produced):**

```python
def weekly_search_quality_review(week_start: date) -> ReviewArtefact:
    return ReviewArtefact(
        week_start=week_start,
        dashboard_snapshot=dashboard.snapshot(),
        new_decisions=decisions_log.entries_since(week_start - timedelta(days=7)),
        new_gotchas=gotchas_file.entries_since(week_start - timedelta(days=7)),
        top_5_degraded_queries=query_log.top_degraded(metric="zero_result", k=5),
        top_5_degraded_rankings=offline_eval.top_degraded_queries(golden_set.current(), k=5),
        actions=team_decides(),
    )
```

Reference: [Google — Rules of Machine Learning, Rule 27: Try to Quantify Observed Undesirable Behavior](https://developers.google.com/machine-learning/guides/rules-of-ml)
