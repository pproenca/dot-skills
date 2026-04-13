---
title: Build Profile Features Incrementally on Each Interaction
impact: MEDIUM-HIGH
impactDescription: enables in-session preference learning without login
tags: profile, incremental, session-features
---

## Build Profile Features Incrementally on Each Interaction

An anonymous visitor reveals preferences with every scroll, click and dwell — but only if the system accumulates those signals into a live profile rather than treating every page as an isolated request. A visitor who clicks three listings in London, ignores a row in Paris, and dwells on a listing that accepts large dogs has told the system enough to rank the next page dramatically better than a cold-start global popularity list. The profile feature store should update on every event, expose the current feature vector to every downstream request, and mutate cheaply enough that every interaction refines the next recommendation.

**Incorrect (each page served from global popularity, clicks ignored):**

```python
def homefeed(request: Request) -> list[Listing]:
    return listings.top_by_global_popularity(limit=24)

def on_click(request: Request, listing_id: str) -> None:
    analytics.track("click", listing_id=listing_id)
```

**Correct (profile feature store updated on every event, read by next request):**

```python
def homefeed(request: Request) -> list[Listing]:
    features = profile_store.get(request.anon_session)
    return listings.rank_by_features(
        features=features,
        fallback="global_popularity",
        limit=24,
    )

def on_click(request: Request, listing_id: str) -> None:
    listing = listings.get(listing_id)
    profile_store.update(
        anon_session=request.anon_session,
        updates={
            "clicked_regions": {"append": listing.region},
            "clicked_price_tiers": {"append": listing.price_tier},
            "clicked_species_accepted": {"append": listing.species_accepted},
            "click_count": {"increment": 1},
            "last_active_at": {"set": datetime.utcnow()},
        },
    )
    analytics.track("click", listing_id=listing_id)
```

Reference: [Li, Chu, Langford, Schapire — A Contextual-Bandit Approach to Personalized News Article Recommendation (WWW 2010)](https://dl.acm.org/doi/10.1145/1772690.1772758)
