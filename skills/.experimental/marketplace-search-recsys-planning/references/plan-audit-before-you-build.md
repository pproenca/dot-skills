---
title: Audit Before You Build — Gate Work on Instrumentation Readiness
impact: HIGH
impactDescription: prevents building on broken telemetry
tags: plan, audit, instrumentation
---

## Audit Before You Build — Gate Work on Instrumentation Readiness

Any ranking, retrieval, or model work that begins before the telemetry is known-good is guaranteed to produce surprising online metrics that nobody can explain. The cheap fix is a one-hour audit at the start of every project: verify impression coverage, outcome coverage, request-ID join rate, zero-result capture, and reformulation detection. If coverage is below threshold, fix the telemetry first — the model work waits. This rule is the hardest to follow because it feels like a delay, but it is always faster than debugging mysterious online metrics two months later.

**Incorrect (project kick-off with no instrumentation audit):**

```python
def kickoff_project(project: str) -> None:
    create_jira_epic(project)
    schedule_design_review(project)
    allocate_engineers(project, headcount=3)
```

**Correct (audit gate blocks kick-off on failing coverage):**

```python
def kickoff_project(project: str) -> None:
    audit = run_telemetry_audit(window_days=30)
    required = {
        "impression_coverage": 0.95,
        "outcome_coverage": 0.90,
        "request_id_join_rate": 0.98,
        "zero_result_capture": 1.00,
        "reformulation_detection": 0.90,
    }
    failing = {
        key: (value, audit.get(key))
        for key, value in required.items()
        if audit.get(key, 0.0) < value
    }
    if failing:
        create_jira_epic(f"{project}-telemetry-fix", blockers=failing)
        return
    create_jira_epic(project)
    schedule_design_review(project)
```

Reference: [Google — Rules of Machine Learning, Rule 2: First, Design and Implement Metrics](https://developers.google.com/machine-learning/guides/rules-of-ml)
