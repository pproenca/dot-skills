---
title: Use Bayesian Average for Star Ratings with Low Sample Sizes
impact: HIGH
impactDescription: prevents new-listing cold-start rating distortion
tags: qual, bayesian, rating, smoothing, m-estimate
---

## Use Bayesian Average for Star Ratings with Low Sample Sizes

For multi-grade ratings (1-5 stars), the raw mean is a maximum-likelihood estimate that ignores prior beliefs. A new listing with three 5-star ratings has a sample mean of 5.0; a mature listing with 10,000 ratings averaging 4.7 has a sample mean of 4.7. Ranking by mean puts the noisy new one first. The Bayesian (or m-estimate) average shrinks each item's mean toward the global mean by a confidence weight — equivalent to assuming each item starts with `m` "pseudo-ratings" at the global mean. This is the IMDB Top 250 formula and the standard approach across marketplaces.

**The formula:**

```text
bayesian_avg = (v / (v + m)) * R  +  (m / (v + m)) * C

  where:
    R = item's mean rating
    v = item's rating count
    C = global mean rating across catalog
    m = minimum ratings to be "trusted" (the smoothing strength)
```

**Incorrect (raw mean — new listings dominate):**

```json
{
  "query": { "match_all": {} },
  "sort": [
    { "field": "avg_rating", "order": "desc" }
  ]
}
```

**Correct (Bayesian average computed offline, indexed as `rank_feature`):**

```json
// In your indexing pipeline (Python):
//   v = item.rating_count
//   R = item.avg_rating
//   m = 50  (calibrate from rating-count distribution)
//   C = 4.32  (current global mean — recompute weekly)
//   bayesian_score = (v / (v + m)) * R + (m / (v + m)) * C
//   index field: "quality.bayesian_score": <value>

PUT /listings/_mapping
{
  "properties": {
    "quality": {
      "properties": {
        "bayesian_score": { "type": "rank_feature" }
      }
    }
  }
}
```

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "loft" } },
      "functions": [
        { "rank_feature": { "field": "quality.bayesian_score" } }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

**Calibrating `m`:** Set `m` to the 60th-90th percentile of your rating-count distribution. Higher `m` = stronger shrinkage = harder for new items to dominate. Common defaults: IMDB uses ~25,000 (because they have millions of ratings); a young marketplace might use 20-50.

**Why this beats Wilson for 5-star data:** Wilson assumes binary outcomes. A 4-star rating isn't half a positive vote — it's its own grade. Bayesian average preserves the rating grade information; Wilson collapses it to thumbs-up/down. Use Wilson for like/dislike, Bayesian for 5-star.

**Recompute `C` periodically:** Global mean drifts as the catalog matures. Stale `C` introduces systematic bias.

Reference: [Paul Masurel — Of Bayesian Average and Star Ratings](https://fulmicoton.com/posts/bayesian_rating/) · [Plan Space — How To Sort By Average Rating (Bayesian section)](https://planspace.org/2014/08/17/how-to-sort-by-average-rating/) · [Jules Jacobs — Bayesian Ranking of Items](https://julesjacobs.com/2015/08/17/bayesian-scoring-of-ratings.html)
