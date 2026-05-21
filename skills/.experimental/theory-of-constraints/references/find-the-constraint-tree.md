# Decision Tree: Find the Constraint (master)

**Symptom:** "Optimize this / make it faster / cheaper" with no obvious target. Start here whenever the constraint is unknown — every other tree assumes you have already identified one.

**Precondition — define the goal metric.** ToC is meaningless without a *global* throughput metric. Before measuring anything, pin down what you are maximizing:
- CI/build pipeline → end-to-end wall-clock per run, or runs/hour at capacity.
- Dev value stream → PRs merged/week, or lead time from first commit to deploy.
- Agent Skill/plugin → useful task completions per session, or tokens spent per completion.
- Runtime code path → requests/sec sustained, or p99 latency at target load.

If the user has not given one, ask. Optimizing without a global metric is how local optima get rewarded.

```
Define goal metric + list the ordered stages
│
├── Can you time each stage? → run queries/measure-stage-times.sh
│   │
│   ├── One stage dominates wall-clock (>40% of total, or ≥2x the next)
│   │   └── That stage is the constraint candidate → CONFIRM with WIP check below
│   │
│   └── No single stage dominates (times are even)
│       └── Throughput is likely gated by flow, not a slow stage →
│           run queries/measure-wip.sh and queries/utilization-vs-throughput.py
│           │
│           ├── WIP accumulates before one stage (queue grows run-over-run)
│           │   └── That stage is the constraint → go to wip-accumulation-tree.md
│           │
│           └── A non-constraint runs >85% busy while a downstream stage starves
│               └── Over-activation → go to utilization-trap-tree.md
│
├── Can't time stages, but work flows through a queue/board →
│   run queries/measure-wip.sh
│   └── The stage with the largest / fastest-growing inbox is the constraint
│       (work waits in front of the slowest resource) → CONFIRM below
│
└── It's an Agent Skill / plugin → run queries/skill-context-cost.sh <skill-dir>
    │
    ├── SKILL.md + always-loaded content > ~500 lines or dwarfs references
    │   └── Constraint = always-loaded context budget → EXPLOIT: move detail into
    │       on-demand references; the entry point should navigate, not embed
    │
    └── Description is generic/passive (skill rarely triggers)
        └── Constraint = triggering — throughput is ZERO when the skill never fires →
            EXPLOIT: rewrite the description (intent-focused, pushy). Defer to
            dev-skill:evolve. This beats any internal optimization.

CONFIRM the constraint, then walk the Five Focusing Steps:
│
├── Step 2 — EXPLOIT (no new spend): is the constraint ever idle, blocked, or
│   doing avoidable work? Remove that first. (Examples: constraint waits on a
│   serialized upstream step; runs work that could be cached; re-does rejected work.)
│   └── Re-measure. Did the goal metric improve? 
│       ├── Yes, and it's now "good enough" → STOP. Record in report.md.
│       └── Still binding → continue to Step 3.
│
├── Step 3 — SUBORDINATE: pace every non-constraint to the constraint's rate.
│   Non-constraints should idle rather than pile WIP in front of the constraint.
│   (Drum-Buffer-Rope: release work only as fast as the constraint consumes it.)
│   ├── Non-constraints resist idling / stay over-activated →
│   │   go to utilization-trap-tree.md.
│   └── Else (they subordinate cleanly) → continue to Step 4.
│
├── Step 4 — ELEVATE (only after exploit + subordinate): add capacity to the
│   constraint — parallelize it, add a worker, upgrade it, split the batch.
│   └── Re-measure with queries/throughput-accounting.py (verify T rose, not just OE).
│       Go to elevation-misfire-tree.md if it didn't help.
│
└── Step 5 — REPEAT: the constraint has moved. Re-run this tree from the top.
    Beware inertia: kill policies built around the OLD constraint →
    go to moving-constraint-tree.md.
```

## Usual suspects (most frequent constraints, by domain)

1. **CI/build:** a serialized full test suite or a single-threaded build step gating every run.
2. **Dev value stream:** code review (work waits longest in the review queue).
3. **Agent Skill:** the always-loaded context budget, or a non-triggering description.
4. **Runtime:** an N+1 query or a synchronous external call on the hot path.

## Decision criteria (measurable)

| Node | "Constraint" looks like | "Not it" looks like |
|------|-------------------------|---------------------|
| Stage timing | One stage ≥40% of total wall-clock or ≥2x next | Even spread, <25% each |
| WIP | Inbox grows run-over-run; items wait here longest | Inbox drains each cycle |
| Utilization | Constraint ~100% busy; downstream starves | All stages <70% — system has spare capacity, look for a policy constraint |
| Skill context | Always-loaded ≫ on-demand; SKILL.md >500 lines | Lean entry point, detail in references |

## Terminal actions

- **Exploit / Subordinate / Elevate** — proceed through the Five Focusing Steps above.
- **Repeat** — constraint moved; restart at the top.
- **Dismiss** — all stages <70% utilized and no WIP builds anywhere → the constraint is not a resource. Go to [policy-constraint-tree.md](policy-constraint-tree.md).

Record every confirmed constraint and intervention in [../assets/templates/report.md](../assets/templates/report.md).
