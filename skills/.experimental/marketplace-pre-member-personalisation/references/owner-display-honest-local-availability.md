---
title: Display Honest Local Availability, Not Inflated Global Counts
impact: CRITICAL
impactDescription: prevents post-payment expectancy violation
tags: owner, liquidity, honesty
---

## Display Honest Local Availability, Not Inflated Global Counts

Expectancy-violation research (Burgoon 1993) and the broader literature on consumer trust show that discovering a service is worse than advertised after payment burns trust more severely than the equivalent disappointment before payment. An owner who pays for membership expecting "hundreds of sitters in your area" and finds four is not just disappointed — they feel deceived, and the churn rate on expectation-violated cohorts runs 2-3× the baseline. Showing honest local availability pre-payment costs some conversions but dramatically improves first-year retention, which is what drives lifetime value on a subscription marketplace.

**Incorrect (global count shown to every visitor regardless of their location):**

```python
def trust_bar(request: Request) -> TrustBar:
    return TrustBar(
        headline="Over 200,000 trusted sitters worldwide",
        secondary=f"Join {platform.total_owners} members today",
    )
```

**Correct (honest local availability against the visitor's region and dates):**

```python
def trust_bar(request: Request) -> TrustBar:
    geo = request.profile.geoip_region
    period = request.profile.inferred_travel_window or next_60_days()

    local = sitters.active_in(
        region=geo,
        available_during=period,
        accepting_new_owners=True,
    )

    if len(local) >= 20:
        return TrustBar(headline=f"{len(local)} sitters available in {geo} for your dates")
    if len(local) >= 5:
        return TrustBar(headline=f"{len(local)} sitters active in {geo} — limited availability, book early")
    return TrustBar(
        headline=f"{len(local)} sitters active in {geo}",
        alternatives=nearby_regions_with_more_supply(geo, period, limit=3),
        honest_warning="Supply is thin for your dates. Consider flexible dates or nearby areas.",
    )
```

Reference: [Burgoon — Interpersonal Expectations, Expectancy Violations, and Emotional Communication](https://www.tandfonline.com/doi/abs/10.1080/08934219309367485)
