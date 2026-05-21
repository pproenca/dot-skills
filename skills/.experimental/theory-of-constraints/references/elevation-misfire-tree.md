# Decision Tree: Elevation Misfire (added capacity, no gain)

**Symptom:** You added capacity — more workers, parallelism, hardware, a bigger machine, an extra reviewer — and throughput barely changed.

**Core principle:** Elevation (Step 4) is the *last* of the Five Focusing Steps for a reason. It is the only step that costs money, and it pays off only when (a) you have already exploited and subordinated, (b) you elevated the actual constraint, and (c) the constraint hasn't already moved. A misfire means one of those three failed.

```
You elevated something and throughput didn't rise. Which failure?
│
├── Did you EXPLOIT before elevating?
│   │   (Was the constraint already running with zero idle/waste?)
│   │
│   └── No → you bought capacity to do work the existing capacity wasn't
│       fully doing. Revert or pause the spend. Go EXPLOIT first
│       (remove idle, batching, rework, waiting on the constraint) →
│       find-the-constraint-tree.md Step 2. Re-measure before spending again.
│
├── Did you elevate the ACTUAL constraint?
│   │   Run queries/measure-stage-times.sh (and measure-wip.sh) again, AFTER
│   │   the elevation, on the goal metric.
│   │
│   ├── The stage you elevated is still the slowest / still accumulates WIP
│   │   └── You under-elevated: added capacity but it's still the constraint.
│   │       Elevate further (more shards/workers) OR switch to a structural
│   │       exploit (e.g. cache, algorithmic fix → complexity-optimizer). 
│   │       Re-measure.
│   │
│   └── A DIFFERENT stage is now slowest / now accumulates WIP
│       └── You elevated a non-constraint (it never was binding), OR the
│           constraint MOVED to the new slowest stage. Either way, the elevation
│           you paid for did nothing for T → 
│           │
│           ├── The elevated stage was never the constraint
│           │   └── Local optimum via spending. Roll back the spend if it adds
│           │       ongoing OE. Redirect → find-the-constraint-tree.md.
│           │
│           └── The constraint genuinely moved to a new stage
│               └── Expected and good — the system improved. Continue POOGI on
│                   the NEW constraint → moving-constraint-tree.md.
│
└── Confirm with throughput accounting:
    run queries/throughput-accounting.py with before/after T, I, OE.
    │
    ├── T rose but you only looked at the local stage → not a misfire; the
    │   elevation worked. Re-identify the new constraint →
    │   find-the-constraint-tree.md.
    │
    ├── T flat, OE up (you now pay for idle capacity)
    │   └── Confirmed misfire. The capacity sits idle because it isn't the
    │       constraint or wasn't exploited. Roll back the ongoing cost.
    │
    └── T flat, I up (more parallelism created more WIP, not more output)
        └── You parallelized a non-constraint; it floods the real constraint →
            subordinate it and cap WIP → wip-accumulation-tree.md.
```

## Common misfires by domain

- **CI:** added runners, but the bottleneck is a serialized DB-migration test that can't parallelize → exploit (isolate/mock it) before adding hardware.
- **Dev value stream:** added a reviewer, but reviews wait on flaky CI, not reviewer time → CI was the constraint.
- **Runtime:** scaled out web workers, but all hit one undersized database → DB is the constraint; workers now just queue on it.
- **Agent Skill:** added more reference detail "to be thorough", inflating context — that's negative elevation; it enlarged the very constraint (context budget).

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| Post-elevation T delta | Flat = misfire; rose proportionally = worked |
| Which stage is now slowest | Same = under-elevated; different = wrong target or moved |
| OE delta | Up with T flat = paying for idle capacity; roll back |
| I delta | Up with T flat = parallelized a non-constraint; subordinate + cap WIP |

## Terminal actions

- **Exploit first** — you skipped Step 2; recover free capacity before spending.
- **Elevate further / structurally** — right target, not enough; add more or change the approach.
- **Roll back the spend** — elevated a non-constraint; stop paying for idle capacity.
- **Continue POOGI** — constraint moved (a win) → [moving-constraint-tree.md](moving-constraint-tree.md).
- **Subordinate + cap WIP** — parallelism created WIP, not output → [wip-accumulation-tree.md](wip-accumulation-tree.md).

Record the elevation, its cost, and the measured T delta in [../assets/templates/report.md](../assets/templates/report.md) — elevations that don't hold are the strongest signal of a hidden policy constraint.
