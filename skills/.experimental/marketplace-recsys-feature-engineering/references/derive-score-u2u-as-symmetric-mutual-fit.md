---
title: Score User-to-User Compatibility as Symmetric Mutual Fit
impact: MEDIUM-HIGH
impactDescription: prevents the 30-50% of requests that end in owner rejection
tags: derive, u2u, mutual-fit, symmetric, two-sided
---

## Score User-to-User Compatibility as Symmetric Mutual Fit

In a two-sided marketplace, a one-sided score ("this sitter scores 0.9 for this listing from the sitter's perspective") ignores whether the owner will accept, and produces requests that the owner rejects — both sides waste effort. The u2u compatibility score must be symmetric: `min(P(owner_accepts | sitter, listing), P(sitter_requests | sitter, listing))` or the product of the two, so that high scores require both sides to say yes. Train the two sides as independent classifiers (or a joint two-sided two-tower), and always compose before ranking.

**Incorrect (one-sided sitter-perspective score):**

```python
def u2u_score(sitter: Sitter, listing: Listing) -> float:
    return sitter_wants_this_listing_model.predict(sitter, listing)
    # high-scoring requests get rejected by the owner because the owner prefers someone else
```

**Correct (symmetric fit — both sides must want the match):**

```python
def u2u_score(sitter: Sitter, listing: Listing) -> float:
    p_sitter_requests = sitter_wants_model.predict(sitter, listing)
    p_owner_accepts = owner_accepts_model.predict(listing, sitter)
    # use min (strict bottleneck) or product (geometric combination)
    return min(p_sitter_requests, p_owner_accepts)

# For ranking the owner's shortlist: rank by p_owner_accepts AND require p_sitter_requests > threshold
def shortlist_sitters_for_owner(listing: Listing, pool: list[Sitter], top_k: int = 10) -> list[Sitter]:
    scored = [
        (s, owner_accepts_model.predict(listing, s))
        for s in pool
        if sitter_wants_model.predict(s, listing) > 0.4  # feasibility gate
    ]
    return [s for s, _ in sorted(scored, key=lambda x: -x[1])[:top_k]]
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
