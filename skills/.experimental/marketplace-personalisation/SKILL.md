---
name: marketplace-personalisation
description: Use this skill whenever designing, building, debugging, reviewing, or improving a personalisation or recommendation system for a two-sided trust marketplace built on AWS Personalize — covers event tracking, dataset and schema design, two-sided matching, cold start, feedback loops, bias control, recipe selection, serving-time re-ranking, observability, and a diagnostic playbook for existing systems. Trigger even when the user does not explicitly mention "AWS Personalize" but is working on recommendations, ranking, search, homepage personalisation, or anything that matches seekers and providers across a trust-based catalog.
---

# Marketplace Engineering Two-Sided Personalisation Best Practices

Comprehensive guide for designing, building and improving personalisation and recommendation
systems in two-sided trust marketplaces on AWS Personalize. Contains 49 rules across 9
categories, ordered by cascade impact on the personalisation lifecycle, plus two playbooks
for planning a new system from scratch and diagnosing an existing one.

## When to Apply

Reference this skill when:

- Designing the event schema and tracking for a new recommender system
- Choosing an AWS Personalize recipe (USER_PERSONALIZATION_v2, SIMS, PERSONALIZED_RANKING_v2)
- Writing or reviewing candidate-generation and re-ranking code for marketplace search or homefeed
- Handling cold start for new providers, new seekers, or new catalog regions
- Diagnosing a live system that "mostly works but feels stale, unfair, or unpersonalised"
- Planning the next experiment, baseline comparison, or A/B test for the recommender
- Investigating concentration, coverage collapse, death spirals, or training-serving skew
- Adding observability dashboards, drift detection, or online metric slicing

## Setup

This skill has no user-specific configuration — it is self-contained. References are live
URLs to official AWS Personalize documentation, academic papers on bias and exposure, and
engineering blogs from Airbnb and DoorDash.

## Rule Categories

Categories are ordered by cascade impact: earlier stages poison everything downstream.

| # | Category | Prefix | Impact |
|---|----------|--------|--------|
| 1 | Event Tracking and Capture | `track-` | CRITICAL |
| 2 | Dataset and Schema Design | `schema-` | CRITICAL |
| 3 | Two-Sided Matching Patterns | `match-` | CRITICAL |
| 4 | Simple Baselines and Theory of Constraints | `simple-` | HIGH |
| 5 | Feedback Loops and Bias Control | `loop-` | HIGH |
| 6 | Cold Start and Coverage | `cold-` | HIGH |
| 7 | Recipe and Pipeline Selection | `recipe-` | MEDIUM-HIGH |
| 8 | Inference, Filters and Re-ranking | `infer-` | MEDIUM-HIGH |
| 9 | Observability and Online Metrics | `obs-` | MEDIUM-HIGH |

## Quick Reference

### 1. Event Tracking and Capture (CRITICAL)

- [`track-log-impressions-alongside-clicks`](references/track-log-impressions-alongside-clicks.md) — the denominator that turns clicks into a rate and unlocks unbiased training
- [`track-use-stable-opaque-item-ids`](references/track-use-stable-opaque-item-ids.md) — prevents history loss when listings rename or move
- [`track-stamp-events-with-request-id`](references/track-stamp-events-with-request-id.md) — the join key that enables impression-to-outcome attribution
- [`track-stream-events-via-putevents`](references/track-stream-events-via-putevents.md) — real-time adaptation versus end-of-day bulk import
- [`track-capture-negative-signals`](references/track-capture-negative-signals.md) — dismissal is information, silence is not
- [`track-measure-outcomes-not-clicks`](references/track-measure-outcomes-not-clicks.md) — reward the completed booking, not the clickbait

### 2. Dataset and Schema Design (CRITICAL)

- [`schema-design-conservatively`](references/schema-design-conservatively.md) — Interactions schemas are immutable, Users/Items are painful to change
- [`schema-keep-user-item-thin`](references/schema-keep-user-item-thin.md) — volatile fields belong in events
- [`schema-enforce-metadata-freshness`](references/schema-enforce-metadata-freshness.md) — PutItems on every metadata change
- [`schema-prefer-categorical-fields`](references/schema-prefer-categorical-fields.md) — unlock per-value features
- [`schema-weight-event-value`](references/schema-weight-event-value.md) — align the model with the business outcome
- [`schema-include-context-everywhere`](references/schema-include-context-everywhere.md) — train-serve feature parity
- [`schema-meet-minimum-dataset-sizes`](references/schema-meet-minimum-dataset-sizes.md) — 50 users / 50 items / 1000 interactions before training

### 3. Two-Sided Matching Patterns (CRITICAL)

- [`match-rank-mutual-fit`](references/match-rank-mutual-fit.md) — rank by mutual accept probability
- [`match-hard-filter-before-ranking`](references/match-hard-filter-before-ranking.md) — retrieval enforces feasibility
- [`match-cap-provider-exposure`](references/match-cap-provider-exposure.md) — diversity as a fairness constraint
- [`match-model-capacity-constraints`](references/match-model-capacity-constraints.md) — capacity-discounted scoring
- [`match-balance-supply-demand`](references/match-balance-supply-demand.md) — per-segment strategy routing

### 4. Simple Baselines and Theory of Constraints (HIGH)

- [`simple-ship-popularity-baseline`](references/simple-ship-popularity-baseline.md) — a reference point that every ML model must beat
- [`simple-find-bottleneck-first`](references/simple-find-bottleneck-first.md) — diagnostic before optimisation
- [`simple-heuristic-rerank-cold-cohorts`](references/simple-heuristic-rerank-cold-cohorts.md) — trust × recency × proximity
- [`simple-budget-complexity`](references/simple-budget-complexity.md) — ship or kill criterion before running
- [`simple-audit-before-build`](references/simple-audit-before-build.md) — telemetry audit gates model work
- [`simple-measure-gap-to-baseline`](references/simple-measure-gap-to-baseline.md) — baseline retained as permanent minority bucket

### 5. Feedback Loops and Bias Control (HIGH)

- [`loop-log-ranking-slot`](references/loop-log-ranking-slot.md) — slot data for position-bias correction
- [`loop-reserve-random-exploration`](references/loop-reserve-random-exploration.md) — unbiased training data
- [`loop-optimize-completed-outcome`](references/loop-optimize-completed-outcome.md) — reward the goal, not the proxy
- [`loop-decay-event-weights`](references/loop-decay-event-weights.md) — old preferences fade
- [`loop-detect-death-spirals`](references/loop-detect-death-spirals.md) — exposure Gini as a leading indicator

### 6. Cold Start and Coverage (HIGH)

- [`cold-use-v2-recipe-with-metadata`](references/cold-use-v2-recipe-with-metadata.md) — metadata extrapolates to new listings
- [`cold-best-of-segment-popularity`](references/cold-best-of-segment-popularity.md) — segmentation beats global top-N
- [`cold-capture-onboarding-intent`](references/cold-capture-onboarding-intent.md) — ask instead of guessing
- [`cold-reserve-exploration-slots`](references/cold-reserve-exploration-slots.md) — promotions filter for fresh inventory
- [`cold-tag-cold-start-recs`](references/cold-tag-cold-start-recs.md) — warm-versus-cold metric slicing

### 7. Recipe and Pipeline Selection (MEDIUM-HIGH)

- [`recipe-default-to-user-personalization-v2`](references/recipe-default-to-user-personalization-v2.md) — discovery default
- [`recipe-sims-for-item-page-only`](references/recipe-sims-for-item-page-only.md) — similar-items is not a homepage recipe
- [`recipe-personalized-ranking-as-reranker`](references/recipe-personalized-ranking-as-reranker.md) — not a candidate generator
- [`recipe-build-candidate-rerank-pipeline`](references/recipe-build-candidate-rerank-pipeline.md) — two layers, two concerns
- [`recipe-defer-hpo-until-baseline-measured`](references/recipe-defer-hpo-until-baseline-measured.md) — prove the model before tuning

### 8. Inference, Filters and Re-ranking (MEDIUM-HIGH)

- [`infer-use-filters-api`](references/infer-use-filters-api.md) — Personalize backfills to numResults
- [`infer-rerank-rules-after-model`](references/infer-rerank-rules-after-model.md) — preserve the model distribution
- [`infer-deduplicate-canonical-entity`](references/infer-deduplicate-canonical-entity.md) — provider-level dedup, not listing-level
- [`infer-enforce-exposure-caps`](references/infer-enforce-exposure-caps.md) — rolling fairness constraints
- [`infer-cache-responses-short-ttl`](references/infer-cache-responses-short-ttl.md) — session continuity and cost control

### 9. Observability and Online Metrics (MEDIUM-HIGH)

- [`obs-always-ab-test`](references/obs-always-ab-test.md) — before-and-after is never enough
- [`obs-track-coverage-and-gini`](references/obs-track-coverage-and-gini.md) — exposure-health signals
- [`obs-slice-metrics-by-segment`](references/obs-slice-metrics-by-segment.md) — aggregate metrics hide segment regressions
- [`obs-watch-online-offline-divergence`](references/obs-watch-online-offline-divergence.md) — proxy overfitting detector
- [`obs-alarm-on-prediction-drift`](references/obs-alarm-on-prediction-drift.md) — distribution KL-divergence as early warning

## Planning and Improving Recommendations

Two playbooks drive end-to-end workflows that compose the rules above:

- [`references/playbooks/planning.md`](references/playbooks/planning.md) — Plan a new recommender system from scratch: a nine-step workflow that starts with instrumentation and ends with the first A/B-tested ML lift over a popularity baseline.
- [`references/playbooks/improving.md`](references/playbooks/improving.md) — Diagnose and improve an existing recommender: a decision tree that identifies the current bottleneck (telemetry, freshness, coverage, feedback loop, algorithm) and routes to the specific rules that fix it.

Read the playbooks first when the task is "design a recommender" or "this recommender
is underperforming". Read the individual rules when a specific question arises during
implementation or review.

## How to Use

- Read [`references/_sections.md`](references/_sections.md) for category structure and impact ordering.
- Read individual rule files under `references/` when a specific rule matches the task at hand.
- Read [`references/playbooks/planning.md`](references/playbooks/planning.md) to design a new system.
- Read [`references/playbooks/improving.md`](references/playbooks/improving.md) to diagnose an existing system.
- Use [`assets/templates/_template.md`](assets/templates/_template.md) to author new rules as the skill grows.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact ordering, cascade rationale |
| [references/playbooks/planning.md](references/playbooks/planning.md) | Planning playbook for a new recommender |
| [references/playbooks/improving.md](references/playbooks/improving.md) | Diagnostic playbook for an existing recommender |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, discipline, authoritative reference URLs |
