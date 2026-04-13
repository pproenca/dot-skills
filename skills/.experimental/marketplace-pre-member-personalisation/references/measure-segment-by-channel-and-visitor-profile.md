---
title: Segment Conversion Measurement by Channel and Visitor Profile
impact: MEDIUM
impactDescription: prevents aggregate-masked segment regressions
tags: measure, segmentation, simpsons-paradox
---

## Segment Conversion Measurement by Channel and Visitor Profile

Aggregate conversion rates hide segment-level reality with alarming regularity — organic search visitors might convert at 8% while paid social visitors convert at 2%, and a blended 4% number tells the team nothing about where to invest. Simpson's paradox is routine in pre-member experiments: an intervention that lifts aggregate conversion 3% might lift organic 5% and drop paid social 1%, and a team optimising aggregate misses both facts. Slicing every primary metric by acquisition channel, inferred role, target destination and visitor cohort surfaces the real drivers and prevents ship decisions that are right on average and wrong in specifics.

**Incorrect (aggregate conversion rate is the only number tracked):**

```python
def weekly_conversion() -> dict:
    return {
        "anonymous_to_member_rate": analytics.conversion_rate(
            event_a="page_view",
            event_b="membership_activated",
            window_days=30,
        ),
    }
```

**Correct (segmented by channel, role, target and cohort):**

```python
def weekly_conversion() -> dict:
    segments = {
        "overall": {},
        "by_channel": ["organic_search", "paid_social", "paid_search", "referral", "direct"],
        "by_role": ["owner", "sitter", "both", "unknown"],
        "by_target": ["local", "european", "international", "unknown"],
        "by_cohort": ["first_session", "returning_anonymous", "registered_not_paid"],
    }
    results: dict = {}
    for axis, values in segments.items():
        if not values:
            results[axis] = analytics.conversion_rate(event_a="page_view", event_b="membership_activated")
            continue
        results[axis] = {
            value: analytics.conversion_rate(
                event_a="page_view",
                event_b="membership_activated",
                filter={axis.replace("by_", ""): value},
            )
            for value in values
        }
    return results
```

Reference: [Kohavi, Tang, Xu — Trustworthy Online Controlled Experiments](https://experimentguide.com/)
