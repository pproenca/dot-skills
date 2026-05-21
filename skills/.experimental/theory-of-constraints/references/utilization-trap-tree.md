# Decision Tree: Utilization Trap (busy ≠ productive)

**Symptom:** Every stage/resource looks fully utilized — dashboards green, everyone "at capacity" — yet little actually ships and throughput is low.

**Core principle:** Two Goldratt rules collide here. "Activating a resource is not the same as utilizing it" — running a non-constraint flat-out only produces excess WIP, not throughput. And "the level of utilization of a non-constraint is determined by the constraint, not by its own potential." A correctly-subordinated non-constraint *should* sit idle part of the time. High utilization everywhere is a symptom, not a goal: **balance flow, not capacity.**

```
Everything is busy but throughput is low.
│
├── Run queries/utilization-vs-throughput.py with each stage's busy-time and
│   items-completed.
│   │
│   ├── A non-constraint stage runs >85% busy while the constraint STARVES
│   │   (constraint idle, waiting for input)
│   │   └── Over-activation. The busy non-constraint is producing the WRONG
│   │       work or work the constraint can't yet use → SUBORDINATE: throttle
│   │       the non-constraint to feed the constraint exactly what it needs,
│   │       when it needs it. Let it idle the rest of the time.
│   │
│   ├── A non-constraint runs >85% busy and the constraint is BLOCKED
│   │   (constraint can't release output downstream)
│   │   └── The downstream stage is the real constraint, not the busy one →
│   │       go to find-the-constraint-tree.md to re-identify, then subordinate
│   │       the busy stage to it.
│   │
│   ├── The CONSTRAINT itself is <100% busy while everything waits on it
│   │   └── The constraint has idle/waste on it — the highest-value fix →
│   │       EXPLOIT it (remove setup time, batching delays, rework, waiting on
│   │       approvals). An hour recovered on the constraint is an hour of system
│   │       throughput. See find-the-constraint-tree.md, Step 2.
│   │
│   └── ALL stages >85% busy and WIP growing between them
│       └── You are pushing work in faster than it can flow (a "push" system).
│           High utilization is inflating WIP and lead time, not throughput →
│           install a WIP cap / rope → wip-accumulation-tree.md.
│
└── "But idle resources look wasteful / management rewards utilization"
    └── This is a POLICY constraint masquerading as a capacity problem: the
        measurement system rewards local utilization over global throughput →
        go to policy-constraint-tree.md. Until the metric changes, people will
        re-create the trap.
```

## Why local utilization is the wrong target

If a non-constraint is faster than the constraint, forcing it to 100% just builds inventory in front of (or behind) the constraint — more I, more lead time, zero extra T. The only resource whose utilization should approach 100% is the constraint. Everywhere else, idle time is the *correct* state of a balanced flow.

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| Non-constraint utilization | >85% while constraint starves = over-activated; subordinate |
| Constraint utilization | <100% with everything waiting = exploitable idle/waste on the constraint |
| Throughput vs utilization | Utilization up but T flat = the trap is active |
| WIP between stages | Growing while all busy = push system; cap WIP |

`queries/utilization-vs-throughput.py` reports utilization% and throughput per stage side by side and flags any stage that is "busy but not the constraint."

## Terminal actions

- **Subordinate** — throttle the over-activated non-constraint to the constraint's rate; let it idle.
- **Exploit** — the constraint has recoverable idle/waste; remove it (highest leverage).
- **Cap WIP** — push system flooding itself → [wip-accumulation-tree.md](wip-accumulation-tree.md).
- **Re-identify** — the busy stage isn't the constraint and you're unsure which is → [find-the-constraint-tree.md](find-the-constraint-tree.md).
- **Change the metric** — utilization is rewarded over throughput → [policy-constraint-tree.md](policy-constraint-tree.md).

Record which stages you allowed to idle in [../assets/templates/report.md](../assets/templates/report.md) — it is counterintuitive and will be questioned.
