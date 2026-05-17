---
title: Use Exp Decay for Time Freshness, Gauss for Date Proximity
impact: HIGH
impactDescription: prevents symmetric falloff on directional time
tags: decay, exp, gauss, freshness, time, dates
---

## Use Exp Decay for Time Freshness, Gauss for Date Proximity

Time-based decay has two distinct shapes depending on the question. Exp decay (`exp(-λ × age)`) is "older is monotonically worse, fast at first then slowly" — right for freshness (new listings, recent updates, recent reviews). Gauss decay around a date origin is "match this date, with a tolerance window" — right for event-date or availability matching. Mixing them up gives bizarre results: exp around an event date treats "1 day before" the same as "1 day after"; gauss for freshness treats "yesterday" same as "tomorrow."

**Incorrect (gauss decay on listing age — symmetric falloff doesn't model freshness):**

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "gauss": {
        "listed_at": {
          "origin": "now",
          "scale": "14d",
          "decay": 0.5
        }
      }
    }
  }
}
```

Gauss is symmetric around origin — `listed_at` in the future (impossible for real data, but possible with clock skew or test data) scores same as past. More importantly, it suggests "30 days old" is much worse than "14 days old," which over-penalizes anything older than your window.

**Correct (exp decay for freshness — monotonic, smooth long-tail):**

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "exp": {
        "listed_at": {
          "origin": "now",
          "offset": "3d",
          "scale": "30d",
          "decay": 0.5
        }
      },
      "boost_mode": "multiply"
    }
  }
}
```

So: brand-new listings within 3 days score 1.0, 33-day-old listings score 0.5, year-old listings score ~0.02 — gradual, monotonic.

**Correct (gauss decay for date-proximity matching — symmetric tolerance):**

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "gauss": {
        "event_date": {
          "origin": "2026-08-15",
          "scale": "7d",
          "decay": 0.5
        }
      }
    }
  }
}
```

An event on 2026-08-08 or 2026-08-22 both score 0.5 — symmetric around the user's target date, which is what you want for "find an event around this date."

**Decision table for time-based decay:**

| Question | Shape | Function |
|----------|-------|----------|
| Is this listing fresh? | Monotonic falloff with age | `exp` |
| Is this near the user's target date? | Symmetric tolerance window | `gauss` |
| Is this within a hard cutoff? | Sharp drop after threshold | `linear` with small scale |
| Did this happen recently? | Monotonic but fast falloff | `exp` with small scale |

**Combining freshness with text relevance:** Use `boost_mode: multiply` so freshness modulates relevance rather than overwhelming it. With `boost_mode: sum`, very old listings can ride to the top on text relevance alone.

**Anti-pattern — using `now`/`d` units as filter:** Don't use decay as a substitute for filtering out stale records. If anything older than 90 days is irrelevant, filter it out with `range` *before* scoring; let decay shape ranking within the relevant window.

Reference: [OpenSearch decay functions](https://opensearch.org/docs/latest/query-dsl/compound/function-score/#decay-functions)
