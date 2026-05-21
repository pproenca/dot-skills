---
name: theory-of-constraints
description: Apply the Theory of Constraints (Goldratt's Five Focusing Steps) to find and fix the single bottleneck that caps a process, workflow, pipeline, or Agent Skill/plugin's throughput. Use whenever optimizing speed, lead time, cost, or token/context budget of a system — CI/build pipelines, dev value streams (idea→review→merge→ship), an Agent Skill's trigger/context flow, or runtime code paths — ESPECIALLY when you don't know where to optimize, a local speedup didn't improve the whole, work piles up at a stage, everything is busy but little ships, adding capacity didn't help, or a policy/rule (not a resource) is the limiter. It locates the constraint with measurement, then prescribes exploit → subordinate → elevate → repeat, and stops you optimizing non-constraints (the "mirage of the non-bottleneck"). Trigger even when the user just says "speed this up", "why is this slow", or "make this more efficient" without mentioning constraints or bottlenecks.
---

# Theory of Constraints

A diagnostic runbook for optimizing any process — a CI/build pipeline, a dev value stream, an Agent Skill or plugin, or a runtime code path — through Eliyahu Goldratt's Theory of Constraints (ToC).

The one idea that makes ToC powerful: **every system has exactly one binding constraint at a time**, and global throughput rises *only* when you improve that constraint. Effort spent anywhere else produces nothing — "an hour saved at a non-bottleneck is a mirage." This runbook finds the constraint with measurement, then walks the Five Focusing Steps to relieve it without creating new problems.

## When to Apply

Use this skill when the user wants to optimize a process or workflow and any of these are true:

- They want to optimize but **don't know where** to start ("make this faster", "why is this slow", "reduce the cost of this").
- A local speedup **didn't move the end-to-end result** (you optimized the wrong thing).
- Work, queues, or WIP **pile up at one stage** while others sit idle.
- Everything looks **100% busy but little ships** (high utilization, low throughput).
- They **added capacity, parallelism, or resources** and it didn't help.
- Fixing one bottleneck just **surfaces another**.
- The real limiter is a **policy or rule, not a resource** (a mandatory full test suite, serialized review, a "read every reference" instruction, batch-everything releases).
- They're **stuck in a tradeoff** that blocks the obvious fix ("faster vs safer", "smaller context vs more coverage").

Do not use this skill for:
- A specific, already-localized hotspot where the constraint is known — go straight to the fix (e.g. an O(n²) loop → `complexity-optimizer`).
- Pure correctness/quality review with no throughput goal — use a code-review skill.
- Micro-optimizing a stage you have not yet proven is the constraint. That is the cardinal ToC error; this skill exists to stop it.

## The Process of Ongoing Improvement (POOGI)

ToC is a loop, not a one-shot. Always run it in order — exploiting before elevating is what separates ToC from "just throw resources at it."

```
        ┌─────────────────────────────────────────────────┐
        │                                                   │
        ▼                                                   │
1. IDENTIFY the constraint  ── the one stage that gates global throughput
        │
        ▼
2. EXPLOIT it               ── get the most from it with NO new spend
        │                       (remove waste/idle on the constraint)
        ▼
3. SUBORDINATE everything   ── pace all non-constraints to the constraint;
   else to the constraint      let them idle rather than build WIP
        │
        ▼
4. ELEVATE the constraint   ── only now add capacity / invest / parallelize
        │
        ▼
5. REPEAT                   ── the constraint has moved; go to step 1.
        │                       Do NOT let inertia (old policies) be the
        └───────────────────────new constraint.
```

The most common mistakes map directly to skipped steps: jumping to step 4 (elevate) before step 2 (exploit), or never reaching step 1 (optimizing whatever is most visible instead of what is binding).

## Common Symptoms

Start here. Match the symptom, open its decision tree, run the quick check.

| Symptom | Usual constraint | Quick check | Tree |
|---------|------------------|-------------|------|
| "Optimize this, don't know where" | Unknown — measure first | `queries/measure-stage-times.sh` | [find-the-constraint](references/find-the-constraint-tree.md) |
| Local speedup, no global gain | You optimized a non-constraint | `queries/throughput-accounting.py` | [local-optimum](references/local-optimum-tree.md) |
| Queue/WIP piling up at a stage | Constraint is at/just downstream of the pile | `queries/measure-wip.sh` | [wip-accumulation](references/wip-accumulation-tree.md) |
| Busy everywhere, little ships | Non-constraints over-activated | `queries/utilization-vs-throughput.py` | [utilization-trap](references/utilization-trap-tree.md) |
| Added capacity, no improvement | Elevated the wrong thing / skipped exploit | `queries/measure-stage-times.sh` | [elevation-misfire](references/elevation-misfire-tree.md) |
| Fix one bottleneck, another appears | Constraint moved (expected) | `queries/measure-stage-times.sh` | [moving-constraint](references/moving-constraint-tree.md) |
| A rule/process is the limiter | Policy constraint | `queries/five-focusing-steps.sh` | [policy-constraint](references/policy-constraint-tree.md) |
| Stuck in a tradeoff | A surfaced dilemma blocks the fix | (reasoning — Evaporating Cloud) | [conflict-resolution](references/conflict-resolution-tree.md) |

For Agent Skills / plugins specifically, the constraint is most often the **always-loaded context budget** (a bloated SKILL.md) or a **weak description** (the skill never triggers, so its throughput is zero). Run `queries/skill-context-cost.sh <skill-dir>`.

## How to Use

1. **Identify the symptom** in the table above and open its tree in `references/`.
2. **Define the goal and throughput metric first.** ToC is meaningless without a global metric to improve (PRs merged/week, requests/sec, task completions per agent session, build wall-clock). The trees assume you have one — set it via `config.json` or ask the user.
3. **Run the quick-check query** the tree points to. Queries live in [references/queries/](references/queries/); each has a header explaining parameters and how to read the output.
4. **Follow the tree** to a terminal action. Every path ends in a concrete ToC move (exploit / subordinate / elevate / change-the-policy / repeat).
5. **Record the finding** using [assets/templates/report.md](assets/templates/report.md). Append a one-line entry to the investigation log so recurring constraints become visible over time.

Read [references/symptoms.md](references/symptoms.md) for the full catalog with entry points and severity.

## Setup

This skill uses `config.json` to know what "throughput" means for the system under study and how to measure each stage. On first use, if `goal_metric` or `value_stream_stages` are empty, ask the user (via `AskUserQuestion`) for:
- the **goal metric** (the global throughput to maximize), and
- the **ordered stages** of the workflow being optimized.

Then save them to `config.json`. If config cannot be filled, the skill still works — fall back to asking the user inline and measuring stages manually. Never block on missing config.

## Gotchas

The classic ToC traps (measuring local efficiency, elevating before exploiting, optimizing the most-visible stage) are captured in [gotchas.md](gotchas.md). Read it before your first investigation — these errors are the whole reason ToC exists.

## Related Skills

- `complexity-optimizer` — once ToC identifies a *code* stage as the constraint, use this to find and fix the algorithmic hotspot inside it.
- `dx-harness` — when the constraint is a developer-experience chore (slow bootstrap, manual steps), this audits and fixes the harness.
- `dev-skill:evolve` — when the constraint is an Agent Skill itself (bloated context, weak triggering), this improves it.
