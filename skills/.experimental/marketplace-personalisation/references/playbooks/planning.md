# Planning Playbook: Building a Two-Sided Recommender from Scratch

This playbook walks through designing a new recommendation system for a two-sided
marketplace end-to-end. It composes the rules from every category into a nine-step
workflow that starts with instrumentation and ends with the first A/B-tested ML lift
over a popularity baseline.

Use this playbook when:

- Launching a new surface (homefeed, search, category page, related-items shelf)
- Rebuilding a recommender that has accumulated too much technical debt to incrementally fix
- Planning the first personalisation work in a product that currently has none
- Preparing a design document or RFC for a new recsys initiative

Skip to the [Improvement Playbook](./improving.md) if the system already exists and
the question is "how do we make it better" rather than "how do we design it".

## Summary

| Step | Goal | Time Budget | Primary Rules |
|------|------|-------------|---------------|
| 1. Define the mutual-fit outcome | State the single metric that defines success | 1 day | `match-rank-mutual-fit`, `simple-audit-before-build` |
| 2. Instrument the lifecycle | Capture impressions, clicks, outcomes, negatives | 1-2 weeks | `track-*` (all 6 rules) |
| 3. Ship a popularity baseline | Non-ML reference point in production | 1 week | `simple-ship-popularity-baseline`, `simple-measure-gap-to-baseline` |
| 4. Design the dataset schemas | User, Item, Interactions — conservatively | 3-5 days | `schema-*` (all 6 rules) |
| 5. Import historical data | Build dataset group and first import | 1 week | `schema-design-conservatively`, `recipe-default-to-user-personalization-v2` |
| 6. Build candidate-gen + re-rank | Retrieval before ranking | 1-2 weeks | `recipe-build-candidate-rerank-pipeline`, `match-hard-filter-before-ranking` |
| 7. Apply two-sided matching | Mutual fit, fairness, capacity | 1 week | `match-*`, `infer-*` |
| 8. Close the feedback loop | Exploration, decay, outcome weighting | 1 week | `loop-*` (all 5 rules) |
| 9. Launch A/B and measure | Compare ML against baseline | 2-4 weeks | `obs-*` (all 5 rules) |

Total: ~8-12 weeks from zero to a shipped A/B-tested ML model with online lift over
a popularity baseline. Every step is a gate: do not proceed to the next step until the
current step passes its exit criterion.

## Step 1 — Define the Mutual-Fit Outcome

**Goal:** one sentence that states the primary metric the recommender will optimise.

A two-sided marketplace has more than one plausible objective: click rate, booking rate,
booking rate weighted by provider acceptance, repeat booking rate, mutual-rating average,
long-term marketplace liquidity. Pick one before writing any code — and write down why
the other objectives were rejected. See [`simple-audit-before-build`](../simple-audit-before-build.md)
for the rationale.

**Exit criterion:** a written decision naming the primary metric, its formula, and the
definition of a "successful match" (typically `booking_completed AND mutual_rating >= 4`).

## Step 2 — Instrument the Lifecycle

**Goal:** every stage of the seeker-to-completion journey emits an event to Personalize.

Build the event schema and telemetry before the model. Every rule in the `track-*`
category applies here. Minimum viable instrumentation:

| Event | Rule | Fires When |
|-------|------|------------|
| `impression` | [`track-log-impressions-alongside-clicks`](../track-log-impressions-alongside-clicks.md) | Listing enters viewport |
| `click` | [`track-stamp-events-with-request-id`](../track-stamp-events-with-request-id.md) | Seeker taps a listing card |
| `dismiss` | [`track-capture-negative-signals`](../track-capture-negative-signals.md) | Seeker marks "not for me" |
| `booking_request` | [`track-measure-outcomes-not-clicks`](../track-measure-outcomes-not-clicks.md) | Booking form submitted |
| `booking_confirmed` | [`track-measure-outcomes-not-clicks`](../track-measure-outcomes-not-clicks.md) | Provider accepts |
| `booking_completed` | [`track-measure-outcomes-not-clicks`](../track-measure-outcomes-not-clicks.md) | Stay finished and rated |

Every event carries a `requestId` that joins it back to the ranker response, per
[`track-stamp-events-with-request-id`](../track-stamp-events-with-request-id.md).
Stream via PutEvents per [`track-stream-events-via-putevents`](../track-stream-events-via-putevents.md);
bulk import is only for historical backfill.

**Exit criterion:** instrumentation audit shows impression coverage ≥95%, booking_completed
coverage ≥90%, and requestId join rate ≥98%. See [`simple-audit-before-build`](../simple-audit-before-build.md)
for the audit format.

## Step 3 — Ship a Popularity Baseline

**Goal:** serve a non-ML top-N through the real inference path.

Before any Personalize work, ship a popularity baseline end-to-end: retrieve top-N
completed-booking-count listings from the feasible set, render them through the real
homefeed component, log impressions and outcomes. The baseline becomes the permanent
control against which every future model is measured — see
[`simple-ship-popularity-baseline`](../simple-ship-popularity-baseline.md) and
[`simple-measure-gap-to-baseline`](../simple-measure-gap-to-baseline.md).

**Exit criterion:** popularity baseline serves production traffic behind a feature flag,
with online metrics dashboarded per [`obs-always-ab-test`](../obs-always-ab-test.md).

## Step 4 — Design the Dataset Schemas

**Goal:** three immutable schemas (Interactions, Items, Users) that will last years.

Schemas are effectively immutable in Personalize — adding a field means creating a new
dataset group and re-importing all history. Follow every rule in the `schema-*` category:

- Keep Items and Users thin per [`schema-keep-user-item-thin`](../schema-keep-user-item-thin.md)
- Use categorical fields for bounded vocabularies per [`schema-prefer-categorical-fields`](../schema-prefer-categorical-fields.md)
- Include context fields that will be populated at inference per [`schema-include-context-everywhere`](../schema-include-context-everywhere.md)
- Weight event types with a plan for EVENT_VALUE per [`schema-weight-event-value`](../schema-weight-event-value.md)

**Exit criterion:** schemas written as Avro JSON, reviewed by the team, and committed
to the repository. Every field has a one-line rationale.

## Step 5 — Import Historical Data

**Goal:** dataset group populated with historical events, items, and users.

Bulk import via S3 for the historical window (typically 90-365 days of interactions).
Run PutItems / PutUsers in parallel for the current state of the catalog and user base.
Verify dataset sizes meet AWS Personalize minimums: 50 users, 50 items, 1000 active
interactions — below this, results degrade per the
[AWS Personalize cheat sheet](https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md).

**Exit criterion:** a dataset group with all three datasets imported, schemas matching
Step 4, and row counts logged as a sanity check.

## Step 6 — Build Candidate Generation and Re-rank

**Goal:** a two-layer pipeline where retrieval enforces hard rules and a re-ranker applies
personalisation to the feasible set.

Follow [`recipe-build-candidate-rerank-pipeline`](../recipe-build-candidate-rerank-pipeline.md).
The candidate generator uses existing catalog search (region, date, species, legal
compliance) and returns 100-500 items. The re-ranker is a PERSONALIZED_RANKING_v2 campaign
that takes the candidate list and returns it sorted by relevance — see
[`recipe-personalized-ranking-as-reranker`](../recipe-personalized-ranking-as-reranker.md).

Alternatively, for surfaces where the feasible set is small enough to pre-filter via
Personalize filters, USER_PERSONALIZATION_v2 with a filter can serve as both generator
and ranker in one call — see
[`recipe-default-to-user-personalization-v2`](../recipe-default-to-user-personalization-v2.md).

**Exit criterion:** the pipeline returns a non-empty, feasible, personalised list for
a smoke-test set of test seekers. Cached responses expire within 60-120 seconds per
[`infer-cache-responses-short-ttl`](../infer-cache-responses-short-ttl.md).

## Step 7 — Apply Two-Sided Matching

**Goal:** the ranker accounts for both sides' preferences and enforces fairness.

Every rule in the `match-*` category applies here. Wire the ranker to:

- Score by mutual fit per [`match-rank-mutual-fit`](../match-rank-mutual-fit.md)
- Enforce feasibility in retrieval per [`match-hard-filter-before-ranking`](../match-hard-filter-before-ranking.md)
- Cap provider exposure per [`match-cap-provider-exposure`](../match-cap-provider-exposure.md)
- Discount by remaining capacity per [`match-model-capacity-constraints`](../match-model-capacity-constraints.md)
- Route per segment-level liquidity per [`match-balance-supply-demand`](../match-balance-supply-demand.md)

Apply business rules after model scoring per
[`infer-rerank-rules-after-model`](../infer-rerank-rules-after-model.md), deduplicate by
provider per [`infer-deduplicate-canonical-entity`](../infer-deduplicate-canonical-entity.md),
and enforce rolling exposure caps per [`infer-enforce-exposure-caps`](../infer-enforce-exposure-caps.md).

**Exit criterion:** top-24 responses on a diverse seeker sample show no provider appearing
more than twice, feasibility 100%, and exposure distribution reasonably balanced across
the feasible set.

## Step 8 — Close the Feedback Loop

**Goal:** the system learns from every session without reinforcing bias.

Every rule in the `loop-*` category applies here. Wire:

- Slot logging per [`loop-log-ranking-slot`](../loop-log-ranking-slot.md)
- Random exploration slice (3-5%) per [`loop-reserve-random-exploration`](../loop-reserve-random-exploration.md)
- Outcome-weighted training per [`loop-optimize-completed-outcome`](../loop-optimize-completed-outcome.md)
- Event-weight decay per [`loop-decay-event-weights`](../loop-decay-event-weights.md)
- Death-spiral detection per [`loop-detect-death-spirals`](../loop-detect-death-spirals.md)

**Exit criterion:** exploration slice is logged with propensity, slot is recorded on
every impression, and the weekly exposure-Gini metric is dashboarded.

## Step 9 — Launch A/B and Measure

**Goal:** an online A/B test shows statistically significant lift over the popularity baseline.

Run the full A/B test described in [`obs-always-ab-test`](../obs-always-ab-test.md)
with the popularity baseline as control and the Personalize pipeline as treatment. Slice
metrics by segment per [`obs-slice-metrics-by-segment`](../obs-slice-metrics-by-segment.md);
watch the online-versus-offline divergence per
[`obs-watch-online-offline-divergence`](../obs-watch-online-offline-divergence.md).

Define the ship/kill criterion upfront per
[`simple-budget-complexity`](../simple-budget-complexity.md). A typical criterion:
ship if booking-completed-per-session lifts ≥2% with p<0.05, no segment regresses by
>1%, and exposure-Gini does not rise; otherwise kill and diagnose via the
[improvement playbook](./improving.md).

**Exit criterion:** a shipped decision (ship or kill), documented in the experiments log,
with the reason and the next step.

## After Launch

The [`improvement playbook`](./improving.md) takes over. Every new experiment is framed
as a delta against the current production model AND the retained popularity baseline,
so drift against the baseline is detectable per
[`simple-measure-gap-to-baseline`](../simple-measure-gap-to-baseline.md).
