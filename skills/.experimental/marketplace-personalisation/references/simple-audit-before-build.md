---
title: Audit Instrumentation Before Any Model Work
impact: HIGH
impactDescription: prevents building on broken telemetry
tags: simple, audit, instrumentation
---

## Audit Instrumentation Before Any Model Work

A model trained on incomplete or mislabelled events produces confident recommendations based on a distorted view of reality. Before any ranking improvement, run a concrete instrumentation audit: what fraction of sessions emit impressions? What fraction of bookings emit a completion event with the correct item ID? What fraction of dismissals are captured at all? A single hour of audit work often uncovers the bottleneck that a quarter of model work would have failed to address.

**Incorrect (assume the telemetry is correct and iterate on the model):**

```python
def start_next_experiment() -> None:
    solution_version = personalize.create_solution_version(
        solutionArn=SOLUTION_ARN,
        trainingMode="FULL",
    )
    deploy_campaign(solution_version)
```

**Correct (audit report blocks any model changes on failing coverage):**

```python
def start_next_experiment() -> None:
    audit = TelemetryAudit.run(window_days=14)
    assert audit.impression_coverage >= 0.95, audit.explain()
    assert audit.booking_completed_coverage >= 0.90, audit.explain()
    assert audit.dismissal_coverage >= 0.70, audit.explain()
    assert audit.request_id_join_rate >= 0.98, audit.explain()

    solution_version = personalize.create_solution_version(
        solutionArn=SOLUTION_ARN,
        trainingMode="FULL",
    )
    deploy_campaign(solution_version)
```

Reference: [Google — Rules of Machine Learning, Rule 2: First, Design and Implement Metrics](https://developers.google.com/machine-learning/guides/rules-of-ml)
