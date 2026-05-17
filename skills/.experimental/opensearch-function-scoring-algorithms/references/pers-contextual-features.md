---
title: Inject Contextual Features into script_score
impact: MEDIUM-HIGH
impactDescription: 2-5% conversion lift from device/time/location context
tags: pers, context, device, time, script-score
---

## Inject Contextual Features into script_score

Contextual signals (device type, hour-of-day, day-of-week, search-time location) are cheap to capture and meaningfully shift relevance. A user searching at 11pm from a mobile device for "ramen" wants different results than the same user at noon from a laptop. These features don't belong in the item tower (they're user-state) or query tower (they need to interact with item features at score time) — they belong in `script_score` as runtime parameters.

**Incorrect (ignores context — same ranking regardless of device/time):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "name": "ramen" } },
      "functions": [
        { "rank_feature": { "field": "popularity", "saturation": { "pivot": 50 } } }
      ]
    }
  }
}
```

**Correct (`script_score` with context-conditional features):**

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "name": "ramen" } },
      "script": {
        "source": """
          double base = _score;

          // Mobile users prefer near, fast-loading, easy-to-find places
          double distKm = doc['location'].arcDistance(params.lat, params.lon) / 1000;
          double mobileNearBoost = params.is_mobile ? Math.exp(-distKm / 2.0) : 1.0;

          // Late-night searches prefer 24h-open places
          double lateNightBoost = (params.hour >= 22 || params.hour < 4)
              ? (doc['open_24h'].value ? 1.5 : 0.7)
              : 1.0;

          // Weekend brunch searches prefer brunch-tagged places
          double brunchBoost = (params.day_of_week == 6 || params.day_of_week == 0)
              ? (doc['serves_brunch'].value ? 1.3 : 1.0)
              : 1.0;

          return base * mobileNearBoost * lateNightBoost * brunchBoost;
        """,
        "params": {
          "lat": 38.71, "lon": -9.13,
          "is_mobile": true,
          "hour": 23,
          "day_of_week": 5
        }
      }
    }
  }
}
```

**Context features that consistently move conversion:**

| Feature | Why it matters |
|---------|---------------|
| `is_mobile` | Mobile sessions favor near, fast, easy choices |
| `hour_of_day` | Time-of-day demand patterns (breakfast/lunch/dinner; late-night) |
| `day_of_week` | Weekday vs weekend behavioral split |
| `device_type` | Tablet ≠ phone ≠ laptop browsing patterns |
| `os` | iOS vs Android demographic differences |
| `connection_speed` | Slow connections favor faster-loading / closer items |
| `recently_viewed_category` | Reinforce current intent |
| `weather` | Outdoor venues, weather-sensitive categories |

**Why this beats baking context into the query tower:** Context features interact multiplicatively with *item* features (mobile × distance, late-night × 24h-open). The two-tower architecture can't model cross-tower interactions at the kNN stage — they have to come at the rescore/script_score stage where both sides are available.

**Latency:** Painless scripts compile once and run JIT'd. Adding 5-10 multiplicative contextual factors typically adds <5ms to a rescore phase on 500 documents.

Reference: [OpenSearch script_score query](https://opensearch.org/docs/latest/query-dsl/specialized/script-score/) · [Painless geo functions](https://opensearch.org/docs/latest/api-reference/script-apis/exec-script/)
