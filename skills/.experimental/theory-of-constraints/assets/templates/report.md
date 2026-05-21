# Constraint Analysis Report: {system / workflow name}

**Date:** {YYYY-MM-DD}
**Investigator:** {agent/user}
**System under study:** {CI pipeline | dev value stream | Agent Skill | runtime path}
**Goal metric (global throughput):** {e.g. PRs merged/week, requests/sec, builds/hour, task completions/session}
**Severity:** {P1 effort being wasted | P2 a step skipped | P3 meta-process}

## Summary

{1–2 sentences: what the constraint was, which focusing step applied, and the measured effect on the goal metric.}

## System map

{The ordered stages, with the constraint marked. Example:}

```
install → build → [TEST ← constraint] → deploy
```

## Constraint identified

| Field | Value |
|-------|-------|
| Constraint | {stage / resource / policy} |
| Type | {physical resource | policy} |
| Evidence | {slowest stage X% of total | WIP growing in front | ~100% utilized | all stages slack → policy} |
| Quick check used | {queries/measure-stage-times.sh \| measure-wip.sh \| utilization-vs-throughput.py \| skill-context-cost.sh} |
| Entry tree | {find-the-constraint | local-optimum | wip-accumulation | utilization-trap | elevation-misfire | moving-constraint | policy-constraint | conflict-resolution} |

## Timeline

- {HH:MM} — Goal metric defined: {metric} = {baseline value}
- {HH:MM} — Measured stages: {tool}, found {result}
- {HH:MM} — Constraint confirmed: {what} ({evidence})
- {HH:MM} — Focusing step applied: {EXPLOIT / SUBORDINATE / ELEVATE / change policy}
- {HH:MM} — Re-measured: {metric} = {new value}

## Focusing step applied

{Which of the Five Focusing Steps, and exactly what was done.}

- [ ] 1. IDENTIFY — constraint confirmed with evidence (not guessed)
- [ ] 2. EXPLOIT — removed idle/waste/rework on the constraint (no new spend)
- [ ] 3. SUBORDINATE — paced non-constraints to the constraint; capped WIP
- [ ] 4. ELEVATE — added capacity (only after exploit + subordinate)
- [ ] 5. REPEAT / inertia check — removed any policy tuned to the old constraint

## Throughput accounting (before / after)

| Measure | Before | After | Delta | Verdict |
|---------|--------|-------|-------|---------|
| T (throughput ↑) | | | | |
| I (inventory ↓) | | | | |
| OE (operating expense ↓) | | | | {THROUGHPUT IMPROVED / LOCAL OPTIMUM / WIP INFLATED / REGRESSION} |

> Run `queries/throughput-accounting.py --before T I OE --after T I OE` to fill this in and get the verdict. A T-flat / OE-down result is a LOCAL OPTIMUM — do not claim success.

## Necessary conditions verified (only if a policy was relaxed)

{If you shrank a test gate, removed an approval, or changed a metric: confirm the protected outcome still holds — escaped-defect rate, incident rate, output correctness. If it regressed, the policy was real, not stale; restore it.}

## Next predicted constraint

{When this constraint is broken, the system limit moves. Where to next? This is POOGI step 5 — name the likely new constraint so the next investigation starts ahead.}

## Action items

- [ ] {Intervention to keep / make permanent}
- [ ] {Stale policy to remove (inertia)}
- [ ] {Metric/instrumentation to add so the next constraint is measurable}
- [ ] {Append a one-line entry to the investigation log}
