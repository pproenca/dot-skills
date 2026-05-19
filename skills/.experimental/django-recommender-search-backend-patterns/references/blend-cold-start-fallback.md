---
title: Fall Back to Popular/Editorial on Cold-Start
impact: HIGH
impactDescription: prevents empty recommendations for new users
tags: blend, cold-start, fallback, recommender, new-user
---

## Fall Back to Popular/Editorial on Cold-Start

Personalize, affinity models, and embedding-based recommenders all need user history to produce good results. A brand-new user (registered minutes ago, no interactions) gets either an empty response, garbage results, or a "no recommendations" error. The cold-start path matters: this is the user's first impression of your product.

Detect cold-start at request time, swap in a deterministic fallback (popular items, editorial picks, trending), and gradually fade in personalized results as the user accumulates interactions. Track when each source is reliable for the user — don't ship personalization that's worse than popular items.

**Incorrect (no cold-start handling — empty or low-quality results):**

```python
async def get_recommendations(user_id: str):
    items = await personalize_client.get_recommendations(user_id)
    return items
# New user with no history → Personalize returns [] or random items
# User sees empty page or random products and bounces
```

**Correct (detect cold-start, blend with popular fallback):**

```python
async def get_recommendations(user_id: str):
    user_state = await get_user_state(user_id)  # interaction_count, signup_age_days

    is_cold = (
        user_state.interaction_count < 5
        or user_state.signup_age_days < 1
    )

    if is_cold:
        # Pure fallback for the coldest users
        return {
            "items": await get_popular_items(segment=user_state.segment or "default"),
            "source": "popular",
            "personalized": False,
        }

    # Warm enough — call personalization
    try:
        personalized = await personalize_client.get_recommendations(user_id)
        if len(personalized) < 5:
            # Personalization returned too few — blend in popular to fill
            popular = await get_popular_items(segment=user_state.segment)
            blended = blend_dedup(
                {"personalize": personalized, "popular": popular},
                weights={"personalize": 0.7, "popular": 0.3},
            )
            return {"items": blended[:20], "source": "blended", "personalized": True}
        return {"items": personalized[:20], "source": "personalize", "personalized": True}
    except Exception:
        # Failure also = use fallback
        return {
            "items": await get_popular_items(segment=user_state.segment or "default"),
            "source": "popular_fallback",
            "personalized": False,
        }
```

**Tiered fallback (increasing personalization with user maturity):**

```python
def get_personalization_strategy(user_state) -> dict:
    """Returns weight distribution across sources based on user maturity."""
    if user_state.interaction_count < 3:
        # Brand new — pure popular
        return {"popular": 1.0}
    if user_state.interaction_count < 20:
        # Some signal — mostly popular, sprinkle personalized
        return {"popular": 0.6, "personalize": 0.4}
    if user_state.interaction_count < 100:
        # Established — primarily personalized, anchor with popular
        return {"personalize": 0.7, "affinity": 0.2, "popular": 0.1}
    # Power user — full personalization
    return {"personalize": 0.5, "affinity": 0.3, "databricks": 0.2}
```

**Cache the popular fallback aggressively (it's the same for everyone in a segment):**

```python
# Per-segment popular items — refreshed every hour, served from Redis on every request
@cached_with_stampede(ttl_seconds=3600, key_template="popular:{segment}")
async def get_popular_items(segment: str) -> list[dict]:
    body = {
        "query": {"bool": {"filter": [{"term": {"segment": segment}}]}},
        "size": 50,
        "sort": [{"popularity_score": "desc"}],
        "_source": ["id", "title", "thumbnail_url", "price"],
    }
    return [hit["_source"] for hit in opensearch.search(index="products_live", body=body)["hits"]["hits"]]
```

**Diversify the popular fallback (don't show every cold user the same 20 items):**

```python
def shuffle_with_seed(items: list, seed: str, top_keep: int = 3) -> list:
    """Keep top-N pinned, shuffle the rest with a stable per-user seed."""
    import random
    rng = random.Random(seed)
    pinned = items[:top_keep]
    rest = items[top_keep:]
    rng.shuffle(rest)
    return pinned + rest

# For cold users, give each a stable but varied view
items = shuffle_with_seed(await get_popular_items(segment="default"), seed=user_id)
```

**Editorial fallback for high-stakes domains:**

For domains where "popular" is the wrong default (a news site shouldn't show yesterday's headlines to a new user), use editorial curation:

```python
async def get_editorial_picks(segment: str) -> list[dict]:
    """Hand-curated by editors. Updated daily."""
    return await editorial_client.get_homepage_picks(segment=segment)

# Cold path becomes:
if is_cold:
    items = await get_editorial_picks(segment=user_state.segment)
```

**Track the fallback usage:**

```python
# Emit metrics so you can monitor cold-start ratio
metrics.increment("recommendations.served", tags={"strategy": response["source"]})
# Examples in production:
#   recommendations.served{strategy=popular}: 12%   ← cold users
#   recommendations.served{strategy=blended}: 24%   ← warming up
#   recommendations.served{strategy=personalize}: 64% ← warm
```

If cold-fallback is firing too often (e.g., 40%+), check:
- Is your interaction-tracking pipeline lagged? Users may have interactions you're not seeing yet
- Is your "cold" threshold too aggressive?
- Are returning users hitting cold-start due to identity-resolution gaps?

**Symptom of missing cold-start handling:**
- High bounce rate on first-time users
- Personalize/Databricks errors for cold users not handled gracefully
- "We have new-user retention problems" — the recommendation page might be empty for new users

Reference: [Netflix — Cold-start in recommendation](https://research.netflix.com/research-area/recommendations) | [AWS Personalize — Cold-start](https://docs.aws.amazon.com/personalize/latest/dg/getting-real-time-recommendations.html#user-personalization-cold-start)
