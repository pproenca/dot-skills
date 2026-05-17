---
title: Score Price Relevance with Soft Bands, Not Hard Filters
impact: HIGH
impactDescription: prevents zero-result pages from tight budgets
tags: market, price, budget, decay, soft-filter
---

## Score Price Relevance with Soft Bands, Not Hard Filters

A hard `price ≤ $100` filter excludes a listing at $103 that's otherwise a perfect match — and forces users to widen filters or leave. Soft price-relevance encodes the user's budget as a *preference*: full score within band, gradual decay outside it. The user gets full-budget matches at the top and slightly-over-budget alternatives below — informing a real choice rather than a no-results page. This is well-studied (Airbnb, Booking.com use this pattern) and a low-risk easy win.

**Incorrect (hard filter — silently hides near-matches):**

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "city": "lisbon" } }],
      "filter": [{ "range": { "price_per_night": { "lte": 100 } } }]
    }
  }
}
```

User searching with budget=$100 never sees a $105 listing that would have been perfect.

**Correct (soft price band with gauss decay over budget):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "city": "lisbon" } },
      "functions": [
        {
          "gauss": {
            "price_per_night": {
              "origin": 100,
              "offset": 10,
              "scale": 30,
              "decay": 0.5
            }
          }
        }
      ],
      "score_mode": "multiply",
      "boost_mode": "multiply"
    }
  }
}
```

Score-by-price:
- $90-$110 → 1.0 (within budget + 10% tolerance)
- $140 → 0.5 (40% over budget, decayed to half)
- $200 → ~0.04 (effectively excluded but still findable)

**Combine with a hard cap to prevent extreme outliers:**

```json
{
  "query": {
    "function_score": {
      "query": {
        "bool": {
          "must":   [{ "match": { "city": "lisbon" } }],
          "filter": [{ "range": { "price_per_night": { "lte": 500 } } }]
        }
      },
      "functions": [
        {
          "gauss": {
            "price_per_night": {
              "origin": 100, "offset": 10, "scale": 30, "decay": 0.5
            }
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

The hard cap at $500 (5× budget) prevents truly absurd matches; the gauss inside the cap scores by price relevance.

**Asymmetric price decay (penalize over-budget more than under-budget):**

Most marketplaces care more about over-budget penalty than under-budget. A two-sided gauss isn't asymmetric — use `script_score`:

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "city": "lisbon" } },
      "script": {
        "source": """
          double price = doc['price_per_night'].value;
          double budget = params.budget;
          double scale;
          if (price > budget) {
            scale = budget * 0.30;          // tighter over-budget
          } else {
            scale = budget * 0.50;          // wider under-budget (cheaper is fine)
          }
          double offset = budget * 0.10;
          double diff = Math.max(0, Math.abs(price - budget) - offset);
          double priceScore = Math.exp( -0.5 * Math.pow(diff / scale, 2) );
          return _score * priceScore;
        """,
        "params": { "budget": 100 }
      }
    }
  }
}
```

**Why this matters for the marketplace, not just the user:** Hard price filters depress conversion (no results = no conversion); they also depress supply revenue (a $105 listing gets zero impressions on a $100-budget search). Soft bands grow both metrics by surfacing near-fits.

**UX pairing:** When showing over-budget items, label them ("Slightly over budget — $105 vs your $100"). Transparent over-show beats silent filter for trust and conversion.

Reference: [Booking.com Engineering — Personalizing search relevance](https://booking.ai/) · [Airbnb — Smart pricing and budget-aware ranking](https://airbnb.tech/)
