---
title: Separate Host-Quality and Listing-Quality Signals
impact: MEDIUM-HIGH
impactDescription: prevents host-good-listing-bad confusion
tags: market, host-quality, listing-quality, signal-separation
---

## Separate Host-Quality and Listing-Quality Signals

A great host can have an underwhelming listing; a great listing can belong to an unreliable host. Treating them as one quality score conflates two distinct concerns and produces ranking errors in both directions. Index them separately and combine deliberately: host signals (response rate, acceptance rate, cancellation rate, tenure) modulate trust; listing signals (rating, photo count, completeness, conversion rate) modulate intrinsic appeal. A listing is recommendable only when both are sufficient.

**Incorrect (single "quality" score conflating host and listing):**

```python
# Conflated quality signal — fails when host is great but listing is bad
quality = 0.5 * host_rating + 0.5 * listing_rating  # single rank_feature
```

A perfect-host with a poorly-described listing scores 0.8; a great listing under a flaky host scores 0.8 too. Both are misranked.

**Correct (separate host and listing signals, AND-style composition):**

```json
PUT /listings/_mapping
{
  "properties": {
    "host": {
      "properties": {
        "response_rate":    { "type": "rank_feature", "positive_score_impact": true },
        "acceptance_rate":  { "type": "rank_feature", "positive_score_impact": true },
        "cancellation_rate":{ "type": "rank_feature", "positive_score_impact": false },
        "is_superhost":     { "type": "boolean" }
      }
    },
    "listing": {
      "properties": {
        "bayesian_rating":  { "type": "rank_feature", "positive_score_impact": true },
        "completeness":     { "type": "rank_feature", "positive_score_impact": true },
        "conv_rate_30d":    { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "city": "lisbon" } },
      "script": {
        "source": """
          double textRel = _score;

          // Host trust: AND-like — all signals must be acceptable
          double hostTrust = Math.min(
              Math.min(
                  Math.pow(doc['host.response_rate'].value, 2),
                  Math.pow(doc['host.acceptance_rate'].value, 2)
              ),
              1.0 - doc['host.cancellation_rate'].value
          );

          // Listing appeal: OR-like — strong on any axis is good
          double listingAppeal = 0.4 * doc['listing.bayesian_rating'].value
                               + 0.3 * doc['listing.completeness'].value
                               + 0.3 * doc['listing.conv_rate_30d'].value;

          // Multiply — both must pass; either failing tanks the result
          return textRel * hostTrust * listingAppeal;
        """
      }
    }
  }
}
```

**Why AND-composition for host trust:** Host signals are gating — a host with great response rate but high cancellation rate is unreliable overall. AND-style (min, multiply) means any weak signal pulls the trust score down. The user-visible failure mode of a bad host (no-show, cancellation) is bad enough that you should ration on the worst signal.

**Why OR-composition for listing appeal:** Different listings shine on different axes. A boutique listing with sparse photos but stellar ratings is fine; a generic listing with thorough photos and competitive price is also fine. OR (weighted sum) lets each listing be recommendable for its strengths.

**Surface signal separation in product UI:** Show host badges separately from listing badges ("Superhost", "Highly rated"). This educates users to read both signals and creates incentive for both improvements.

Reference: [Airbnb — Search Ranking and Personalization (RecSys 2017)](https://dl.acm.org/doi/abs/10.1145/3109859.3109920) · [DoorDash — Multi-objective marketplace optimization](https://careersatdoordash.com/blog/)
