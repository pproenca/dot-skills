---
name: marketplace-search-recsys-planning
description: Use this skill whenever planning, designing, reviewing, or improving search and recommendation systems for a two-sided trust marketplace built on OpenSearch — covers user-intent framing, product-surface architecture, index design, query understanding, retrieval strategy, ranking, search-plus-recs blending, measurement, and a dashboard-and-alerting layer for ongoing decision making. Triggers on tasks involving marketplace search, homefeeds, ranking, relevance tuning, OpenSearch query DSL, analyzers, synonyms, golden sets, NDCG, A/B testing, or diagnosing an existing retrieval system. Use this skill BEFORE marketplace-personalisation when planning new work; hand off when the diagnosed bottleneck is personalisation-specific.
---

# Marketplace Engineering Two-Sided Search and Recsys Planning Best Practices

Comprehensive planning, design and diagnostic guide for search and recommendation systems
in two-sided trust marketplaces. Covers OpenSearch index, query and ranking patterns, the
methodology for planning retrieval work, the handoff points to recommendation-specific
tooling, and the instrumentation and dashboard layer that turns measurement into ongoing
decision making. Contains 57 rules across 10 categories ordered by cascade impact, plus
two playbooks (plan a new system from scratch, diagnose an existing one) and explicit
living-artefact conventions (decisions log, golden set, gotchas).

## When to Apply

Reference this skill when:

- Planning a new marketplace retrieval project from scratch
- Reviewing an existing retrieval system that feels stale, unfair, or unpersonalised
- Designing the OpenSearch index mapping, analyzers, or query DSL
- Choosing retrieval primitives per product surface (search, recs, hybrid, curated)
- Deciding which search quality metrics to track and dashboard
- Running the weekly search-quality review ritual
- Diagnosing a silent regression in ranking, coverage, or zero-result rate
- Deciding when a retrieval problem is actually a personalisation problem

This skill is the **precursor** to `marketplace-personalisation`. Start here for
planning and search work; hand off to the personalisation skill when the diagnosed
bottleneck is impression tracking, feedback-loop bias, or AWS Personalize-specific
design.

## Living Context

This skill treats the system as evolving. Three living artefacts carry context across
sessions, releases, and team changes — read them before making suggestions, update them
after every shipped change:

- **`gotchas.md`** (in this skill folder) — append-only diagnostic lessons. Every gotcha
  has a date and a short description of what surprised the team and how it was resolved.
- **Decisions log** (maintained in the product repo, typically `decisions/*.md`) —
  every ranking change, schema tweak, and synonym edit recorded with its hypothesis,
  offline and online evidence, ship criterion, outcome, and rollback path. See rule
  [`plan-maintain-a-decisions-log`](references/plan-maintain-a-decisions-log.md).
- **Golden query set** (frozen per eval cycle, committed to the product repo) — the
  reference set of queries against which every ranking change is offline-evaluated
  before an online test. See rule
  [`plan-version-the-golden-set`](references/plan-version-the-golden-set.md).

## Rule Categories

Categories are ordered by cascade impact on the retrieval lifecycle: intent
misunderstanding poisons architecture; wrong architecture poisons index; wrong index
poisons retrieval forever until a reindex; every downstream layer inherits the upstream
error.

| # | Category | Prefix | Impact |
|---|----------|--------|--------|
| 1 | Problem Framing and User Intent | `intent-` | CRITICAL |
| 2 | Surface Taxonomy and Architecture | `arch-` | CRITICAL |
| 3 | Index Design and Mapping | `index-` | HIGH |
| 4 | Planning and Improvement Methodology | `plan-` | HIGH |
| 5 | Query Understanding | `query-` | MEDIUM-HIGH |
| 6 | Retrieval Strategy | `retrieve-` | MEDIUM-HIGH |
| 7 | Relevance and Ranking | `rank-` | MEDIUM-HIGH |
| 8 | Search and Recommender Blending | `blend-` | MEDIUM |
| 9 | Measurement and Experimentation | `measure-` | MEDIUM |
| 10 | Instrumentation, Dashboards and Decision Triggers | `monitor-` | MEDIUM |

## Quick Reference

### 1. Problem Framing and User Intent (CRITICAL)

- [`intent-map-queries-to-intent-classes`](references/intent-map-queries-to-intent-classes.md) — classify before retrieving
- [`intent-separate-known-item-from-discovery`](references/intent-separate-known-item-from-discovery.md) — different failure modes, different strategies
- [`intent-audit-live-query-logs-first`](references/intent-audit-live-query-logs-first.md) — design from real data, not imagined data
- [`intent-distinguish-transactional-from-exploratory`](references/intent-distinguish-transactional-from-exploratory.md) — precision vs diversity
- [`intent-reject-one-search-for-everything`](references/intent-reject-one-search-for-everything.md) — per-surface query shapes
- [`intent-treat-no-search-as-first-class-choice`](references/intent-treat-no-search-as-first-class-choice.md) — curated is a legitimate answer

### 2. Surface Taxonomy and Architecture (CRITICAL)

- [`arch-map-surface-to-retrieval-primitive`](references/arch-map-surface-to-retrieval-primitive.md) — a single-source-of-truth routing table
- [`arch-split-candidate-generation-from-ranking`](references/arch-split-candidate-generation-from-ranking.md) — two-stage pipelines
- [`arch-design-zero-result-fallback`](references/arch-design-zero-result-fallback.md) — declare fallback owner per surface
- [`arch-design-for-cold-start-from-day-one`](references/arch-design-for-cold-start-from-day-one.md) — cold start is permanent, not bootstrap
- [`arch-avoid-mono-stack-retrieval`](references/arch-avoid-mono-stack-retrieval.md) — diversify primary dependencies
- [`arch-route-surfaces-deliberately`](references/arch-route-surfaces-deliberately.md) — every routing decision recorded

### 3. Index Design and Mapping (HIGH)

- [`index-design-mappings-conservatively`](references/index-design-mappings-conservatively.md) — reindex is expensive
- [`index-use-keyword-and-text-as-multi-fields`](references/index-use-keyword-and-text-as-multi-fields.md) — full-text plus exact match
- [`index-match-index-and-query-time-analyzers`](references/index-match-index-and-query-time-analyzers.md) — tokens must agree
- [`index-use-language-analyzers-for-language-fields`](references/index-use-language-analyzers-for-language-fields.md) — language-aware stemming
- [`index-separate-searchable-from-display-fields`](references/index-separate-searchable-from-display-fields.md) — index only what you search
- [`index-use-index-templates-for-consistency`](references/index-use-index-templates-for-consistency.md) — prevent mapping drift
- [`index-stream-listing-updates-via-cdc`](references/index-stream-listing-updates-via-cdc.md) — freshness in seconds, not hours

### 4. Planning and Improvement Methodology (HIGH)

- [`plan-audit-before-you-build`](references/plan-audit-before-you-build.md) — instrumentation gate on kick-off
- [`plan-build-golden-query-set-first`](references/plan-build-golden-query-set-first.md) — the first artefact, not the last
- [`plan-find-bottleneck-before-optimising`](references/plan-find-bottleneck-before-optimising.md) — theory of constraints
- [`plan-maintain-a-decisions-log`](references/plan-maintain-a-decisions-log.md) — living context across team changes
- [`plan-version-the-golden-set`](references/plan-version-the-golden-set.md) — frozen per eval cycle
- [`plan-handoff-to-personalisation-skill`](references/plan-handoff-to-personalisation-skill.md) — recognise the boundary

### 5. Query Understanding (MEDIUM-HIGH)

- [`query-normalise-before-anything-else`](references/query-normalise-before-anything-else.md) — canonical string in
- [`query-use-language-analyzers-for-stemming`](references/query-use-language-analyzers-for-stemming.md) — double-digit recall wins
- [`query-curate-synonyms-by-domain`](references/query-curate-synonyms-by-domain.md) — domain vocabulary not thesaurus
- [`query-use-fuzzy-matching-for-typos`](references/query-use-fuzzy-matching-for-typos.md) — 10-15% of queries have typos
- [`query-classify-before-routing`](references/query-classify-before-routing.md) — single-pass classifier
- [`query-build-autocomplete-on-separate-index`](references/query-build-autocomplete-on-separate-index.md) — latency isolation

### 6. Retrieval Strategy (MEDIUM-HIGH)

- [`retrieve-use-filter-clauses-for-exact-matches`](references/retrieve-use-filter-clauses-for-exact-matches.md) — filter cache wins
- [`retrieve-use-bool-structure-deliberately`](references/retrieve-use-bool-structure-deliberately.md) — must vs should vs filter
- [`retrieve-run-expensive-signals-in-rescore`](references/retrieve-run-expensive-signals-in-rescore.md) — rescore window limits cost
- [`retrieve-combine-bm25-and-knn-via-hybrid-search`](references/retrieve-combine-bm25-and-knn-via-hybrid-search.md) — lexical plus semantic
- [`retrieve-paginate-with-search-after`](references/retrieve-paginate-with-search-after.md) — constant-cost deep pagination
- [`retrieve-choose-embedding-model-deliberately`](references/retrieve-choose-embedding-model-deliberately.md) — re-embedding is expensive

### 7. Relevance and Ranking (MEDIUM-HIGH)

- [`rank-tune-bm25-parameters-last`](references/rank-tune-bm25-parameters-last.md) — upstream levers first
- [`rank-use-function-score-for-business-signals`](references/rank-use-function-score-for-business-signals.md) — explicit named functions
- [`rank-deploy-ltr-only-after-golden-set-exists`](references/rank-deploy-ltr-only-after-golden-set-exists.md) — supervised learning needs labels
- [`rank-apply-diversity-at-rank-time`](references/rank-apply-diversity-at-rank-time.md) — after scoring, not before
- [`rank-normalise-scores-across-retrieval-primitives`](references/rank-normalise-scores-across-retrieval-primitives.md) — comparable scales

### 8. Search and Recommender Blending (MEDIUM)

- [`blend-use-search-alone-for-specific-intent`](references/blend-use-search-alone-for-specific-intent.md) — precision queries
- [`blend-combine-search-and-personalisation-scores`](references/blend-combine-search-and-personalisation-scores.md) — normalised weighted sum
- [`blend-keep-hybrid-blending-explainable`](references/blend-keep-hybrid-blending-explainable.md) — traceable results
- [`blend-never-return-zero-results`](references/blend-never-return-zero-results.md) — guaranteed cascade to non-empty

### 9. Measurement and Experimentation (MEDIUM)

- [`measure-define-session-success-per-surface`](references/measure-define-session-success-per-surface.md) — one definition per surface
- [`measure-track-ndcg-mrr-zero-result-rate`](references/measure-track-ndcg-mrr-zero-result-rate.md) — three metrics for one picture
- [`measure-track-reformulation-rate-as-failure-signal`](references/measure-track-reformulation-rate-as-failure-signal.md) — cheapest failure metric
- [`measure-use-click-models-for-implicit-judgments`](references/measure-use-click-models-for-implicit-judgments.md) — scale beyond human judges
- [`measure-run-interleaving-as-cheap-ab-proxy`](references/measure-run-interleaving-as-cheap-ab-proxy.md) — 10x less sample needed

### 10. Instrumentation, Dashboards and Decision Triggers (MEDIUM)

- [`monitor-log-every-query-with-full-context`](references/monitor-log-every-query-with-full-context.md) — structured replayable events
- [`monitor-scrub-pii-from-query-logs`](references/monitor-scrub-pii-from-query-logs.md) — redact before warehouse ingestion
- [`monitor-build-search-health-dashboard`](references/monitor-build-search-health-dashboard.md) — threshold lines, colour bands
- [`monitor-alert-on-decision-triggers`](references/monitor-alert-on-decision-triggers.md) — quality metrics, not error rates
- [`monitor-track-ranking-stability-churn`](references/monitor-track-ranking-stability-churn.md) — RBO churn as leading indicator
- [`monitor-run-weekly-search-quality-review`](references/monitor-run-weekly-search-quality-review.md) — calendar-driven ritual

## Planning and Improving

Two playbooks compose the rules into end-to-end workflows:

- [`references/playbooks/planning.md`](references/playbooks/planning.md) — Plan a new marketplace retrieval system from scratch. Nine-step workflow from intent audit through the first A/B-tested online lift, with explicit exit criteria per step.
- [`references/playbooks/improving.md`](references/playbooks/improving.md) — Diagnose and improve an existing retrieval system. Decision tree that walks through telemetry, index freshness, coverage, baseline gap, cold start, segment regressions, and algorithm iteration in that order, with hand-off points to `marketplace-personalisation` when the bottleneck is personalisation-specific.

Read the playbooks first when the task is "design a new search and recommender project"
or "this retrieval system needs to get better". Read individual rules when a specific
question arises during implementation or review.

## How to Use

- Read [`references/_sections.md`](references/_sections.md) for category structure and cascade rationale.
- Read [`gotchas.md`](gotchas.md) for diagnostic lessons accumulated from prior incidents.
- Read [`references/playbooks/planning.md`](references/playbooks/planning.md) to plan a new system.
- Read [`references/playbooks/improving.md`](references/playbooks/improving.md) to diagnose an existing one.
- Read individual rule files when a specific task matches the rule title.
- Use [`assets/templates/_template.md`](assets/templates/_template.md) to author new rules as the skill grows.

## Related Skills

- **`marketplace-personalisation`** — The companion skill covering AWS Personalize implementation, impression tracking, schema design, two-sided matching, feedback loops, and the personalisation-specific diagnostic playbook. Hand off to this skill when the diagnostic identifies a personalisation-specific bottleneck.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [references/playbooks/planning.md](references/playbooks/planning.md) | Plan a new retrieval system |
| [references/playbooks/improving.md](references/playbooks/improving.md) | Diagnose an existing retrieval system |
| [gotchas.md](gotchas.md) | Accumulated diagnostic lessons (living) |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, discipline, references |
