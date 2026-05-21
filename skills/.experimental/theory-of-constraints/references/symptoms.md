# Symptom Catalog

Each symptom is an entry point into a decision tree. Match the user's situation to a row, then open the tree. Severity reflects how badly the symptom misdirects optimization effort — P1 symptoms mean effort is actively being wasted right now.

| # | Symptom / trigger | Entry tree | Severity | What it usually means |
|---|-------------------|-----------|----------|-----------------------|
| 1 | "Optimize this / make it faster / cheaper" but no obvious target; general slowness | [find-the-constraint-tree.md](find-the-constraint-tree.md) | P1 | No constraint identified yet. This is the master tree — start here when in doubt. |
| 2 | A change sped up one stage but end-to-end throughput or lead time did not move | [local-optimum-tree.md](local-optimum-tree.md) | P1 | You optimized a non-constraint — "an hour saved at a non-bottleneck is a mirage." |
| 3 | Work, queue depth, or WIP keeps growing at one stage; lead time climbing | [wip-accumulation-tree.md](wip-accumulation-tree.md) | P2 | WIP piles up *immediately upstream of* the constraint. The pile points to it. |
| 4 | Everything looks 100% busy / fully utilized, yet little actually ships | [utilization-trap-tree.md](utilization-trap-tree.md) | P2 | Non-constraints are over-activated. "Activating a resource ≠ utilizing it." |
| 5 | We added capacity, parallelism, workers, or hardware and throughput barely changed | [elevation-misfire-tree.md](elevation-misfire-tree.md) | P2 | Elevated the wrong stage, skipped exploit, or the constraint moved after elevating. |
| 6 | We fix one bottleneck and another immediately appears; the constraint oscillates | [moving-constraint-tree.md](moving-constraint-tree.md) | P3 | Expected under POOGI step 5 — but watch for thrashing and inertia (stale policies). |
| 7 | The limiter is a rule/process/policy, not a resource (mandatory full test gate, serialized review, "read every reference", batch-everything releases) | [policy-constraint-tree.md](policy-constraint-tree.md) | P2 | A policy constraint — the highest-leverage kind, because changing it costs nothing. |
| 8 | Stuck in a tradeoff that blocks the obvious fix ("faster vs safer", "smaller context vs more coverage") | [conflict-resolution-tree.md](conflict-resolution-tree.md) | P3 | A surfaced dilemma. Resolve with the Evaporating Cloud, not compromise. |

## How severity maps to action

- **P1** — Effort is being wasted right now (either undirected, or aimed at a non-constraint). Stop and identify the real constraint before any more changes.
- **P2** — A specific ToC step is being skipped or misapplied (subordination, exploitation, elevation). Correct the step.
- **P3** — The system is improving but the *meta-process* needs attention (constraint moved, or a dilemma/policy needs a thinking-process tool).

## Terminal states (every tree ends in one)

1. **Exploit** — get more from the constraint with no new spend (remove idle/waste on it).
2. **Subordinate** — pace non-constraints to the constraint; let them idle rather than build WIP.
3. **Elevate** — add capacity to the constraint (only after exploiting).
4. **Change the policy** — relax, reorder, or right-size a rule that is the constraint.
5. **Repeat** — the constraint has moved; re-identify (and check for inertia).
6. **Dismiss** — not a constraint problem; redirect to the appropriate skill or declare "no action; this stage is not binding."

## Investigation history

Append a one-line entry per investigation to the log (default `${CLAUDE_PLUGIN_DATA}/toc-investigations.log`, configurable in `config.json`). Over time this reveals which constraints recur and whether elevations actually held — the signal that a deeper policy constraint is in play.
