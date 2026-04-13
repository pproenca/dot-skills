---
title: Ship One Feature at a Time in the First Year
impact: MEDIUM
impactDescription: prevents bundled-release attribution confounds
tags: prove, one-at-a-time, attribution, experimentation
---

## Ship One Feature at a Time in the First Year

Shipping three features together in a single release and seeing a 2% lift tells you nothing about which of the three moved the metric — and the one that regressed is hidden by the two that helped. In the first year of a feature portfolio, release exactly one feature per A/B test: one new feature goes into the treatment, the control has the model without it, and the ship/kill decision is per feature. Once the portfolio is mature and the team has credibility, bundled releases become defensible; before that, bundling is the fastest way to accumulate features that nobody can defend.

**Incorrect (three features ship together):**

```python
# experiment ths_homefeed_ml_v2
# treatment: +amenity_multihot, +pet_description_embedding, +sitter_experience_count
# control: previous model
# result: +1.8% booking rate, p < 0.05 → "ship"
# but which feature actually helped? and which one regressed a subsegment?
```

**Correct (three separate experiments, serial or parallel with disjoint populations):**

```python
EXPERIMENTS = [
    {
        "name": "ths_homefeed_amenity_multihot",
        "treatment": "model_v14_with_amenity_multihot",
        "control": "model_v14_without_amenity_multihot",
    },
    {
        "name": "ths_homefeed_pet_description_embedding",
        "treatment": "model_v14_with_pet_desc_embed",
        "control": "model_v14_without_pet_desc_embed",
    },
    {
        "name": "ths_homefeed_sitter_experience_count",
        "treatment": "model_v14_with_experience_count",
        "control": "model_v14_without_experience_count",
    },
]
# ship decision made per experiment; losers are killed without blocking the winners
```

Reference: [Google — Rules of Machine Learning, Rule #16: Plan to launch and iterate](https://developers.google.com/machine-learning/guides/rules-of-ml)
