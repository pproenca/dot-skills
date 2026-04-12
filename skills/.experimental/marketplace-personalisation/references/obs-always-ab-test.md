---
title: Always A/B Test, Never Before-and-After
impact: MEDIUM-HIGH
impactDescription: prevents confounding with seasonality
tags: obs, ab-testing, causal
---

## Always A/B Test, Never Before-and-After

A before-and-after comparison conflates the change under test with every other thing that happened in the same window — seasonality, marketing campaigns, population shifts, supply changes, bug fixes. Only a randomised A/B split gives a causal estimate of the change's effect. Before-and-after is the most common source of "we shipped a model and booking rate went up 4%" claims that turn out to be coincidence when an A/B test is eventually run.

**Incorrect (before-and-after comparison against last week):**

```python
def evaluate_new_model(model: str) -> Report:
    this_week = metrics.fetch(
        model=model,
        start=date.today() - timedelta(days=7),
        end=date.today(),
    )
    last_week = metrics.fetch(
        model="previous_production",
        start=date.today() - timedelta(days=14),
        end=date.today() - timedelta(days=7),
    )
    return Report(
        lift=(this_week.booking_rate - last_week.booking_rate) / last_week.booking_rate,
    )
```

**Correct (randomised A/B with control and treatment in the same window):**

```python
def evaluate_new_model(treatment_model: str, control_model: str) -> Report:
    experiment = experiments.create(
        name=f"compare-{treatment_model}-vs-{control_model}",
        variants={"control": control_model, "treatment": treatment_model},
        allocation={"control": 0.5, "treatment": 0.5},
        primary_metric="booking_completed_per_session",
    )
    return experiment.wait_for_significance(
        min_sample_size=40_000,
        max_p_value=0.05,
    )
```

Reference: [Trustworthy Online Controlled Experiments (Kohavi, Tang, Xu)](https://experimentguide.com/)
