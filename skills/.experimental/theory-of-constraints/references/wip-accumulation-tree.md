# Decision Tree: WIP Accumulation (let inventory point at the constraint)

**Symptom:** Work-in-progress, queue depth, or an inbox keeps growing at one stage; lead time is climbing even though "everyone is working."

**Core principle:** In any flow, WIP piles up *immediately in front of the constraint* — the constraint can't consume work as fast as upstream produces it. The growing pile is a free pointer to the bottleneck. The remedy is **Drum-Buffer-Rope (DBR)**: the constraint sets the drumbeat, a small buffer protects it from starving, and a "rope" ties the release of new work to the constraint's consumption so WIP stops growing.

```
WIP is growing somewhere. Where?
│
├── Run queries/measure-wip.sh across the stages.
│   │   (Counts items waiting per stage: open PRs in review, files in a queue
│   │    dir, jobs pending, branches awaiting CI, etc. Run it twice, minutes
│   │    or a cycle apart, to see which inbox GROWS.)
│   │
│   ├── One stage's inbox is largest AND growing run-over-run
│   │   └── The stage CONSUMING that inbox is the constraint. Confirm: is it
│   │       ~100% busy? (queries/utilization-vs-throughput.py)
│   │       │
│   │       ├── Yes, ~100% busy → constraint confirmed. Apply DBR (below).
│   │       │
│   │       └── No, it's idle while its inbox grows
│   │           └── The stage is BLOCKED, not slow — it waits on something
│   │               (a lock, an approval, an external dependency, a serialized
│   │               handoff). That dependency is the real constraint →
│   │               EXPLOIT by removing the block (parallelize the handoff,
│   │               pre-fetch the dependency). Then re-measure.
│   │
│   ├── WIP is growing at MULTIPLE stages
│   │   └── You are releasing work faster than the system can flow it. The
│   │       constraint is the FURTHEST-DOWNSTREAM growing stage; upstream piles
│   │       are secondary. Throttle release (rope) to that stage's rate, then
│   │       re-measure — upstream piles should drain.
│   │
│   └── No stage's WIP is growing (inboxes drain each cycle)
│       └── Not a flow/constraint problem in steady state. The slowness is
│           elsewhere → find-the-constraint-tree.md (look at stage timing).
│
└── Apply Drum-Buffer-Rope at the confirmed constraint:
    │
    ├── DRUM — set the system's pace to the constraint's actual throughput.
    │   Measure how many items/hour it really completes.
    │
    ├── BUFFER — keep a SMALL, bounded queue right before the constraint so it
    │   never starves (e.g. 1–2 items, or a few minutes of work). Bigger is not
    │   safer — it just inflates lead time (I) with no T gain.
    │
    └── ROPE — release new work into the system only when the constraint pulls
        the next item. This caps total WIP. 
        └── Re-run queries/measure-wip.sh: upstream inboxes should stop growing
            and lead time should fall while throughput holds.
            ├── Lead time fell, T unchanged → success (you removed inventory waste).
            │   Now consider EXPLOIT/ELEVATE on the constraint itself →
            │   find-the-constraint-tree.md (Five Focusing Steps).
            └── T dropped after adding the rope → buffer too small (constraint
                starving). Increase buffer by one item and re-measure.
```

## Worked examples

- **Dev value stream:** 30 PRs open, all waiting on 2 reviewers. Review is the constraint. Rope = don't start new feature work until a review slot frees (WIP limit on "in review"). Buffer = a small ready-for-review queue so reviewers never idle.
- **CI:** builds queue behind a single shared test runner. Runner is the constraint. Rope = cap concurrent pipeline triggers; buffer = a short job queue; then EXPLOIT (shard tests) or ELEVATE (add a runner).
- **Agent pipeline:** generation steps outrun a slow verification step; partial outputs accumulate. Verification is the constraint. Rope = generate the next item only when verification frees.

## Decision criteria (measurable)

| Signal | Reading |
|--------|---------|
| Inbox size (two readings) | Growing run-over-run = constraint is just downstream |
| Constraint utilization | ~100% busy = slow constraint; idle = blocked constraint |
| Lead time after rope | Should fall sharply with T held — that's WIP waste removed |

## Terminal actions

- **Apply DBR** — drum/buffer/rope as above; the default fix.
- **Unblock** — constraint is idle-but-blocked; remove the dependency (an exploit move).
- **Throttle release** — multiple growing piles; cap WIP to the downstream constraint's rate.
- **Dismiss** — no inbox grows; not a flow problem → [find-the-constraint-tree.md](find-the-constraint-tree.md).

Record buffer sizes and the WIP cap you set in [../assets/templates/report.md](../assets/templates/report.md) so the next investigation can tune them.
