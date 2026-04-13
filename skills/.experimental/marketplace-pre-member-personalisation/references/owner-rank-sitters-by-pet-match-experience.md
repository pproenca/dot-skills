---
title: Rank Sitters by Experience with the Visitor's Pet Type
impact: CRITICAL
impactDescription: prevents feasibility-mismatch objection
tags: owner, matching, feasibility
---

## Rank Sitters by Experience with the Visitor's Pet Type

Matching-market research (Roth, *Who Gets What and Why*) shows that two-sided matching quality depends on both sides' acceptance probabilities, and visitor owners are making an implicit acceptance calculation during preview browsing — "would this sitter accept my specific pet?" A sitter profile that generically says "experienced with pets" does not answer that question for an owner whose dog is an elderly diabetic Great Dane. Ranking preview listings by the sitter's demonstrated experience with the visitor's pet type (species, breed class, age band, health flags) closes the feasibility question concretely and removes the single biggest pre-payment objection.

**Incorrect (ranking by global popularity ignores the visitor's pet type):**

```python
def preview_sitters(visitor: AnonVisitor, region: str) -> list[Sitter]:
    return sitters.query(
        region=region,
        sort=[("completed_stays", "desc")],
        limit=24,
    )
```

**Correct (ranking by demonstrated experience with the visitor's pet type):**

```python
def preview_sitters(visitor: AnonVisitor, region: str) -> list[Sitter]:
    pet_type = visitor.profile.get("pet_type") or visitor.profile.get("inferred_pet_type")
    if not pet_type:
        return sitters.query(region=region, sort=[("completed_stays", "desc")], limit=24)

    candidates = sitters.query(region=region, limit=200)
    return sorted(
        candidates,
        key=lambda s: (
            -s.completed_stays_for_pet_type(pet_type),
            -s.completed_stays_for_pet_size(pet_type.size_class),
            -s.average_rating,
        ),
    )[:24]
```

Reference: [Alvin Roth — Who Gets What and Why: The New Economics of Matchmaking and Market Design](https://www.hup.harvard.edu/books/9780544291133)
