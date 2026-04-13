---
title: Display Acceptance Rate for the Visitor's Profile Shape
impact: HIGH
impactDescription: prevents unrealistic expectations on rare-profile visitors
tags: gap, acceptance-rate, feasibility
---

## Display Acceptance Rate for the Visitor's Profile Shape

Acceptance rates on a trust marketplace are not uniform across profile shapes. An owner with a low-maintenance cat and flexible dates has a dramatically higher sitter acceptance rate than an owner with an elderly diabetic Great Dane that needs insulin twice daily and a fenced garden. An established sitter with ten reviews has a dramatically higher owner acceptance rate than a new sitter with none. Showing the visitor their cohort's acceptance rate pre-payment lets them set correct expectations and either adjust their profile (relax a constraint, add credentials) or accept the reality — both of which are better outcomes than paying and being blindsided.

**Incorrect (no acceptance-rate context shown before membership commitment):**

```python
def membership_cta(visitor: AnonVisitor) -> CallToAction:
    return CallToAction(
        headline="Join now and start sitting",
        cta_label="Become a member",
        price="£129/year",
    )
```

**Correct (cohort-specific acceptance rate with adjustment suggestions):**

```python
def membership_cta(visitor: AnonVisitor) -> CallToAction:
    cohort = classify_visitor_cohort(visitor)
    acceptance = analytics.acceptance_rate_for_cohort(cohort)

    headline = f"Join now and start sitting"
    caveat = None
    suggestion = None

    if acceptance.rate < 0.35:
        caveat = (
            f"Members with profiles like yours ({cohort.label}) have about a "
            f"{int(acceptance.rate * 100)}% acceptance rate on typical applications."
        )
        suggestion = cohort.top_adjustment_to_improve_acceptance()

    return CallToAction(
        headline=headline,
        caveat=caveat,
        improvement_suggestion=suggestion,
        cta_label="Become a member",
        price="£129/year",
    )
```

Reference: [Real-time Personalization using Embeddings for Search Ranking at Airbnb (KDD 2018)](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
