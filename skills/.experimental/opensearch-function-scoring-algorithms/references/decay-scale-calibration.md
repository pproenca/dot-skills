---
title: Calibrate Decay Scale to the 0.5-Score Distance Target
impact: MEDIUM-HIGH
impactDescription: prevents over- or under-penalty cliffs
tags: decay, scale, offset, calibration, tuning
---

## Calibrate Decay Scale to the 0.5-Score Distance Target

`scale` is the most-misset decay parameter because its meaning is non-obvious — it's "the distance from `(origin + offset)` at which the function returns `decay`" (default 0.5). Set it without thinking about that and you get either a wall ("anything beyond 1km is dead") or a flat noise floor ("everything within 100km looks the same"). The right calibration is empirical: pick the distance/duration at which you want the score to halve, set `scale` to that minus `offset`.

**Incorrect (scale chosen by gut feel — falloff happens nowhere useful):**

```json
{
  "gauss": {
    "location": {
      "origin": "38.71,-9.13",
      "scale": "100km",
      "decay": 0.5
    }
  }
}
```

For city food-delivery, `scale: 100km` means a 50km-away restaurant still scores ~0.85 — distance signal is nearly absent.

**Correct (scale = the "half-score distance" minus offset, derived from data):**

Step 1 — Look at the historical click/conversion data:

```sql
SELECT distance_km_bucket, COUNT(*) as clicks, AVG(converted) as conv_rate
FROM search_events
WHERE category = 'food_delivery'
GROUP BY distance_km_bucket
ORDER BY distance_km_bucket;
```

Suppose conversion halves at 2km from origin.

Step 2 — Set `scale` so the function halves at that distance:

```json
{
  "gauss": {
    "location": {
      "origin": "38.71,-9.13",
      "offset": "200m",
      "scale": "1.8km",
      "decay": 0.5
    }
  }
}
```

Now the decay function's 0.5 point matches the observed conversion 0.5 point.

**The math:**

```text
Gauss:    s(d) = exp( -ln(decay) / scale^2 * max(0, d - offset)^2 )
Exp:      s(d) = exp(  ln(decay) / scale      * max(0, d - offset)   )
Linear:   s(d) = max(0, 1 - max(0, d - offset) / scale * (1 - decay))

Solving for scale at a target half-distance d_half (with decay = 0.5):
  Gauss:  scale = (d_half - offset) / sqrt(1)  = d_half - offset
  Exp:    scale = (d_half - offset)            (same — at decay=0.5)
  Linear: scale = (d_half - offset) * 2        (linear hits 0.5 at half-scale)
```

So for Gauss/Exp with `decay=0.5`, `scale = d_half - offset` directly.

**Calibration heuristics by domain:**

| Domain | offset | scale | (gauss) d_half from origin |
|--------|--------|-------|---------------------------|
| Food delivery | 200m | 1.8km | 2.0km |
| Coffee/quick errand | 100m | 900m | 1.0km |
| Local services | 500m | 4.5km | 5.0km |
| City accommodation | 1km | 4km | 5.0km |
| Cross-city trip | 0km | 50km | 50km |

**Validation:** Plot the resulting decay curve against historical conversion-by-distance. If they don't track, recalibrate `scale` or switch the curve shape.

**Common mistake — copying values across domains:** A `scale: 5km` calibrated for restaurant delivery is wrong for hotel search. The "half-distance" is fundamentally different.

Reference: [OpenSearch decay function parameters](https://opensearch.org/docs/latest/query-dsl/compound/function-score/#decay-functions)
