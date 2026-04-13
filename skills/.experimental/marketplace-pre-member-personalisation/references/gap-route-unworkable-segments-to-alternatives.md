---
title: Route Unworkable Segments to Alternatives, Not to Payment
impact: HIGH
impactDescription: prevents converting visitors who will churn
tags: gap, routing, lifetime-value
---

## Route Unworkable Segments to Alternatives, Not to Payment

A new sitter trying to book a listing in central Lisbon for the first week of August is running a losing trade — the competition is saturated, the lead time is wrong, and the profile is weakest. Paying this visitor into membership is worse than sending them away, because they will churn within weeks and the platform will own both a refund request and a bad word-of-mouth review. The right move on unworkable segments is to route the visitor to an alternative that they can actually succeed in — a nearby city, an off-season month, a less-competitive cohort — even if it means declining their current intent. Lifetime-value economics favour this trade across every published marketplace model.

**Incorrect (convert every visitor regardless of feasibility):**

```python
def on_search_intent(visitor: AnonVisitor, intent: SearchIntent) -> Response:
    return Response(
        paywall=True,
        cta="Become a member to apply",
        listing_preview=stays.search(intent)[:12],
    )
```

**Correct (feasibility gate routes unworkable segments to alternatives):**

```python
def on_search_intent(visitor: AnonVisitor, intent: SearchIntent) -> Response:
    feasibility = assess_feasibility(visitor=visitor, intent=intent)

    if feasibility.score >= 0.4:
        return Response(
            paywall=True,
            cta="Become a member to apply",
            listing_preview=stays.search(intent)[:12],
        )

    return Response(
        paywall=False,
        headline="These dates and destination are very hard for new sitters",
        reasoning=feasibility.reasons,
        alternatives=[
            {"label": alt.label, "description": alt.why_easier, "intent": alt.intent}
            for alt in feasibility.alternatives[:3]
        ],
        soft_cta="Try an alternative or keep looking",
    )
```

Reference: [Alvin Roth — Who Gets What and Why: The New Economics of Matchmaking and Market Design](https://www.hup.harvard.edu/books/9780544291133)
