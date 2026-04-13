---
title: Show Stay Inventory in the Sitter's Target Destination
impact: HIGH
impactDescription: prevents generic-inventory disappointment
tags: sitter, inventory, specificity
---

## Show Stay Inventory in the Sitter's Target Destination

Airbnb's research on search ranking (KDD 2018) shows that location-specific supply is the single biggest driver of traveller conversion — a visitor searching for Lisbon does not care that the platform has 10,000 stays globally; they care whether there are stays in Lisbon for their dates. Pet sitters behave the same way. A new sitter thinking about Lisbon will convert on "12 stays in Lisbon for July dates" and will not convert on "hundreds of sitting opportunities worldwide". Extract the target destination from the inferred profile (URL path, referred search term, explicit onboarding answer) and show inventory in that specific geography, not a global proxy.

**Incorrect (global inventory count shown to every sitter visitor):**

```python
def sitter_landing(visitor: AnonVisitor) -> SitterLanding:
    return SitterLanding(
        hero_count=f"Over {stays.total_global()} stays worldwide",
        preview=stays.popular_global(limit=12),
    )
```

**Correct (target-destination inventory with honest count and dates):**

```python
def sitter_landing(visitor: AnonVisitor) -> SitterLanding:
    target = visitor.profile.get("target_destinations") or infer_target_from_entry(visitor)
    if not target:
        return SitterLanding(
            hero_prompt="Where are you hoping to travel?",
            preview=[],
            show_destination_chooser=True,
        )

    period = visitor.profile.get("target_period") or next_6_months()
    available = stays.query(destination=target, during=period, accepts_new_sitters=True)

    return SitterLanding(
        hero_count=f"{len(available)} stays in {target} between {period.label}",
        preview=available[:12],
        honest_caveat=(
            f"{len(available)} stays for new sitters. Established sitters see more."
            if len(available) < 20 else None
        ),
    )
```

Reference: [Real-time Personalization using Embeddings for Search Ranking at Airbnb (KDD 2018)](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
