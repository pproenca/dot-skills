# Decision Tree: Local Optimum (the mirage of the non-bottleneck)

**Symptom:** A change measurably sped up one stage, but end-to-end throughput or lead time barely moved. The user is frustrated that "the optimization didn't work."

**Core principle:** "An hour saved at a non-bottleneck is a mirage." Improving a stage that is not the constraint cannot raise global throughput — the constraint still gates the system. The fix is rarely to optimize harder; it is to redirect effort to the actual constraint.

```
A change sped up stage X. Did global throughput improve?
│
├── Did you measure the GLOBAL metric before and after?
│   │   (not just stage X's local time — the end-to-end goal metric)
│   │
│   ├── No → run queries/throughput-accounting.py with before/after T, I, OE
│   │   │   to get the real delta. Then re-enter this tree with the numbers.
│   │
│   └── Yes → compare global throughput (T) delta:
│       │
│       ├── T rose ≥ the stage's local improvement, proportionally
│       │   └── X WAS the constraint. Not a local optimum — keep the change.
│       │       Re-identify (constraint has likely moved) →
│       │       find-the-constraint-tree.md.
│       │
│       ├── T flat (<5% change) but OE dropped or stage X is faster
│       │   └── LOCAL OPTIMUM CONFIRMED. X was not the constraint.
│       │       │
│       │       ├── Was the change cheap and side-effect-free (e.g. a cache)?
│       │       │   └── Keep it (harmless), but STOP investing here. Redirect all
│       │       │       further effort → find-the-constraint-tree.md.
│       │       │
│       │       └── Did the change add complexity, risk, or new WIP?
│       │           └── REVERT it. Local optimizations that add inventory or
│       │               complexity make the system worse (more I and OE, same T).
│       │               Then → find-the-constraint-tree.md.
│       │
│       └── T fell after the change
│           └── The change pushed MORE WIP at the real constraint (a faster
│               non-constraint floods the bottleneck). Revert, then apply
│               Drum-Buffer-Rope → wip-accumulation-tree.md.
│
└── "We can't measure global throughput"
    └── You cannot do ToC without a global metric — that absence is itself the
        first thing to fix. Define the goal metric (see find-the-constraint-tree.md
        precondition), instrument it, then return.
```

## Why this happens (so you can prevent it)

Local efficiency *feels* like progress and is easy to measure, so teams optimize whatever they can see. Goldratt's measurement rule: **the worth of any local improvement is judged solely by its effect on the global goal.** A 50%-faster compile stage does nothing if tests (the constraint) gate every merge.

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| Global T delta | <5% = local optimum; ≈ proportional to stage gain = real |
| OE delta | OE down + T flat = classic mirage (you bought nothing) |
| I delta | I up (more WIP/complexity) + T flat = net negative; revert |

Use `queries/throughput-accounting.py` — it explicitly flags the OE↓/T-flat pattern as a local optimum.

## Terminal actions

- **Keep + redirect** — change was harmless; stop investing here, go find the real constraint.
- **Revert** — change added I/OE/complexity without raising T.
- **Re-identify** — X actually was the constraint; it has moved → [find-the-constraint-tree.md](find-the-constraint-tree.md).
- **Apply DBR** — change flooded the constraint → [wip-accumulation-tree.md](wip-accumulation-tree.md).

Record the false start in [../assets/templates/report.md](../assets/templates/report.md) — repeated local optima in the log signal a measurement-culture problem worth naming.
