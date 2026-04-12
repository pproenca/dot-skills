# Two-Sided Personalisation

**Version 0.1.0**  
Marketplace Engineering  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for designing, building and improving personalisation and recommendation systems in two-sided trust marketplaces on AWS Personalize. Contains 49 rules across 9 categories, ordered by cascade impact on the personalisation lifecycle — from event tracking and schema design through two-sided matching, cold start, feedback loops, bias control, recipe selection, serving-time re-ranking, and observability. Includes two playbooks that walk through planning a new recommender from scratch and diagnosing an existing one against common failure modes (instrumentation gaps, stale metadata, winner-take-all, death spirals, training-serving skew).

---

## Table of Contents

1. [Event Tracking and Capture](references/_sections.md#1-event-tracking-and-capture) — **CRITICAL**
   - 1.1 [Capture Negative Signals Explicitly](references/track-capture-negative-signals.md) — CRITICAL (prevents silence-as-acceptance bias)
   - 1.2 [Log Impressions Alongside Clicks](references/track-log-impressions-alongside-clicks.md) — CRITICAL (enables unbiased CTR training)
   - 1.3 [Stamp Events with a Request-ID Join Key](references/track-stamp-events-with-request-id.md) — CRITICAL (enables impression-to-outcome attribution)
   - 1.4 [Stream Events via PutEvents in Real Time](references/track-stream-events-via-putevents.md) — CRITICAL (1-2 second recommendation adaptation)
   - 1.5 [Track Outcomes to Completion, Not Clicks](references/track-measure-outcomes-not-clicks.md) — CRITICAL (prevents clickbait reward shaping)
   - 1.6 [Use Stable Opaque Item IDs](references/track-use-stable-opaque-item-ids.md) — CRITICAL (prevents history loss on listing rename)
2. [Dataset and Schema Design](references/_sections.md#2-dataset-and-schema-design) — **CRITICAL**
   - 2.1 [Design Schemas Conservatively Because They Are Immutable](references/schema-design-conservatively.md) — CRITICAL (avoids full dataset rebuild)
   - 2.2 [Enforce Metadata Freshness as a First-Class Signal](references/schema-enforce-metadata-freshness.md) — CRITICAL (prevents stale price and availability recommendations)
   - 2.3 [Include Context Fields in Training and Inference](references/schema-include-context-everywhere.md) — HIGH (prevents training-serving feature divergence)
   - 2.4 [Keep User and Item Metadata Thin and Stable](references/schema-keep-user-item-thin.md) — CRITICAL (prevents training-serving skew)
   - 2.5 [Meet the AWS Personalize Minimum Dataset Sizes Before Training](references/schema-meet-minimum-dataset-sizes.md) — HIGH (prevents training on below-threshold data)
   - 2.6 [Prefer Categorical Fields over Free Text](references/schema-prefer-categorical-fields.md) — HIGH (enables per-value learned features)
   - 2.7 [Use EVENT_VALUE to Weight Outcomes over Clicks](references/schema-weight-event-value.md) — HIGH (enables outcome-weighted training)
3. [Two-Sided Matching Patterns](references/_sections.md#3-two-sided-matching-patterns) — **CRITICAL**
   - 3.1 [Balance Supply and Demand per Segment](references/match-balance-supply-demand.md) — HIGH (prevents segment liquidity collapse)
   - 3.2 [Cap Provider Exposure to Prevent Winner-Take-All](references/match-cap-provider-exposure.md) — CRITICAL (prevents supply monopolisation)
   - 3.3 [Filter Infeasible Candidates Before Ranking](references/match-hard-filter-before-ranking.md) — CRITICAL (reduces wasted model capacity on impossible candidates)
   - 3.4 [Model Capacity Constraints at Rank Time](references/match-model-capacity-constraints.md) — HIGH (prevents over-saturation of popular providers)
   - 3.5 [Rank by Mutual Fit, Not One Side](references/match-rank-mutual-fit.md) — CRITICAL (3-5% booking lift per Airbnb study)
4. [Simple Baselines and Theory of Constraints](references/_sections.md#4-simple-baselines-and-theory-of-constraints) — **HIGH**
   - 4.1 [Audit Instrumentation Before Any Model Work](references/simple-audit-before-build.md) — HIGH (prevents building on broken telemetry)
   - 4.2 [Budget Each Model with a Ship or Kill Criterion](references/simple-budget-complexity.md) — HIGH (prevents indefinite incubation of dead experiments)
   - 4.3 [Find the Bottleneck Before Optimizing](references/simple-find-bottleneck-first.md) — HIGH (prevents work on non-bottleneck stages)
   - 4.4 [Measure the Gap to Baseline on Every Change](references/simple-measure-gap-to-baseline.md) — HIGH (prevents accidental regression against popularity)
   - 4.5 [Ship a Popularity Baseline Before ML](references/simple-ship-popularity-baseline.md) — HIGH (reduces premature ML spend by 100%)
   - 4.6 [Use Heuristic Re-ranking for Cold Cohorts](references/simple-heuristic-rerank-cold-cohorts.md) — HIGH (enables useful ranking with zero interactions)
5. [Feedback Loops and Bias Control](references/_sections.md#5-feedback-loops-and-bias-control) — **HIGH**
   - 5.1 [Decay Event Weights over Time](references/loop-decay-event-weights.md) — HIGH (prevents stale preferences dominating)
   - 5.2 [Detect Popularity Death Spirals via Top-N Gini](references/loop-detect-death-spirals.md) — HIGH (prevents silent concentration collapse)
   - 5.3 [Log the Ranking Slot with Every Impression](references/loop-log-ranking-slot.md) — HIGH (enables position-bias correction)
   - 5.4 [Optimize for Completed Outcome, Not Click](references/loop-optimize-completed-outcome.md) — HIGH (prevents clickbait reward in feedback loop)
   - 5.5 [Reserve a Random Exploration Slice for Unbiased Training](references/loop-reserve-random-exploration.md) — HIGH (enables counterfactual evaluation)
6. [Cold Start and Coverage](references/_sections.md#6-cold-start-and-coverage) — **HIGH**
   - 6.1 [Capture Explicit Intent at Onboarding](references/cold-capture-onboarding-intent.md) — HIGH (saves days of interaction accumulation)
   - 6.2 [Reserve Exploration Slots for New Inventory](references/cold-reserve-exploration-slots.md) — HIGH (enables new-listing discovery)
   - 6.3 [Tag Cold-Start Recommendations for Separate Measurement](references/cold-tag-cold-start-recs.md) — HIGH (enables warm-vs-cold cohort comparison)
   - 6.4 [Use Best-of-Segment Popularity for New Users](references/cold-best-of-segment-popularity.md) — HIGH (prevents global-popularity blandness)
   - 6.5 [Use USER_PERSONALIZATION_v2 with Rich Item Metadata](references/cold-use-v2-recipe-with-metadata.md) — HIGH (enables same-day relevance for new listings)
7. [Recipe and Pipeline Selection](references/_sections.md#7-recipe-and-pipeline-selection) — **MEDIUM-HIGH**
   - 7.1 [Build a Candidate-Generation and Re-rank Pipeline](references/recipe-build-candidate-rerank-pipeline.md) — MEDIUM-HIGH (enables business rules and personalization to coexist)
   - 7.2 [Default to USER_PERSONALIZATION_v2 for Discovery](references/recipe-default-to-user-personalization-v2.md) — MEDIUM-HIGH (enables 5 million item catalog with lower latency)
   - 7.3 [Defer HPO Until the Baseline Is Measured](references/recipe-defer-hpo-until-baseline-measured.md) — MEDIUM (prevents wasted training spend)
   - 7.4 [Use PERSONALIZED_RANKING_v2 as a Re-ranker, Not a Generator](references/recipe-personalized-ranking-as-reranker.md) — MEDIUM-HIGH (enables business-rule compatible ranking)
   - 7.5 [Use SIMS Only for Item-Page Similar Recommendations](references/recipe-sims-for-item-page-only.md) — MEDIUM-HIGH (prevents user-history waste on item-page surfaces)
8. [Inference, Filters and Re-ranking](references/_sections.md#8-inference,-filters-and-re-ranking) — **MEDIUM-HIGH**
   - 8.1 [Apply Business Rules After Model Scoring, Not Before](references/infer-rerank-rules-after-model.md) — MEDIUM-HIGH (preserves model distribution information)
   - 8.2 [Cache Responses by User Context with a Short TTL](references/infer-cache-responses-short-ttl.md) — MEDIUM (reduces duplicate inference calls)
   - 8.3 [Deduplicate by Canonical Entity Before Returning](references/infer-deduplicate-canonical-entity.md) — MEDIUM-HIGH (prevents duplicate-entity erosion of trust)
   - 8.4 [Enforce Provider Exposure Caps at Inference](references/infer-enforce-exposure-caps.md) — MEDIUM-HIGH (prevents supply-side concentration at inference)
   - 8.5 [Use the Filters API for Hard Exclusions, Not Client Code](references/infer-use-filters-api.md) — MEDIUM-HIGH (prevents numResults shortfall on exclusion)
9. [Observability and Online Metrics](references/_sections.md#9-observability-and-online-metrics) — **MEDIUM-HIGH**
   - 9.1 [Alarm on Prediction Distribution Drift](references/obs-alarm-on-prediction-drift.md) — MEDIUM (prevents silent model staleness)
   - 9.2 [Always A/B Test, Never Before-and-After](references/obs-always-ab-test.md) — MEDIUM-HIGH (prevents confounding with seasonality)
   - 9.3 [Slice Metrics by User Segment](references/obs-slice-metrics-by-segment.md) — MEDIUM-HIGH (prevents aggregate-hides-regression failures)
   - 9.4 [Track Coverage and Exposure Gini](references/obs-track-coverage-and-gini.md) — MEDIUM-HIGH (enables death-spiral detection)
   - 9.5 [Watch for Online and Offline Metric Divergence](references/obs-watch-online-offline-divergence.md) — MEDIUM-HIGH (prevents proxy-metric overfitting)

---

## References

1. [https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-user-personalization-v2.html](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-user-personalization-v2.html)
2. [https://docs.aws.amazon.com/personalize/latest/dg/working-with-predefined-recipes.html](https://docs.aws.amazon.com/personalize/latest/dg/working-with-predefined-recipes.html)
3. [https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html](https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html)
4. [https://docs.aws.amazon.com/personalize/latest/dg/custom-datasets-and-schemas.html](https://docs.aws.amazon.com/personalize/latest/dg/custom-datasets-and-schemas.html)
5. [https://docs.aws.amazon.com/personalize/latest/dg/event-values-types.html](https://docs.aws.amazon.com/personalize/latest/dg/event-values-types.html)
6. [https://docs.aws.amazon.com/personalize/latest/dg/optimizing-solution-events-config.html](https://docs.aws.amazon.com/personalize/latest/dg/optimizing-solution-events-config.html)
7. [https://docs.aws.amazon.com/personalize/latest/dg/interactions-dataset-requirements.html](https://docs.aws.amazon.com/personalize/latest/dg/interactions-dataset-requirements.html)
8. [https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html](https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html)
9. [https://docs.aws.amazon.com/personalize/latest/dg/updating-dataset-schema.html](https://docs.aws.amazon.com/personalize/latest/dg/updating-dataset-schema.html)
10. [https://docs.aws.amazon.com/personalize/latest/dg/frequently-asked-questions.html](https://docs.aws.amazon.com/personalize/latest/dg/frequently-asked-questions.html)
11. [https://arxiv.org/abs/1205.2618](https://arxiv.org/abs/1205.2618)
12. [https://docs.aws.amazon.com/personalize/latest/dg/recommendations.html](https://docs.aws.amazon.com/personalize/latest/dg/recommendations.html)
13. [https://aws.amazon.com/blogs/machine-learning/recommend-and-dynamically-filter-items-based-on-user-context-in-amazon-personalize/](https://aws.amazon.com/blogs/machine-learning/recommend-and-dynamically-filter-items-based-on-user-context-in-amazon-personalize/)
14. [https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md](https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md)
15. [https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
16. [https://medium.com/airbnb-engineering/how-airbnb-uses-machine-learning-to-detect-host-preferences-18ce07150fa3](https://medium.com/airbnb-engineering/how-airbnb-uses-machine-learning-to-detect-host-preferences-18ce07150fa3)
17. [https://medium.com/airbnb-engineering/machine-learning-powered-search-ranking-of-airbnb-experiences-110b4b1a0789](https://medium.com/airbnb-engineering/machine-learning-powered-search-ranking-of-airbnb-experiences-110b4b1a0789)
18. [https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3](https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3)
19. [https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
20. [https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/](https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/)
21. [https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238](https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238)
22. [https://dl.acm.org/doi/10.1145/3712292](https://dl.acm.org/doi/10.1145/3712292)
23. [https://arxiv.org/pdf/2010.03240](https://arxiv.org/pdf/2010.03240)
24. [https://developers.google.com/machine-learning/guides/rules-of-ml](https://developers.google.com/machine-learning/guides/rules-of-ml)
25. [https://developers.google.com/machine-learning/recommendation/overview](https://developers.google.com/machine-learning/recommendation/overview)
26. [https://experimentguide.com/](https://experimentguide.com/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |