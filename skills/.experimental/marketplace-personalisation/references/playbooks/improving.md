# Improvement Playbook: Diagnosing an Existing Recommender

This playbook is a decision tree that walks through diagnosing an existing two-sided
marketplace recommender and choosing the next intervention. It applies the theory-of-constraints
principle from [`simple-find-bottleneck-first`](../simple-find-bottleneck-first.md): there
is always exactly one bottleneck, work on any other layer is wasted, and finding the
bottleneck takes hours while fixing the wrong thing takes weeks.

Use this playbook when:

- The recommender "mostly works" but online metrics are flat or declining
- A new experiment fails to beat the current production model
- A seeker complaint, a provider complaint, or a product manager intuition suggests something is wrong
- Online metrics have drifted without any deploy — silent regression
- The team is debating whether to tune the current model, retrain, or rewrite
- Planning the next quarter of recsys work and asking "what is the highest-leverage change"

## The Diagnostic Sequence

Run the diagnostic in order. Each step is a cheap check (hours, not weeks) that either
clears the layer or points to a specific rule. Do not skip steps — the bottleneck is
almost always earlier than the team thinks it is.

```
   Start
     │
     ▼
  ┌─────────────────────────────────────────────────────┐
  │ 1. Telemetry audit                                   │
  │    → impression coverage, outcome coverage,          │
  │      requestId join rate, dismissal capture          │
  │    ← fix: track-* rules                              │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 2. Metadata freshness audit                          │
  │    → Items dataset p99 staleness                     │
  │    ← fix: schema-enforce-metadata-freshness          │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 3. Coverage and Gini audit                           │
  │    → catalog coverage, exposure Gini, top-N Gini     │
  │    ← fix: loop-detect-death-spirals, loop-reserve-*  │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 4. Baseline gap audit                                │
  │    → compare current model vs popularity baseline    │
  │    ← fix: simple-ship-popularity-baseline            │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 5. Two-sided fairness audit                          │
  │    → provider exposure distribution, decline rates   │
  │    ← fix: match-rank-mutual-fit, match-cap-*         │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 6. Segment regression audit                          │
  │    → cold/warm, new/repeat, per-region breakdown     │
  │    ← fix: cold-*, obs-slice-metrics-by-segment       │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 7. Online/offline divergence audit                   │
  │    → Δ offline AUC vs Δ online booking rate          │
  │    ← fix: obs-watch-online-offline-divergence        │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 8. Algorithm iteration                               │
  │    → recipe choice, HPO, pipeline changes            │
  │    ← fix: recipe-*, careful A/B                      │
  └─────────────────────────────────────────────────────┘
```

Every exit routes to specific rules. Steps 1-7 are cheap to run and typically surface
the real bottleneck. Step 8 — algorithm work — is the last resort, not the first.

## Step 1 — Telemetry Audit

**Question:** is the instrumentation actually recording what we think it is?

Run the audit from [`simple-audit-before-build`](../simple-audit-before-build.md):

| Check | Threshold | Bottleneck Rule |
|-------|-----------|-----------------|
| Fraction of sessions with ≥1 `impression` event | ≥95% | [`track-log-impressions-alongside-clicks`](../track-log-impressions-alongside-clicks.md) |
| Fraction of `booking_completed` events that join to an impression by `requestId` | ≥80% | [`track-stamp-events-with-request-id`](../track-stamp-events-with-request-id.md) |
| Fraction of bookings that emit `booking_completed` | ≥90% | [`track-measure-outcomes-not-clicks`](../track-measure-outcomes-not-clicks.md) |
| Fraction of negative actions captured (dismiss, hide) | ≥70% | [`track-capture-negative-signals`](../track-capture-negative-signals.md) |
| Fraction of events stamped with stable opaque IDs (not URLs or slugs) | 100% | [`track-use-stable-opaque-item-ids`](../track-use-stable-opaque-item-ids.md) |
| Event pipeline uses PutEvents not nightly S3 | Yes | [`track-stream-events-via-putevents`](../track-stream-events-via-putevents.md) |

**If any check fails:** stop here. Fix instrumentation before touching the model. A
recommender trained on broken telemetry is confidently wrong, and every subsequent layer
inherits the damage. Expect this step to be the bottleneck in 40-60% of diagnoses.

## Step 2 — Metadata Freshness Audit

**Question:** is the Items dataset accurate, or does Personalize think listings are available
when they are actually booked out?

Measure the p99 staleness of the Items dataset versus the source-of-truth catalog:

```python
def items_freshness_p99() -> timedelta:
    listings = source_catalog.recent_active(limit=10_000)
    personalize_items = personalize_items_dataset.fetch_all()

    deltas = []
    for listing in listings:
        personalize_item = personalize_items.get(listing.id)
        if personalize_item is None:
            deltas.append(timedelta(days=365))
            continue
        deltas.append(listing.updated_at - personalize_item.updated_at)
    return percentile(deltas, 99)
```

**Threshold:** p99 staleness < 2 hours. Anything higher means Personalize is ranking
ghosts — listings that look attractive in the dataset but are not really available.

**If this check fails:** fix per [`schema-enforce-metadata-freshness`](../schema-enforce-metadata-freshness.md) —
wire PutItems to every metadata change event, not the weekly batch import.

## Step 3 — Coverage and Gini Audit

**Question:** is the recommender in a death spiral?

Fetch the weekly exposure metrics:

| Metric | Threshold | Bottleneck Rule |
|--------|-----------|-----------------|
| Catalog coverage (% items recommended in last 7 days) | ≥60% for mature catalog | [`loop-detect-death-spirals`](../loop-detect-death-spirals.md) |
| Exposure Gini top-24 | < 0.65 | [`loop-detect-death-spirals`](../loop-detect-death-spirals.md) |
| Gini trend over 6 weeks | Not monotonically increasing | [`loop-reserve-random-exploration`](../loop-reserve-random-exploration.md) |
| Provider exposure share p99 | < 10% in rolling hour window | [`infer-enforce-exposure-caps`](../infer-enforce-exposure-caps.md) |

**If any check fails:** inject exploration immediately — both a random exploration slice
(see [`loop-reserve-random-exploration`](../loop-reserve-random-exploration.md)) and
promotional slots for fresh inventory
(see [`cold-reserve-exploration-slots`](../cold-reserve-exploration-slots.md)).
Death spirals compound — every week of delay makes recovery harder.

## Step 4 — Baseline Gap Audit

**Question:** does the current production model still beat a popularity baseline?

Run a small A/B test against a retained popularity baseline per
[`simple-measure-gap-to-baseline`](../simple-measure-gap-to-baseline.md). If the baseline
was retired months ago, rebuild it in a day and run the test.

**Threshold:** production model should lift booking-completed-per-session by ≥5% over
popularity baseline, and the delta should not be declining over time.

**If the check fails:** the model has drifted below the baseline — likely due to accumulated
changes in data shape, schema, or training configuration. Rollback to an earlier known-good
solution version, or rebuild from a clean baseline.

## Step 5 — Two-Sided Fairness Audit

**Question:** is the ranker producing one-sided results that providers will reject?

Compute two metrics:

| Metric | Threshold | Bottleneck Rule |
|--------|-----------|-----------------|
| Provider decline rate on top-10 recommendations | < 15% | [`match-rank-mutual-fit`](../match-rank-mutual-fit.md) |
| Top-1 provider exposure share | < 3% of all impressions | [`match-cap-provider-exposure`](../match-cap-provider-exposure.md) |
| Capacity utilisation variance across providers | Reasonably narrow | [`match-model-capacity-constraints`](../match-model-capacity-constraints.md) |

**If a check fails:** wire provider-accept prediction into the ranking objective, enforce
exposure caps, and apply capacity-discounted scoring. This is typically a 1-2 week change
and produces measurable conversion lift at the provider-side level.

## Step 6 — Segment Regression Audit

**Question:** is the aggregate metric hiding a segment regression?

Slice every primary metric (booking rate, CTR, session length, mutual-rating average) by:

- Cold cohort vs warm cohort (`lifetime_events < 5` vs `≥ 5`)
- New users vs repeat users (`first_session` vs `≥ 2 sessions`)
- Demand-heavy segments vs supply-heavy segments
- By region, device, referral source

**If any segment regresses ≥5% below aggregate:** that segment is the bottleneck. For
cold cohorts, route to `cold-*` rules. For specific regions, check supply/demand ratio
and consider segment-aware ranking per [`match-balance-supply-demand`](../match-balance-supply-demand.md).

## Step 7 — Online/Offline Divergence Audit

**Question:** is the offline evaluation metric misleading the team?

Compare the delta in offline AUC vs the delta in online booking rate across the last
five solution versions. If offline keeps rising while online is flat, the team is overfitting
the offline proxy — see [`obs-watch-online-offline-divergence`](../obs-watch-online-offline-divergence.md).

**If divergence is persistent:** rebuild the offline evaluation. Use a held-out time
window (not a random split) so the evaluation mirrors real use, and weight the evaluation
by outcome not click.

## Step 8 — Algorithm Iteration

**Only run this step if Steps 1-7 pass.** Algorithm changes are the most expensive and
lowest-leverage intervention in most recommender systems, and the team arrives here rarely.

Options, in order of cost:

1. **Tune event weights** (cheap, no retraining) — see [`loop-optimize-completed-outcome`](../loop-optimize-completed-outcome.md).
2. **Rich item metadata** (moderate, requires schema discussion) — see [`cold-use-v2-recipe-with-metadata`](../cold-use-v2-recipe-with-metadata.md).
3. **Context fields at inference** (cheap if schema allows) — see [`schema-include-context-everywhere`](../schema-include-context-everywhere.md).
4. **Candidate-generation → re-rank pipeline** (expensive, 2-4 weeks) — see [`recipe-build-candidate-rerank-pipeline`](../recipe-build-candidate-rerank-pipeline.md).
5. **HPO** (only with a ship/kill criterion set upfront) — see [`recipe-defer-hpo-until-baseline-measured`](../recipe-defer-hpo-until-baseline-measured.md) and [`simple-budget-complexity`](../simple-budget-complexity.md).

Every option requires an A/B test and a written ship/kill criterion. No exceptions.

## When the Playbook Says to Rollback

Some bottlenecks take days or weeks to fix. While the fix is in progress, revert to a
known-good state rather than letting the broken system serve real users. Rollback options,
in order of reach:

- Change traffic allocation to route the offending variant to 0% immediately
- Promote the previous production solution version
- Fall back to the popularity baseline (the permanent 3% bucket scales up)
- For a telemetry failure, stop training on the corrupted window until the pipeline is fixed

The goal of the rollback is to stop the bleeding — full diagnosis and fix come after,
on a timeline that does not include the word "hotfix".

## Using the Playbook in a Design Review

When the team debates "what should we work on next quarter", run through Steps 1-7 with
real numbers on a spreadsheet before the meeting. The step that fails — or the step with
the weakest margin over threshold — is the next quarter's work. Steps that pass comfortably
can be ignored. This converts recsys planning from an opinion exercise into a deterministic
one and usually collapses a two-week debate into a one-hour decision.
