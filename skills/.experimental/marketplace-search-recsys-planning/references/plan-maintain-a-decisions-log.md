---
title: Maintain a Decisions Log as Living Context
impact: HIGH
impactDescription: prevents lost context across team changes
tags: plan, decisions-log, living-artefact
---

## Maintain a Decisions Log as Living Context

Every ranking tweak, schema change, synonym addition and filter edit is a decision made with context — a hypothesis, an offline metric, an A/B result, a reason. Without a decisions log, that context evaporates within a quarter: the team that inherits the system cannot explain why the `trust_score` boost is 1.8 instead of 2.0, why a particular synonym exists, or why a feature was removed. A plain-text decisions log, committed alongside the code, captures the *why* of every change so future engineers inherit context, not just artefacts. Treat the decisions log as a living document that the agent reads before suggesting changes and updates after every shipped experiment.

**Incorrect (change committed with no recorded rationale):**

```bash
git commit -m "Update trust score boost"
```

**Correct (structured decisions-log entry committed alongside the change):**

```markdown
# decisions/2026-04-11-trust-score-boost.md

## Decision
Raise `trust_score` function_score weight from 1.5 to 1.8 in homefeed ranker.

## Why
Q1 audit showed top-10 results were dominated by high-CTR but low-trust listings
(provider decline rate 18% on top-1). Raising the weight shifts rank toward
higher-trust providers even when CTR is slightly lower.

## Evidence
- Offline: NDCG@10 +0.008 on golden set v3.2
- A/B: +2.1% booking_completed, -0.5% CTR, -6pp provider decline rate
- Ship criterion: booking_completed ≥ +1.5% (met)

## Rollback
Revert `weight` to 1.5 in `configs/homefeed_ranker.json`.

## Related
- Replaces earlier experiment 2026-02-08-trust-score-experiment
- References: rules/match-rank-mutual-fit.md
```

Reference: [Google — Rules of Machine Learning, Rule 27: Try to Quantify Observed Undesirable Behavior](https://developers.google.com/machine-learning/guides/rules-of-ml)
