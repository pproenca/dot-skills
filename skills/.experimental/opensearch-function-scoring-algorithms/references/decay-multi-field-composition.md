---
title: Compose Multi-Field Decay with Explicit Weights
impact: MEDIUM-HIGH
impactDescription: prevents one decay dimension from dominating
tags: decay, multi-field, composition, weights, geo, date
---

## Compose Multi-Field Decay with Explicit Weights

Marketplace queries are multi-dimensional: an Airbnb search has a *location* AND *dates*; a DoorDash search has a *location* AND *time-of-day demand*. Each dimension needs its own decay function. Default composition (`multiply`) silently lets one dimension dominate — a far-but-perfect-date listing gets crushed by distance, a near-but-wrong-date one survives. Explicit weights let you express "distance and date are equally important," "distance matters 2× more than date," etc.

**Incorrect (multiple decays without explicit weights — one signal dominates):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "type": "apartment" } },
      "functions": [
        {
          "gauss": {
            "location": { "origin": "38.71,-9.13", "scale": "5km", "decay": 0.5 }
          }
        },
        {
          "gauss": {
            "available_until": { "origin": "2026-08-15", "scale": "7d", "decay": 0.5 }
          }
        }
      ],
      "score_mode": "multiply",
      "boost_mode": "multiply"
    }
  }
}
```

A perfectly available listing 50km away: geo ≈ 0.0001, date = 1.0; product = 0.0001. Effectively excluded.
A nearby listing available 60d off: geo = 0.99, date ≈ 0.001; product = 0.001. Also excluded.

Both should be in results with different rankings, but `multiply` zeros them.

**Correct (`weighted_sum` of geometric components — weights explicit):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "type": "apartment" } },
      "functions": [
        {
          "weight": 0.6,
          "gauss": {
            "location": { "origin": "38.71,-9.13", "offset": "1km", "scale": "4km", "decay": 0.5 }
          }
        },
        {
          "weight": 0.4,
          "gauss": {
            "available_until": { "origin": "2026-08-15", "offset": "1d", "scale": "6d", "decay": 0.5 }
          }
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

`score_mode: sum` with weights gives a convex combination of decays — neither dimension can zero the other out, and the weights are interpretable as "60% distance, 40% date."

**Or use `script_score` for explicit Painless formula:**

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "type": "apartment" } },
      "script": {
        "source": """
          double distKm = doc['location'].arcDistance(params.lat, params.lon) / 1000;
          double distScore = Math.exp( -0.5 * Math.pow(Math.max(0, distKm - 1.0) / 4.0, 2) );

          long dayDiff = Math.abs(ChronoUnit.DAYS.between(
              doc['available_until'].value.toInstant(),
              ZonedDateTime.parse(params.target_date).toInstant()
          ));
          double dateScore = Math.exp( -0.5 * Math.pow(Math.max(0, dayDiff - 1) / 6.0, 2) );

          return _score * (0.6 * distScore + 0.4 * dateScore);
        """,
        "params": { "lat": 38.71, "lon": -9.13, "target_date": "2026-08-15T00:00:00Z" }
      }
    }
  }
}
```

**Calibrating weights:** Weights should sum to 1.0 for interpretability. Tune them on a graded judgment set or via online A/B testing — no closed-form solution exists. Starting points by query archetype: city break = 70% date / 30% location; specific neighborhood = 60% location / 40% date; flexible-date getaway = 80% location / 20% date.

**When `multiply` is right anyway:** If both dimensions are hard requirements (must be near AND must be available), then `multiply` correctly zeros out failures. Use it deliberately, not by default.

Reference: [OpenSearch function_score score_mode](https://opensearch.org/docs/latest/query-dsl/compound/function-score/) · [Painless date helpers](https://opensearch.org/docs/latest/api-reference/script-apis/)
