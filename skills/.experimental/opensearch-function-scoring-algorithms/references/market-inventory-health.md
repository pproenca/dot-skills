---
title: Penalize Listings with Low Inventory Health
impact: MEDIUM-HIGH
impactDescription: prevents user dead-ends on unavailable inventory
tags: market, inventory, availability, instant-book, health
---

## Penalize Listings with Low Inventory Health

A listing that's "available" but with a tiny availability window, slow host response, or low acceptance rate is functionally dead inventory — the user clicks, requests, and gets nothing. Ranking these alongside high-availability listings wastes user attention and erodes trust in search. Bake an "inventory health" composite signal into ranking: availability density (% of dates in next 90 days actually open), instant-book toggle, response time, acceptance rate.

**Incorrect (only filter `available=true` — surfaces functionally dead inventory):**

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "city": "lisbon" } }],
      "filter": [
        { "term": { "available_today": true } }
      ]
    }
  }
}
```

A listing with `available_today: true` but `availability_90d: 0.05` (5% of nights open) and `response_time_hours: 24` has near-zero booking probability.

**Correct (inventory-health rank feature, computed offline):**

```python
def inventory_health(listing):
    """Composite [0, 1] score from inventory liquidity signals."""
    availability_density = listing.open_nights_next_90d / 90  # 0-1
    response_quality = max(0, 1 - listing.avg_response_hours / 24)  # 0 at 24h+
    acceptance = listing.accept_rate_30d  # 0-1
    instant_book_bonus = 1.0 if listing.instant_book else 0.85

    return (
        0.4 * availability_density
        + 0.3 * response_quality
        + 0.3 * acceptance
    ) * instant_book_bonus
```

Index as `rank_feature`:

```json
PUT /listings/_mapping
{
  "properties": {
    "market": {
      "properties": {
        "inventory_health": { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

Apply in ranking with `sigmoid` (there's a meaningful threshold below which inventory is "dead"):

```json
{
  "query": {
    "bool": {
      "must":   [{ "match": { "city": "lisbon" } }],
      "filter": [{ "term": { "available_today": true } }],
      "should": [
        {
          "rank_feature": {
            "field": "market.inventory_health",
            "sigmoid": { "pivot": 0.4, "exponent": 4 }
          }
        }
      ]
    }
  }
}
```

**Why sigmoid with pivot=0.4:** Pivot defines "minimum viable inventory health." Below 0.4 the sigmoid drops sharply (this listing is dead inventory); above 0.4 it climbs gently to 1.0. The shape captures "below threshold = bad; above threshold, marginal improvements matter less."

**Use as a hard gate at extreme low values:** For listings with `inventory_health < 0.15`, exclude from recall entirely. The score-time penalty alone isn't enough — they still show up at the bottom of results, frustrating users who scroll.

**Recompute on a schedule:** Inventory health is dynamic — a host who responds to today's request improves the signal. Recompute nightly; for instant-book and availability_density, recompute on inventory-change events for near-real-time freshness.

**Why this matters for both sides of the marketplace:** Surfacing dead inventory wastes buyer time AND demoralizes sellers who get window-shopping inquiries without bookings. Ranking by inventory health protects both sides.

Reference: [DoorDash — Real-Time Eligibility in Marketplace Search](https://www.shaped.ai/blog/marketplace-search-architecture-why-real-time-eligibility-breaks-every-retrieval-vendor) · [Airbnb Tech — Inventory and conversion signals](https://airbnb.tech/)
