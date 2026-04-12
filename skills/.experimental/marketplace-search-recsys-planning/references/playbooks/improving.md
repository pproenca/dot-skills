# Improvement Playbook: Diagnosing an Existing Retrieval System

This playbook is a decision tree that walks through diagnosing an existing marketplace
retrieval system and choosing the next intervention. It applies the theory-of-constraints
principle from [`plan-find-bottleneck-before-optimising`](../plan-find-bottleneck-before-optimising.md):
there is always exactly one bottleneck, work on any other layer is wasted, and finding
the bottleneck takes hours while fixing the wrong thing takes weeks.

Use this playbook when:

- Search or recommendations "mostly work" but online metrics are flat or declining
- A new ranking experiment fails to beat the current production model
- A seeker complaint, provider complaint, or product-manager intuition suggests something is wrong
- An alert from the decision-trigger dashboard fires
- Zero-result rate, reformulation rate, or ranking churn rose without an explanatory deploy
- Planning the next quarter of retrieval work and asking "what is the highest-leverage change"

## The Diagnostic Sequence

Run the diagnostic in order. Each step is a cheap check (hours, not weeks) that either
clears the layer or points to a specific rule or hand-off. Do not skip steps — the
bottleneck is almost always earlier than the team thinks it is. Steps are ordered by
cascade position, so earlier steps dominate later ones when they fail.

```
   Start
     │
     ▼
  ┌─────────────────────────────────────────────────────┐
  │ 1. Telemetry and logging audit                      │
  │    → query coverage, request-ID join, replay-able   │
  │    ← fix: plan-audit-before-you-build, monitor-*    │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 2. Intent mismatch audit                            │
  │    → query log versus intent classes                │
  │    ← fix: intent-* rules                            │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 3. Index and analyzer audit                         │
  │    → stemming, synonyms, multi-field layout         │
  │    ← fix: index-*, query-*                          │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 4. Retrieval correctness audit                      │
  │    → filter vs must, rescore, hybrid                │
  │    ← fix: retrieve-*                                │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 5. Zero-result and fallback audit                   │
  │    → blending cascade, fallback coverage            │
  │    ← fix: blend-*, arch-design-zero-result-fallback │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 6. Golden-set gap audit                             │
  │    → NDCG vs baseline, divergence trend             │
  │    ← fix: rank-*, plan-build-golden-query-set-first │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 7. Ranking churn and drift audit                    │
  │    → RBO vs previous release                        │
  │    ← fix: monitor-track-ranking-stability-churn     │
  └─────────────────────────────────────────────────────┘
     │
     ▼ pass
  ┌─────────────────────────────────────────────────────┐
  │ 8. Personalisation bottleneck audit                 │
  │    → impression tracking, feedback loops, cold start│
  │    ← HAND OFF: marketplace-personalisation skill    │
  └─────────────────────────────────────────────────────┘
```

Steps 1-7 are retrieval-layer checks owned by this skill. Step 8 is the hand-off to the
companion `marketplace-personalisation` skill, which has a deeper diagnostic playbook for
personalisation-specific bottlenecks.

## Step 1 — Telemetry and Logging Audit

**Question:** is the instrumentation actually recording what we think it is?

Run the audit from [`plan-audit-before-you-build`](../plan-audit-before-you-build.md) and
verify the structured query log from [`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md):

| Check | Threshold | Bottleneck Rule |
|-------|-----------|-----------------|
| Every query emits a structured log event | 100% | [`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md) |
| Each log event contains requestId, ranker_version, top_k, strategy | Yes | [`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md) |
| Reformulation detection works (sessions with 2+ queries within 60s are captured) | Yes | [`measure-track-reformulation-rate-as-failure-signal`](../measure-track-reformulation-rate-as-failure-signal.md) |
| Impression logs join to outcome logs by requestId | ≥98% | [`plan-audit-before-you-build`](../plan-audit-before-you-build.md) |
| Query volume on dashboard matches query volume in app logs | Within 2% | [`monitor-log-every-query-with-full-context`](../monitor-log-every-query-with-full-context.md) |

**If any check fails:** stop here. Fix telemetry first. A retrieval system analysed on
broken logs is diagnosed wrong every time. Expect this step to be the bottleneck in 40-60%
of cases.

## Step 2 — Intent Mismatch Audit

**Question:** is the system treating queries as the wrong intent class?

Classify a 7-day sample of queries and measure how often each intent class is routed to
the wrong strategy. A navigational query going through a hybrid ranker wastes computation
and loses precision; an exploratory query going through an exact-match ranker returns a
dead-end result set.

**Red flags:**
- Reformulation rate is high (>20%) on transactional queries
- Zero-result rate is high (>12%) on queries that are clearly valid

**If this check fails:** fix the intent classifier or the routing table. See all rules
in the `intent-*` category.

## Step 3 — Index and Analyzer Audit

**Question:** is the index shaped correctly for the query workload?

Run the golden query set through the production index and record which queries return
zero results, which return too few results, and which return obviously wrong results.

**Red flags:**
- "dog sitters" matches fewer listings than "dog sitter" (analyzer missing stemming)
- "pet carer" returns nothing when "dog sitter" has dozens of matches (missing synonyms)
- Filtering on "region:london" is slow (filter in must instead of filter context)
- Multi-language queries return wrong stems (missing language analyzers)

**If this check fails:** fix the index mappings or analyzer pipeline. See rules in the
`index-*` and `query-*` categories. Remember that some fixes require a reindex; plan
accordingly per [`index-design-mappings-conservatively`](../index-design-mappings-conservatively.md).

## Step 4 — Retrieval Correctness Audit

**Question:** is the query DSL making correct use of filter, bool, and rescore?

Inspect the production query body for common mistakes:

| Red flag | Fix rule |
|----------|----------|
| Exact-match conditions in `must` instead of `filter` | [`retrieve-use-filter-clauses-for-exact-matches`](../retrieve-use-filter-clauses-for-exact-matches.md) |
| Soft preferences in `must` when they should be `should` | [`retrieve-use-bool-structure-deliberately`](../retrieve-use-bool-structure-deliberately.md) |
| Expensive `script_score` running on the full candidate set | [`retrieve-run-expensive-signals-in-rescore`](../retrieve-run-expensive-signals-in-rescore.md) |
| Deep `from`/`size` pagination (> page 10) | [`retrieve-paginate-with-search-after`](../retrieve-paginate-with-search-after.md) |
| Lexical-only retrieval on paraphrase-heavy queries | [`retrieve-combine-bm25-and-knn-via-hybrid-search`](../retrieve-combine-bm25-and-knn-via-hybrid-search.md) |

## Step 5 — Zero-Result and Fallback Audit

**Question:** is the system ever returning zero results to a user?

Zero results should be rare (target: <5%) and should trigger a documented fallback
cascade. If zero-result rate is rising, either the feasibility filters are too strict
(relax them), the retrieval is missing paraphrase matches (add hybrid), or the fallback
cascade is not wired (add it). See
[`blend-never-return-zero-results`](../blend-never-return-zero-results.md),
[`blend-fall-back-to-recommendations-on-zero-results`](../blend-fall-back-to-recommendations-on-zero-results.md),
and [`arch-design-zero-result-fallback`](../arch-design-zero-result-fallback.md).

**If this check fails:** wire the fallback cascade as the first priority. Zero-result
sessions are lost bookings.

## Step 6 — Golden-Set Gap Audit

**Question:** is the production ranker still beating the baselines on offline NDCG?

Run the frozen golden set against the production ranker and compare NDCG@10, MRR, and
coverage to:
- The popularity baseline (non-ML)
- The previous production ranker version
- The heuristic ranker (if used for cold cohorts)

**Red flags:**
- Production NDCG@10 is within 3% of the popularity baseline
- Delta has been shrinking over the last three releases
- A specific subset of queries (intent class, region) shows much worse NDCG than average

**If this check fails:** either the ranker needs improvement or the golden set is stale.
Refresh the golden set (open a new cycle, add missing queries, grade them, freeze), then
decide whether to invest in the ranker or roll back to a known-good version.

## Step 7 — Ranking Churn and Drift Audit

**Question:** is the ranking changing too much or too little release to release?

Track rank-biased overlap (RBO) between the top-10 for the golden set before and after
each release per [`monitor-track-ranking-stability-churn`](../monitor-track-ranking-stability-churn.md).
A small, deliberate change produces RBO around 0.85-0.95. RBO below 0.75 without a
matching deliberate change is suspicious.

**Red flags:**
- RBO < 0.75 on a release that had no ranking code changes (data drift)
- RBO = 1.00 on a release that was supposed to change ranking (change did not land)
- RBO trends monotonically lower week over week (slow drift)

**If this check fails:** investigate data pipeline drift, index refresh anomalies, or
silent feature regressions. The decisions log is the first source — what changed?

## Step 8 — Hand Off to the Personalisation Skill

If steps 1-7 pass and the problem is still "the results feel generic" or "new users
get a cold experience" or "the same providers dominate the top of the list", the
bottleneck is likely personalisation-specific. Hand off to `marketplace-personalisation`
per [`plan-handoff-to-personalisation-skill`](../plan-handoff-to-personalisation-skill.md)
and use its
[improvement playbook](../../../../marketplace-personalisation/references/playbooks/improving.md)
which covers impression tracking, schema, two-sided matching, feedback loops, cold
start, and recipe selection.

The hand-off is the right move when:

- All retrieval-layer checks pass
- The dashboard shows healthy zero-result rate, NDCG, and reformulation rate
- The problem is in the *ordering quality* for warm cohorts or the *novelty* experience for cold cohorts
- A personalisation experiment is already in progress and the retrieval layer is not the bottleneck

## Recording the Diagnosis

Every diagnostic run should produce an entry in the decisions log per
[`plan-maintain-a-decisions-log`](../plan-maintain-a-decisions-log.md), with:

- The date and who ran the diagnostic
- Which steps passed and which failed
- The chosen intervention and its ship/kill criterion
- A link to the commit that implements the fix
- The outcome of the A/B test

And any genuine surprise gets appended to `gotchas.md` so future diagnostics start from
a richer context.
