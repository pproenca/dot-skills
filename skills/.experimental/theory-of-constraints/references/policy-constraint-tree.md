# Decision Tree: Policy Constraint (the limiter is a rule, not a resource)

**Symptom:** No physical resource is maxed out — all stages have spare capacity, nothing is starved for hardware — yet throughput is still capped. Or: you keep elevating resources and the system refuses to go faster. The binding constraint is a **policy**: a rule, process, metric, or instruction.

**Core principle:** Goldratt's most consequential claim is that the vast majority of real-world constraints are *policy* constraints, not physical ones — and they are the highest-leverage to fix because changing a rule usually costs nothing. A policy constraint is invisible to stage timing because the waste is structural: the resource isn't slow, it's *forbidden from flowing*.

```
Throughput is capped but no resource is maxed. Find the binding policy.
│
├── Run queries/utilization-vs-throughput.py.
│   Are ALL stages well under 100% busy (e.g. <70%) yet throughput is low?
│   │
│   ├── No — some resource IS maxed → this isn't (only) a policy constraint →
│   │   find-the-constraint-tree.md (treat the maxed resource first).
│   │
│   └── Yes — spare capacity everywhere, low throughput
│       └── A policy is gating flow. Identify which class:
│           │
│           ├── BATCHING — work is held and processed in large batches
│           │   (deploy weekly, run the full test suite on every change, review
│           │   only at end of sprint, regenerate everything on any edit)
│           │   └── EXPLOIT by shrinking the batch: deploy per-PR, gate only on
│           │       tests affected by the diff, review continuously, regenerate
│           │       only changed artifacts. Smaller batches cut lead time and
│           │       unlock idle capacity. Re-measure with throughput-accounting.py.
│           │
│           ├── SERIALIZATION — steps that could overlap are forced sequential
│           │   (one reviewer at a time, single-threaded gate, mandatory handoff
│           │   ordering, "read every reference before acting")
│           │   └── EXPLOIT by parallelizing or removing the ordering constraint:
│           │       multiple reviewers, fan-out the gate, read references on
│           │       demand instead of all up front. Re-measure.
│           │
│           ├── WRONG METRIC — local efficiency/utilization is rewarded over
│           │   global throughput, so people re-create the utilization trap
│           │   └── CHANGE THE METRIC to a global one (throughput, lead time).
│           │       Until the measurement changes, the behavior won't. This is
│           │       the root of recurring utilization-trap-tree.md symptoms.
│           │
│           ├── GATE/APPROVAL — work waits on a sign-off that adds little
│           │   (mandatory manual QA on low-risk changes, change-advisory board
│           │   for routine deploys, an approval step that rubber-stamps)
│           │   └── EXPLOIT by right-sizing the gate: risk-tier it (auto-pass
│           │       low-risk), make it asynchronous, or remove it where it adds
│           │       no protection. Verify quality doesn't regress, then keep.
│           │
│           └── STALE RULE — a policy that was rational for a FORMER constraint
│               (see moving-constraint-tree.md inertia check)
│               └── REMOVE/resize it to match the current system.
│
└── Can't tell which policy is binding?
    └── Apply the Evaporating Cloud to surface the assumption that keeps the
        policy in place — most policies persist because of an unexamined
        "we have to do it this way" → conflict-resolution-tree.md.
```

## Verifying a policy change (don't trade throughput for safety blindly)

A policy often exists for a reason (the full suite catches regressions; the gate catches bad deploys). Before keeping a relaxation, confirm the protected outcome still holds:
- Shrinking the test gate? Confirm escaped-defect rate doesn't rise (track it for a few cycles).
- Removing an approval? Confirm the incident rate for that change class stays flat.
- Reading references on demand? Confirm the agent still produces correct output (run `dev-skill:eval`).

If quality regresses, you found a *real* (not stale) policy — restore it and elevate elsewhere. ToC improves throughput **subject to** the system still meeting its necessary conditions (quality, safety).

## Why policy constraints are highest-leverage

| | Physical constraint | Policy constraint |
|---|---|---|
| Cost to elevate | Money (hardware, headcount) | Usually free (change the rule) |
| Visibility | Shows up in stage timing | Invisible to timing; needs reasoning |
| Frequency | Minority of real cases | Majority of real cases |
| Risk | Low (more capacity) | Must verify necessary conditions still hold |

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| Utilization across stages | All <70% + low T = a policy gates flow |
| Batch size | Large batches + idle capacity = batching constraint |
| Parallelizable-but-serial steps | Forced ordering with spare capacity = serialization constraint |
| Metric in use | Local utilization/efficiency rewarded = wrong-metric constraint |

## Terminal actions

- **Shrink the batch / parallelize / right-size the gate / change the metric** — relax the binding policy, then verify necessary conditions hold.
- **Remove the stale rule** — inertia from a former constraint.
- **Restore + elevate elsewhere** — the policy is real (quality regressed); it's protecting something.
- **Surface the assumption** — can't tell which policy binds → [conflict-resolution-tree.md](conflict-resolution-tree.md).

Record the policy changed and the necessary-condition you verified in [../assets/templates/report.md](../assets/templates/report.md).
