---
title: Balance Supply and Demand per Segment
impact: HIGH
impactDescription: prevents segment liquidity collapse
tags: match, liquidity, segmentation
---

## Balance Supply and Demand per Segment

Marketplace liquidity is not uniform — some city-date segments are demand-heavy (dozens of seekers chasing three providers) while others are supply-heavy (providers with empty calendars). A global ranking strategy treats both identically and makes the wrong trade-off: in demand-heavy segments it over-diversifies and in supply-heavy segments it under-explores. Measuring per-segment supply/demand ratio and routing to different ranking strategies restores segment-level liquidity.

**Incorrect (one global ranking strategy for all segments):**

```python
def homefeed(seeker: Seeker, request: Request) -> list[Listing]:
    feasible = retrieve_feasible(seeker, request)
    return rank_default(seeker, feasible)[:24]
```

**Correct (segment-aware routing to different ranking strategies):**

```python
def homefeed(seeker: Seeker, request: Request) -> list[Listing]:
    feasible = retrieve_feasible(seeker, request)
    segment = (request.region, request.date_range.iso_week)
    ratio = liquidity.supply_demand_ratio(segment)

    if ratio < 0.5:  # demand-heavy — aggressive diversification
        return rank_with_exposure_caps(seeker, feasible, cap_per_provider=1)[:24]
    if ratio > 3.0:  # supply-heavy — explore cold providers
        return rank_with_exploration(seeker, feasible, explore_rate=0.2)[:24]
    return rank_default(seeker, feasible)[:24]
```

Reference: [Airbnb — Learning Market Dynamics for Optimal Pricing](https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3)
