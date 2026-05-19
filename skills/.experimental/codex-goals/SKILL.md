---
name: codex-goals
description: Patterns and anti-patterns for using OpenAI Codex Goals — the persistent objectives feature introduced in Codex 0.128.0. Use this skill whenever writing, reviewing, or debugging a `/goal` invocation, deciding whether a task should be a Goal at all, drafting a research Goal that needs an evidence ledger, or diagnosing a Goal that completed against the wrong surface. Triggers on `/goal`, "Codex Goal", "Codex goals", "persistent objective", "evidence-based completion", "iteration policy", "blocked stop condition", or any user message describing a multi-turn Codex task with a defined finish line. Trigger even if the user doesn't explicitly mention Goals — if they're typing "/goal" or asking Codex to "keep going until X", this skill applies.
---

# OpenAI Codex Goals Best Practices

Reference for writing and managing Codex Goals — the persistent objective feature introduced in Codex 0.128.0. "Best practices" here means the patterns and anti-patterns that determine whether a Goal completes against the right evidence vs. silently against the wrong surface. Contains 31 rules across 8 categories, ordered by how much they affect whether a Goal completes correctly. Derived from the official OpenAI cookbook article ["Using Goals in Codex"](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex).

## When to Apply

Reference these guidelines when:
- Deciding whether a task warrants a `/goal` or a normal prompt
- Drafting or strengthening a `/goal` invocation
- Reviewing a Goal someone else wrote before activating it
- Debugging a Goal that completed against the wrong verification surface
- Setting up a research Goal where exact proof may not be available
- Managing Goal lifecycle (pause, resume, clear) across thread sessions
- Writing the iteration policy or blocked stop condition for a long-running Goal
- Diagnosing a Goal that hit its budget without completing

## Rule Categories by Priority

| Priority | Category | Impact (worst rule) | Prefix |
|----------|----------|--------|--------|
| 1 | Goal Fit Decisions | CRITICAL | `fit-` |
| 2 | Outcome Definition | CRITICAL / HIGH | `outcome-` |
| 3 | Verification Surface | CRITICAL / HIGH | `verify-` |
| 4 | Boundaries & Iteration | HIGH | `bound-` |
| 5 | Lifecycle Commands | HIGH | `life-` |
| 6 | Evidence-Based Completion | HIGH | `evidence-` |
| 7 | Crafting Strong Goals | MEDIUM | `craft-` |
| 8 | Research Goals & Anti-Patterns | MEDIUM | `research-` |

Individual rule impacts are listed inline in the per-rule frontmatter.

## Quick Reference

### 1. Goal Fit Decisions (CRITICAL)

- [`fit-when-to-use`](references/fit-when-to-use.md) — Use a Goal When the Finish Line Is Clear but the Path Is Uncertain
- [`fit-three-required-properties`](references/fit-three-required-properties.md) — Require Three Properties Before Setting a Goal — Durable Objective, Evidence Finish Line, Multi-Turn Path
- [`fit-prompt-vs-goal`](references/fit-prompt-vs-goal.md) — Choose a Prompt for Single-Turn Work, a Goal for Outcome-Driven Continuation
- [`fit-skip-for-vague-targets`](references/fit-skip-for-vague-targets.md) — Skip a Goal When the Finish Line Is Vague

### 2. Outcome Definition (CRITICAL)

- [`outcome-measurable-end-state`](references/outcome-measurable-end-state.md) — State the Outcome as a Measurable End State, Not an Activity
- [`outcome-quantify-thresholds`](references/outcome-quantify-thresholds.md) — Pin Thresholds with Numbers, Not Relative Comparatives
- [`outcome-narrow-but-discoverable`](references/outcome-narrow-but-discoverable.md) — Make the Outcome Narrow Enough to Audit, Broad Enough to Allow Discovery
- [`outcome-name-the-artifact`](references/outcome-name-the-artifact.md) — For Generated Artifacts, Name the Artifact and Its Validity Conditions

### 3. Verification Surface (CRITICAL)

- [`verify-name-the-surface`](references/verify-name-the-surface.md) — Always Name the Verification Surface Inside the Goal
- [`verify-include-constraints`](references/verify-include-constraints.md) — Include Constraints That Must Not Regress Alongside the Primary Metric
- [`verify-multiple-checks-when-needed`](references/verify-multiple-checks-when-needed.md) — Use Multiple Verification Surfaces When a Single Check Is Insufficient
- [`verify-surface-must-be-runnable`](references/verify-surface-must-be-runnable.md) — The Verification Surface Must Be Something Codex Can Actually Run or Inspect

### 4. Boundaries & Iteration (HIGH)

- [`bound-tools-and-files`](references/bound-tools-and-files.md) — Bound the Files, Tools, and Repositories Codex May Use
- [`bound-iteration-policy`](references/bound-iteration-policy.md) — Define an Iteration Policy — How Codex Chooses the Next Experiment Between Turns
- [`bound-blocked-stop-condition`](references/bound-blocked-stop-condition.md) — Define a Blocked Stop Condition — What to Report When No Defensible Path Remains
- [`bound-respect-budget`](references/bound-respect-budget.md) — Treat the Budget Limit as Halt-and-Summarize, Not Extend

### 5. Lifecycle Commands (HIGH)

- [`life-set-with-slash-goal`](references/life-set-with-slash-goal.md) — Set a Goal with `/goal <text>` — Available from Codex 0.128.0
- [`life-pause-during-detours`](references/life-pause-during-detours.md) — Pause the Goal Before Unrelated Detours, Resume When Returning
- [`life-clear-stale-goals`](references/life-clear-stale-goals.md) — Clear Stale Goals on Resumed Threads
- [`life-inspect-with-slash-goal`](references/life-inspect-with-slash-goal.md) — Use Bare `/goal` to Inspect Current Objective and State Before Continuation

### 6. Evidence-Based Completion (HIGH)

- [`evidence-audit-before-completion`](references/evidence-audit-before-completion.md) — Audit the Objective Against Concrete Evidence Before Marking a Goal Complete
- [`evidence-budget-is-not-completion`](references/evidence-budget-is-not-completion.md) — Reaching the Budget Limit Is Not the Same as Completing the Objective
- [`evidence-honest-blockers`](references/evidence-honest-blockers.md) — Surface Blockers Explicitly — Never Substitute a Proxy for the Asked Claim

### 7. Crafting Strong Goals (MEDIUM)

- [`craft-six-components`](references/craft-six-components.md) — Define Six Components in Every Strong Goal — Outcome, Verification, Constraints, Boundaries, Iteration Policy, Blocked Stop
- [`craft-template-pattern`](references/craft-template-pattern.md) — Use the Canonical "verified by … while preserving … Use … Between iterations … If blocked …" Pattern
- [`craft-let-codex-draft-it`](references/craft-let-codex-draft-it.md) — Ask Codex to Draft the Goal from a Plain-Language Description, Then Tighten
- [`craft-strengthen-weak-goals`](references/craft-strengthen-weak-goals.md) — Strengthen a Weak Goal by Naming the End State, Verification Surface, and Constraints

### 8. Research Goals & Anti-Patterns (MEDIUM)

- [`research-define-evidence-standard-first`](references/research-define-evidence-standard-first.md) — For Research Goals, Define the Evidence Standard Before Investigation Begins
- [`research-build-claim-inventory`](references/research-build-claim-inventory.md) — Decompose Research Goals into a Claim Inventory Mapped to Evidence Channels
- [`research-preserve-epistemic-ledger`](references/research-preserve-epistemic-ledger.md) — Final Report Must Preserve Epistemic Levels Per Claim — Use a Structured Ledger Entry
- [`research-anti-patterns`](references/research-anti-patterns.md) — Avoid the Three Common Goal Anti-Patterns — Keep-Going Wishes, Hidden Uncertainty, Overclaim on Proxy

## How to Use

Read individual reference files for detailed explanations and worked examples comparing weak vs strong Goal text:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

Each rule file contains:
- A 2-4 sentence explanation of WHY the rule matters
- An "Incorrect" example of a weak Goal or anti-pattern
- A "Correct" example showing how to strengthen it
- Reference back to the cookbook section it derives from

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Compiled TOC built by `build-agents-md.js` |
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
| [gotchas.md](gotchas.md) | Failure points discovered through use |
