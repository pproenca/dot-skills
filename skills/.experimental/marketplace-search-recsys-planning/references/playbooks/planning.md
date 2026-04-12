# Planning Playbook: Building a Marketplace Retrieval System from Scratch

This playbook walks through planning a new search and recommendation system for a
two-sided marketplace end-to-end. It composes the rules from every category into a
nine-step workflow that starts with user-intent audit and ends with the first A/B-tested
online lift over a popularity baseline. At the end, the playbook hands off to
`marketplace-personalisation` when personalisation-specific work begins.

Use this playbook when:

- Launching a new retrieval surface (search, homefeed, category, item-page related)
- Rebuilding a retrieval system that has accumulated too much technical debt
- Planning the first personalisation or search work in a product that currently has none
- Preparing a design document or RFC for a new retrieval initiative

Skip to the [Improvement Playbook](./improving.md) if the system already exists and
the question is "how do we make it better" rather than "how do we design it".

## Summary

| Step | Goal | Time Budget | Primary Rules |
|------|------|-------------|---------------|
| 1. Audit live queries | Understand actual user intent distribution | 1 day | `intent-audit-live-query-logs-first` |
| 2. Define intent classes and surfaces | Intent-to-surface mapping as a written artefact | 2-3 days | `intent-*`, `arch-map-surface-to-retrieval-primitive` |
| 3. Build a golden query set | Offline evaluation reference | 1 week | `plan-build-golden-query-set-first`, `plan-version-the-golden-set` |
| 4. Instrument telemetry and gate the work | Audit coverage before any model work | 3-5 days | `plan-audit-before-you-build`, `monitor-log-every-query-with-full-context` |
| 5. Design the OpenSearch index and analyzers | Near-immutable data shape | 1 week | `index-*` (all 6) |
| 6. Build candidate-gen and re-rank pipeline | Two-stage retrieval | 1-2 weeks | `arch-split-candidate-generation-from-ranking`, `retrieve-*`, `rank-*` |
| 7. Wire blending, fallbacks and diversity | Never return zero results | 1 week | `blend-*` (all 5), `rank-apply-diversity-at-rank-time` |
| 8. Build dashboards and decision triggers | Measurement becomes ongoing decision-making | 3-5 days | `monitor-*` (all 5), `measure-*` (all 5) |
| 9. Run A/B against popularity baseline | Prove the lift over the non-ML baseline | 2-4 weeks | `measure-run-interleaving-as-cheap-ab-proxy`, `plan-find-bottleneck-before-optimising` |
| 10. Hand off to personalisation skill | Continue with AWS Personalize work | — | `plan-handoff-to-personalisation-skill`, `marketplace-personalisation` |

Total: ~8-12 weeks from zero to a shipped A/B-tested retrieval system with online lift
over a popularity baseline and a working monitor + decision-trigger layer. Every step
is a gate: do not proceed until the current step passes its exit criterion.

## Step 1 — Audit Live Queries

**Goal:** a one-page report describing the actual query distribution.

Fetch 30 days of query logs from the existing product (if any) or the closest
equivalent. Measure: total query volume, percentage containing a city token, percentage
containing a date, mean token count, zero-result rate, reformulation rate, the top 100
queries by volume, and the distribution of intent classes (navigational, transactional,
exploratory). See [`intent-audit-live-query-logs-first`](../intent-audit-live-query-logs-first.md).

**Exit criterion:** a committed `audit_query_log_YYYY-MM-DD.md` artefact with the
numbers and the team-reviewed categorisation of queries.

## Step 2 — Define Intent Classes and Surfaces

**Goal:** a single-source-of-truth routing table mapping every product surface to a
retrieval primitive, and every intent class to a handler.

Write the surface-to-primitive table as code (not a doc) so the routing is enforced and
testable. See [`arch-map-surface-to-retrieval-primitive`](../arch-map-surface-to-retrieval-primitive.md),
[`arch-route-surfaces-deliberately`](../arch-route-surfaces-deliberately.md), and
[`intent-map-queries-to-intent-classes`](../intent-map-queries-to-intent-classes.md).

**Exit criterion:** `surface_routes.py` committed with every surface mapped, each entry
documenting the primitive, the owner, and the rationale.

## Step 3 — Build a Golden Query Set

**Goal:** a frozen, versioned query set with expected top results, graded by human
judges.

Select 300-500 queries spanning all intent classes, including easy queries (clear
winners) and hard queries (ambiguous intent). Grade each query with 10-24 result
listings rated 0-3 for relevance. Freeze the set with a version tag. See
[`plan-build-golden-query-set-first`](../plan-build-golden-query-set-first.md) and
[`plan-version-the-golden-set`](../plan-version-the-golden-set.md).

**Exit criterion:** `golden_set/v1.0-frozen-YYYY-MM-DD.jsonl` committed with at least
300 queries and judgments.

## Step 4 — Instrument Telemetry and Gate the Work

**Goal:** telemetry audit passes before any model or retrieval work begins.

Verify impression coverage ≥95%, outcome coverage ≥90%, request-ID join rate ≥98%, zero-
result capture 100%, and reformulation detection ≥90%. If any check fails, fix the
telemetry first; model work waits. See
[`plan-audit-before-you-build`](../plan-audit-before-you-build.md) and
[`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md).

**Exit criterion:** audit report committed as `audit_telemetry_YYYY-MM-DD.md` with all
checks passing.

## Step 5 — Design the OpenSearch Index and Analyzers

**Goal:** mappings, analyzers, and index templates that will last years.

OpenSearch mappings are effectively immutable — every field is a lifetime commitment.
Follow every rule in the `index-*` category:

- Design conservatively per [`index-design-mappings-conservatively`](../index-design-mappings-conservatively.md)
- Use keyword + text multi-fields per [`index-use-keyword-and-text-as-multi-fields`](../index-use-keyword-and-text-as-multi-fields.md)
- Match analyzers at index and query time per [`index-match-index-and-query-time-analyzers`](../index-match-index-and-query-time-analyzers.md)
- Use language analyzers per [`index-use-language-analyzers-for-language-fields`](../index-use-language-analyzers-for-language-fields.md)
- Separate searchable from display fields per [`index-separate-searchable-from-display-fields`](../index-separate-searchable-from-display-fields.md)
- Use index templates per [`index-use-index-templates-for-consistency`](../index-use-index-templates-for-consistency.md)

**Exit criterion:** mapping files committed, reviewed by the team, and each field has a
one-line rationale in comments.

## Step 6 — Build Candidate-Generation and Re-Rank Pipeline

**Goal:** a two-stage pipeline where retrieval enforces hard rules and the re-ranker
applies relevance to the feasible set.

Follow [`arch-split-candidate-generation-from-ranking`](../arch-split-candidate-generation-from-ranking.md).
Apply the retrieval rules: filter clauses for exact matches, deliberate bool structure,
rescoring for expensive signals, hybrid BM25+KNN where semantic recall matters, and
search_after for deep pagination.

Apply the ranking rules: function_score with named business signals, diversity at rank
time, normalised scores for hybrid, and defer BM25 tuning until upstream levers are
exhausted.

**Exit criterion:** pipeline returns non-empty, feasible, ranked results for a
smoke-test set of queries; offline NDCG@10 against the golden set is above the
popularity baseline.

## Step 7 — Wire Blending, Fallbacks and Diversity

**Goal:** every surface guarantees non-empty response, applies diversity caps, and
blends search with recommendations where appropriate.

Every rule in the `blend-*` category applies here. Wire search-alone for specific intent,
fallback to recommendations on zero results, normalised score combination, explainable
traces, and the guaranteed-non-empty cascade.

**Exit criterion:** no surface can return a zero-result response; diversity cap enforced
on every response; blending traces logged.

## Step 8 — Build Dashboards and Decision Triggers

**Goal:** measurement is converted into ongoing decision-making with weekly rituals.

Every rule in the `monitor-*` category applies here:

- Log every query with full context per [`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md)
- Build the search health dashboard with threshold lines per [`monitor-build-search-health-dashboard`](../monitor-build-search-health-dashboard.md)
- Alert on decision-triggers, not just errors, per [`monitor-alert-on-decision-triggers`](../monitor-alert-on-decision-triggers.md)
- Track ranking churn per [`monitor-track-ranking-stability-churn`](../monitor-track-ranking-stability-churn.md)
- Schedule the weekly review ritual per [`monitor-run-weekly-search-quality-review`](../monitor-run-weekly-search-quality-review.md)

Every rule in the `measure-*` category applies here:

- Per-surface session success definitions per [`measure-define-session-success-per-surface`](../measure-define-session-success-per-surface.md)
- NDCG, MRR, zero-result rate per [`measure-track-ndcg-mrr-zero-result-rate`](../measure-track-ndcg-mrr-zero-result-rate.md)
- Reformulation rate as a failure signal per [`measure-track-reformulation-rate-as-failure-signal`](../measure-track-reformulation-rate-as-failure-signal.md)
- Click-model-based implicit judgments per [`measure-use-click-models-for-implicit-judgments`](../measure-use-click-models-for-implicit-judgments.md)
- Interleaving for cheap A/B per [`measure-run-interleaving-as-cheap-ab-proxy`](../measure-run-interleaving-as-cheap-ab-proxy.md)

**Exit criterion:** dashboard published, alerts configured with runbook pointers to
`playbooks/improving.md`, weekly review on the calendar.

## Step 9 — Run A/B Against the Popularity Baseline

**Goal:** statistically significant online lift over a popularity baseline.

Run the A/B test with popularity as control and the new retrieval pipeline as treatment.
Slice metrics by segment. Watch online versus offline divergence. Define the ship/kill
criterion upfront (typically: session_success_rate ≥ +2% with p<0.05, no segment
regresses by >1%, zero-result rate does not rise).

**Exit criterion:** shipped decision recorded in the decisions log with the reason
and the next step.

## Step 10 — Hand Off to the Personalisation Skill

Once the retrieval foundations are in place and measured, subsequent work on warm-cohort
personalisation, impression tracking, two-sided matching, feedback loops, and AWS
Personalize-specific patterns lives in the companion skill `marketplace-personalisation`.
See [`plan-handoff-to-personalisation-skill`](../plan-handoff-to-personalisation-skill.md).

The transition is clean: this skill has delivered a retrieval system with instrumentation
and a measurement layer; the personalisation skill takes it and adds the personalisation
arm on top. Its planning playbook picks up where this one ends.
