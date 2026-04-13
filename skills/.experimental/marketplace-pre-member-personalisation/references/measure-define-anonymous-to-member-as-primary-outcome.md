---
title: Define Anonymous-to-Member Conversion as the Primary Outcome
impact: MEDIUM
impactDescription: prevents proxy-metric optimisation
tags: measure, north-star, conversion
---

## Define Anonymous-to-Member Conversion as the Primary Outcome

Kohavi's research on trustworthy online experiments shows that organisations that optimise proxy metrics (clicks, sessions, sign-ups) consistently drift away from the outcome that actually matters, and the fix is to define a single primary outcome at the start of every experiment and refuse to ship on proxy wins alone. For pre-member personalisation, the only outcome that matters is whether the visitor becomes a paying member. Page views, clicks, time-on-site and even registrations are inputs — useful for diagnosis but not for ship decisions. Every pre-member experiment should declare "anonymous-to-member conversion" as the primary metric and treat everything else as a diagnostic.

**Incorrect (proxy metric treated as ship criterion):**

```python
def evaluate_experiment(experiment: Experiment) -> Decision:
    metrics = experiment.metrics()
    if metrics["click_through_rate"].treatment > metrics["click_through_rate"].control:
        return Decision.SHIP
    return Decision.KILL
```

**Correct (primary outcome is conversion, proxies are diagnostics):**

```python
def evaluate_experiment(experiment: Experiment) -> Decision:
    metrics = experiment.metrics()
    primary = metrics["anonymous_to_member_conversion"]

    if primary.p_value >= 0.05:
        return Decision.INCONCLUSIVE
    if primary.relative_lift < 0.01:
        return Decision.KILL
    if any_guardrail_regressed(metrics, guardrails=["registration_rate", "session_success"]):
        return Decision.INVESTIGATE
    return Decision.SHIP
```

Reference: [Kohavi, Tang, Xu — Trustworthy Online Controlled Experiments](https://experimentguide.com/)
