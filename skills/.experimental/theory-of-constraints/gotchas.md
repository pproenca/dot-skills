# Gotchas

The diagnostic dead-ends and recurring errors of applying Theory of Constraints. The first five are the classic ToC traps — they are the entire reason the method exists. Append new ones (with dates) as investigations surface them.

### Optimizing without a defined global metric
The most common failure: jumping to "make it faster" before naming the global throughput metric. Without one, every local speedup looks like progress and local optima get rewarded. Always pin the goal metric first (see `find-the-constraint-tree.md` precondition); if the user can't state one, that absence is the first thing to fix.
Added: 2026-05-21

### Optimizing the most-visible stage instead of the binding one
Teams optimize whatever is easiest to see or measure (compile time, a noisy log), not what is binding. An improvement to a non-constraint produces zero global gain — "an hour saved at a non-bottleneck is a mirage." Confirm the constraint with measurement (`measure-stage-times.sh` + `measure-wip.sh`) before touching anything. See `local-optimum-tree.md`.
Added: 2026-05-21

### Elevating before exploiting
Adding capacity (Step 4) before getting the most from existing capacity (Step 2) buys idle resources: OE rises, T stays flat. Always exhaust exploit + subordinate before spending. A misfired elevation is the strongest signal you skipped a step. See `elevation-misfire-tree.md`.
Added: 2026-05-21

### Mistaking high utilization for productivity
"Activating a resource is not the same as utilizing it." Driving a non-constraint to 100% only inflates WIP. A correctly-subordinated non-constraint *should* idle part of the time. Green dashboards everywhere with low throughput is the trap, not the goal. See `utilization-trap-tree.md`.
Added: 2026-05-21

### Leaving stale policies in place after the constraint moves (inertia)
After two or three POOGI cycles the binding constraint is usually a *policy* that was rational for a former constraint — a full-suite gate from when tests were fast, a buffer sized for an old bottleneck, a "read all references" instruction from when references were few. These are invisible to stage timing. Run the inertia check every cycle. See `moving-constraint-tree.md` and `policy-constraint-tree.md`.
Added: 2026-05-21

### Relaxing a policy without verifying its necessary condition
Policy constraints are high-leverage because changing a rule is free — but rules often protect something real (regressions, incidents, correctness). Shrinking a test gate or removing an approval can raise throughput while quietly raising escaped defects. ToC maximizes throughput *subject to* necessary conditions still holding. Verify the protected outcome for a few cycles before declaring success; if it regresses, the policy was real, not stale. See `policy-constraint-tree.md`.
Added: 2026-05-21

### Reacting to run-to-run noise as if the constraint moved
A constraint that "jumps around" is often measurement variance, not a moving constraint. Average over several runs (`measure-stage-times.sh --runs 3+`) before declaring a new constraint, especially when stage times are close together (a balanced, flow-gated system). See `moving-constraint-tree.md`.
Added: 2026-05-21

### Treating throughput accounting units inconsistently
`throughput-accounting.py` compares before vs after — the verdict is only meaningful if T, I, and OE use the *same units* in both readings (e.g. both T in PRs/week, both OE in CI-minutes/run). Mixing units (local stage time before, global metric after) produces a false verdict. Measure the same global metric on both sides.
Added: 2026-05-21
