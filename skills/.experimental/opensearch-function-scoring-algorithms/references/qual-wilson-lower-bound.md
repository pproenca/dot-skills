---
title: Sort by Wilson Lower Bound, Not Average Rating
impact: HIGH
impactDescription: prevents 1-rating-of-5-stars beating 1000-ratings-of-4.8
tags: qual, wilson, confidence-interval, ratings, ranking
---

## Sort by Wilson Lower Bound, Not Average Rating

Sorting by mean rating (positive_ratings / total_ratings) systematically favors items with few ratings. One listing with a single 5-star review ranks above a listing with 999 5-star and 1 4-star review (5.0 vs 4.999) — exactly inverted from intuition. The Wilson Score Interval (Wilson 1927) gives the lower bound of a 95% confidence interval on the true positive proportion given observed counts; sorting by this lower bound naturally penalizes low-sample items. Evan Miller popularized this in 2009 as the correct way to sort Bernoulli-rated items (Reddit comments, product upvotes, binary like/dislike).

**Incorrect (mean rating — one 5-star review wins):**

```json
{
  "query": { "match_all": {} },
  "sort": [
    { "_script": {
        "type": "number",
        "script": "doc['positive_ratings'].value / Math.max(doc['total_ratings'].value, 1)",
        "order": "desc"
      }
    }
  ]
}
```

**Correct (Wilson Lower Bound — confidence-weighted):**

```json
{
  "query": { "match_all": {} },
  "sort": [
    { "_script": {
        "type": "number",
        "script": {
          "source": """
            double n = doc['total_ratings'].value;
            if (n == 0) return 0.0;
            double p = doc['positive_ratings'].value / n;
            double z = 1.96; // 95% confidence
            double denom = 1.0 + z*z / n;
            double centre = p + z*z / (2.0 * n);
            double margin = z * Math.sqrt((p*(1.0-p) + z*z/(4.0*n)) / n);
            return (centre - margin) / denom;
          """
        },
        "order": "desc"
      }
    }
  ]
}
```

**Pre-compute, don't sort-script in production:** Computing Wilson Lower Bound at sort time scales linearly with matched docs. Compute it offline (in your indexing pipeline), store as a `rank_feature` field, and use that:

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "functions": [
        { "rank_feature": { "field": "wilson_score" } }
      ],
      "boost_mode": "replace"
    }
  }
}
```

**For 5-star ratings (not binary):** Use Bayesian average instead (see `qual-bayesian-average`). Wilson is for Bernoulli (positive/negative); the analogous interval for multi-grade ratings is more elaborate (Dirichlet-Multinomial).

Reference: [Evan Miller — How Not To Sort By Average Rating (2009)](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html) · [Wilson, E.B. (1927) — Probable Inference, the Law of Succession, and Statistical Inference (JASA 22:158)](https://www.jstor.org/stable/2276774)
