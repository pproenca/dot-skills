---
title: Add Offset to Decay Functions for Noisy Sparse Fields
impact: MEDIUM
impactDescription: prevents micro-distance ranking instability
tags: decay, offset, noise, sparse, plateau
---

## Add Offset to Decay Functions for Noisy Sparse Fields

Without `offset`, the decay function starts decaying immediately from `origin`, making it sensitive to micro-differences — a listing 50m away scores higher than one 60m away. For most marketplace ranking, that distinction is noise: GPS accuracy is ~10-20m and users don't care about meters. The `offset` parameter establishes a plateau within which all items score 1.0, removing this micro-instability and concentrating decay's discriminative power on meaningful distances.

**Incorrect (no offset — micro-distance noise drives ranking):**

```json
{
  "gauss": {
    "location": {
      "origin": "38.71,-9.13",
      "scale": "2km",
      "decay": 0.5
    }
  }
}
```

A restaurant at 80m scores 0.999; one at 200m scores 0.997. Real differences below GPS accuracy now affect rank order — pure noise amplification.

**Correct (offset creates a meaningful plateau):**

```json
{
  "gauss": {
    "location": {
      "origin": "38.71,-9.13",
      "offset": "300m",
      "scale": "1.7km",
      "decay": 0.5
    }
  }
}
```

Everything within 300m scores 1.0 (no micro-distinctions inside walking distance); beyond that, decay engages.

**Offset = your signal noise floor:**

| Signal | Sensible offset | Why |
|--------|----------------|-----|
| Geo location (urban) | 200-500m | GPS accuracy + walking-equivalent indifference |
| Geo location (suburban/rural) | 1-2km | "In the same area" is broader |
| Date proximity | ±1d | "Around this date" tolerance |
| Time of day | ±1h | Hourly granularity |
| Listing age (freshness) | 1-3d | "Brand new" plateau |
| Price proximity to budget | 5-10% | Sticker noise within tolerance |

**Why this matters for ranking stability:** Without offset, every refresh of a user's location (which moves ~10m as they walk) reshuffles results. With offset, ranking is stable within the noise floor — the user perceives consistent results, not flickering.

**Pairing with `decay`:** Offset doesn't replace `decay`; they work together. Offset says "no penalty inside this radius," decay says "what penalty applies at the edge of `scale`." Tune them independently.

**Anti-pattern — using offset as a filter substitute:** If you want hard "no results beyond 10km," use a `geo_distance` filter, not a decay with huge offset. Offset is for soft within-plateau leniency, not hard cutoffs.

Reference: [OpenSearch decay function parameters](https://opensearch.org/docs/latest/query-dsl/compound/function-score/#decay-functions) · [GPS accuracy reference (US.gov)](https://www.gps.gov/systems/gps/performance/accuracy/)
