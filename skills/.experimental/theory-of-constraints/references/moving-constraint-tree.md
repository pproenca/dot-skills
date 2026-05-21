# Decision Tree: Moving Constraint (and the inertia trap)

**Symptom:** You fix one bottleneck and another immediately appears; the constraint seems to "jump around," and it's unclear whether you're making progress or chasing your tail.

**Core principle:** A moving constraint is the *expected, healthy* outcome of POOGI Step 5 — when you break a constraint, some other stage becomes the new limit, and you repeat. The danger is twofold: (1) **thrashing** — chasing a constraint that oscillates because it isn't stable, and (2) **inertia** — leaving in place policies that were built around an *old* constraint, which then become the new constraint themselves. Goldratt's warning: "do not allow inertia to cause a system's constraint."

```
The constraint moved. Is this healthy progress or thrashing?
│
├── Did the GOAL METRIC improve each time the constraint moved?
│   run queries/throughput-accounting.py across the iterations.
│   │
│   ├── Yes — T rose with each move
│   │   └── Healthy POOGI. The system is genuinely improving. Decide whether to
│   │       continue:
│   │       │
│   │       ├── Current T is "good enough" vs the goal
│   │       │   └── STOP iterating. Lock in the current constraint as a
│   │       │       deliberate control point (you WANT a known, managed
│   │       │       constraint — e.g. a strategic capacity you scale on demand).
│   │       │       Stabilize it with Drum-Buffer-Rope → wip-accumulation-tree.md.
│   │       │
│   │       └── Still short of the goal
│   │           └── Continue: re-identify and exploit the NEW constraint →
│   │               find-the-constraint-tree.md.
│   │
│   └── No — T flat or oscillating while the "constraint" jumps around
│       └── Thrashing, not progress. The most likely causes:
│           │
│           ├── Constraints are close together (several stages near-equal)
│           │   └── Whichever you touch becomes "not slowest" by a hair, so it
│           │       looks like it moved. Stop optimizing single stages; the
│           │       system is balanced and gated by FLOW → install a WIP cap and
│           │       subordinate to one chosen pacing stage →
│           │       wip-accumulation-tree.md / utilization-trap-tree.md.
│           │
│           ├── Measurement noise (you're reacting to run-to-run variance)
│           │   └── Average over multiple runs before declaring a constraint.
│           │       Re-measure with queries/measure-stage-times.sh (several runs).
│           │
│           └── The real constraint is a POLICY that re-creates the symptom
│               each time (e.g. a batch-everything rule, a metric that rewards
│               local utilization) → policy-constraint-tree.md.
│
└── INERTIA CHECK (run after every successful move): are any policies, rules,
    schedules, buffers, or instructions still tuned to the OLD constraint?
    Run queries/five-focusing-steps.sh and answer the Step 5 prompts.
    │
    ├── Yes — e.g. a buffer sized for the old bottleneck, a "always run full
    │   suite" rule from when tests were fast, a review process built around a
    │   slow stage that's now fast
    │   └── REMOVE/resize the stale policy. Left in place it becomes the new
    │       constraint. Then re-identify → find-the-constraint-tree.md.
    │
    └── No stale policies found
        └── Clean. Continue POOGI on the new constraint →
            find-the-constraint-tree.md.
```

## Inertia: the most expensive constraint

After two or three POOGI cycles, the binding constraint is frequently no longer a resource at all — it's a rule that *used* to make sense. Examples:
- A CI gate that runs the entire suite "to be safe" — rational when the suite was 30s, now the constraint at 30min.
- A buffer/queue sized large for a slow stage that has since been elevated — now it just inflates lead time.
- An Agent Skill instruction to "read all references before acting" — sensible when references were few, now the context constraint.

These are invisible to stage timing because the waste is *structural*. The inertia check above and `policy-constraint-tree.md` exist to catch them.

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| T trend across moves | Rising = healthy POOGI; flat/oscillating = thrashing |
| Stage time spread | Several stages within ~15% = balanced; flow-gated, stop chasing one |
| Run-to-run variance | High variance = average more runs before acting |
| Stale-policy check | Any rule tuned to a former constraint = inertia; remove it |

## Terminal actions

- **Continue POOGI** — healthy improvement; re-identify the new constraint.
- **Stop + stabilize** — good enough; lock the constraint as a managed control point with DBR.
- **Stop chasing, cap WIP** — system is balanced/flow-gated; subordinate to one pacing stage.
- **Average more runs** — you're reacting to noise.
- **Remove stale policy** — inertia; a former-constraint rule is now binding → [policy-constraint-tree.md](policy-constraint-tree.md).

Record the constraint's path (stage A → B → policy C) in [../assets/templates/report.md](../assets/templates/report.md); the trajectory tells you where to invest structurally.
