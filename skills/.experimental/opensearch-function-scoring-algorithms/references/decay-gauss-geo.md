---
title: Use Gauss Decay for Geo Distance, Not Linear
impact: HIGH
impactDescription: prevents linear over-penalty within walking distance
tags: decay, gauss, geo, distance, function-score
---

## Use Gauss Decay for Geo Distance, Not Linear

Linear distance decay penalizes distance proportionally — a place 2km away scores half as much as one at 1km, and 4km scores zero. That's wrong for how users perceive distance: there's a "close enough" plateau where everything within the user's mental radius feels equivalent, then a sharp falloff. Gaussian decay models this directly: bell-shaped, plateau near origin, steep falloff after the `scale` distance. It's the default geo-decay function for Airbnb-style accommodation search, Uber Eats, DoorDash, Yelp.

**Incorrect (linear decay — 2km is twice as bad as 1km):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "name": "coffee" } },
      "linear": {
        "location": {
          "origin": { "lat": 38.71, "lon": -9.13 },
          "scale": "5km",
          "decay": 0.5
        }
      }
    }
  }
}
```

**Correct (gauss decay — plateau near origin, falloff after scale):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "name": "coffee" } },
      "gauss": {
        "location": {
          "origin": { "lat": 38.71, "lon": -9.13 },
          "offset": "500m",
          "scale": "2km",
          "decay": 0.5
        }
      }
    }
  }
}
```

**Parameter semantics:**

```text
origin: the user's location
offset: distance at which decay starts (plateau within offset)
scale:  distance beyond offset where decay reaches `decay` value
decay:  score at (origin + offset + scale) — typically 0.5
```

So with `offset: 500m, scale: 2km, decay: 0.5`:
- 0-500m → score = 1.0 (full)
- 2.5km → score = 0.5
- 5km → score ≈ 0.06 (near zero)

**Calibrating by domain:**

| Domain | offset | scale | Rationale |
|--------|--------|-------|-----------|
| Food delivery (urban) | 0m | 1.5km | Sharp falloff — distance = delivery time |
| Coffee/quick errand | 200m | 1km | Small plateau, fast falloff |
| Accommodation (city break) | 1km | 5km | "Anywhere central is fine" plateau |
| Accommodation (specific area) | 0m | 2km | User picked a neighborhood — stay close |
| Service appointments (in-home) | 5km | 20km | Wider acceptable radius |

**Compose with text relevance via `multiply`:**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "name": "coffee" } },
      "gauss": {
        "location": { "origin": "38.71,-9.13", "offset": "200m", "scale": "1km", "decay": 0.5 }
      },
      "boost_mode": "multiply"
    }
  }
}
```

`multiply` means the geo signal modulates the text relevance — a far-away perfect-match still loses to a near-by good-match.

**Why not Euclidean / Haversine directly:** The raw distance is unbounded and not interpretable as a relevance multiplier. The decay functions map distance into [0,1] with a domain-meaningful shape.

Reference: [OpenSearch decay functions](https://opensearch.org/docs/latest/query-dsl/compound/function-score/#decay-functions) · [Elastic — Decay functions for relevance](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html#function-decay)
