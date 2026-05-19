# Codex (CLI) — Goals feature

**Version 0.1.0**  
OpenAI  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Patterns and anti-patterns for using OpenAI Codex Goals — the persistent objective feature introduced in Codex 0.128.0 that turns a thread from a sequence of isolated prompts into a stateful work loop with evidence-based completion. Contains 31 rules across 8 categories covering Goal fit decisions, outcome definition, verification surfaces, boundaries and iteration policy, lifecycle commands, evidence-based completion, crafting strong Goals, and research-Goal special cases. Each rule includes a 2-4 sentence rationale and a weak-vs-strong example pair derived from the official OpenAI cookbook article.

---

## Table of Contents

1. [Goal Fit Decisions](references/_sections.md#1-goal-fit-decisions) — **CRITICAL**
   - 1.1 [Choose a Prompt for Single-Turn Work, a Goal for Outcome-Driven Continuation](references/fit-prompt-vs-goal.md) — CRITICAL (prevents miscategorizing work and choosing the wrong operating model)
   - 1.2 [Require Three Properties Before Setting a Goal — Durable Objective, Evidence Finish Line, Multi-Turn Path](references/fit-three-required-properties.md) — CRITICAL (prevents Goals that either spin forever or finish in one turn anyway)
   - 1.3 [Skip a Goal When the Finish Line Is Vague](references/fit-skip-for-vague-targets.md) — CRITICAL (prevents the most common Goal failure mode — open-ended objectives that never close)
   - 1.4 [Use a Goal When the Finish Line Is Clear but the Path Is Uncertain](references/fit-when-to-use.md) — CRITICAL (prevents misuse of persistence machinery on single-turn tasks)
2. [Outcome Definition](references/_sections.md#2-outcome-definition) — **CRITICAL**
   - 2.1 [For Generated Artifacts, Name the Artifact and Its Validity Conditions](references/outcome-name-the-artifact.md) — HIGH (enables artifact-level audit instead of completion based on plausibility)
   - 2.2 [Make the Outcome Narrow Enough to Audit, Broad Enough to Allow Discovery](references/outcome-narrow-but-discoverable.md) — HIGH (prevents both over-narrow Goals that miss the root cause and over-broad Goals with no audit surface)
   - 2.3 [Pin Thresholds with Numbers, Not Relative Comparatives](references/outcome-quantify-thresholds.md) — CRITICAL (eliminates the moving target where any positive delta passes for done)
   - 2.4 [State the Outcome as a Measurable End State, Not an Activity](references/outcome-measurable-end-state.md) — CRITICAL (prevents drift by making every iteration check a boolean condition)
3. [Verification Surface](references/_sections.md#3-verification-surface) — **CRITICAL**
   - 3.1 [Always Name the Verification Surface Inside the Goal](references/verify-name-the-surface.md) — CRITICAL (prevents completion claims grounded in model belief rather than concrete artifacts)
   - 3.2 [Include Constraints That Must Not Regress Alongside the Primary Metric](references/verify-include-constraints.md) — CRITICAL (prevents Pyrrhic completions where the headline metric improves but something important broke)
   - 3.3 [The Verification Surface Must Be Something Codex Can Actually Run or Inspect](references/verify-surface-must-be-runnable.md) — CRITICAL (prevents Goals that look verifiable on paper but can't be checked in practice)
   - 3.4 [Use Multiple Verification Surfaces When a Single Check Is Insufficient](references/verify-multiple-checks-when-needed.md) — HIGH (prevents single-point-of-failure verification that misses important regressions)
4. [Boundaries & Iteration](references/_sections.md#4-boundaries-&-iteration) — **HIGH**
   - 4.1 [Bound the Files, Tools, and Repositories Codex May Use](references/bound-tools-and-files.md) — HIGH (prevents scope creep into unrelated code that risks side effects on critical-path systems)
   - 4.2 [Define a Blocked Stop Condition — What to Report When No Defensible Path Remains](references/bound-blocked-stop-condition.md) — HIGH (prevents Codex from declaring false completion or spinning when the real answer is "stuck")
   - 4.3 [Define an Iteration Policy — How Codex Chooses the Next Experiment Between Turns](references/bound-iteration-policy.md) — HIGH (prevents thrashing and preserves learning across iterations via a recorded reasoning trail)
   - 4.4 [Treat the Budget Limit as Halt-and-Summarize, Not Extend](references/bound-respect-budget.md) — HIGH (prevents overspending by forcing halt-and-summarize at budget exhaustion)
5. [Lifecycle Commands](references/_sections.md#5-lifecycle-commands) — **HIGH**
   - 5.1 [Clear Stale Goals on Resumed Threads](references/life-clear-stale-goals.md) — HIGH (prevents Codex from acting on an objective that no longer applies to the current work)
   - 5.2 [Pause the Goal Before Unrelated Detours, Resume When Returning](references/life-pause-during-detours.md) — HIGH (prevents Codex from continuing toward the Goal while you're context-switching to unrelated work)
   - 5.3 [Set a Goal with `/goal <text>` — Available from Codex 0.128.0](references/life-set-with-slash-goal.md) — HIGH (prevents fallback to manual "keep going" prompts that miss the persistence and audit guarantees)
   - 5.4 [Use Bare `/goal` to Inspect Current Objective and State Before Continuation](references/life-inspect-with-slash-goal.md) — HIGH (prevents surprise about what Codex thinks the active objective is)
6. [Evidence-Based Completion](references/_sections.md#6-evidence-based-completion) — **HIGH**
   - 6.1 [Audit the Objective Against Concrete Evidence Before Marking a Goal Complete](references/evidence-audit-before-completion.md) — HIGH (prevents completion claims based on model belief rather than verification surface output)
   - 6.2 [Reaching the Budget Limit Is Not the Same as Completing the Objective](references/evidence-budget-is-not-completion.md) — HIGH (prevents overstating progress by collapsing budget-limited into complete)
   - 6.3 [Surface Blockers Explicitly — Never Substitute a Proxy for the Asked Claim](references/evidence-honest-blockers.md) — HIGH (prevents approximate evidence from being mislabeled as the asked claim)
7. [Crafting Strong Goals](references/_sections.md#7-crafting-strong-goals) — **MEDIUM**
   - 7.1 [Ask Codex to Draft the Goal from a Plain-Language Description, Then Tighten](references/craft-let-codex-draft-it.md) — MEDIUM (reduces authoring cost for strong Goals by splitting drafting from tightening)
   - 7.2 [Define Six Components in Every Strong Goal — Outcome, Verification, Constraints, Boundaries, Iteration Policy, Blocked Stop](references/craft-six-components.md) — MEDIUM (prevents missing components that predict Goal failure modes (Pyrrhic completion, scope creep, fake completion))
   - 7.3 [Strengthen a Weak Goal by Naming the End State, Verification Surface, and Constraints](references/craft-strengthen-weak-goals.md) — MEDIUM (enables a repeatable weak-to-strong upgrade path for one-line aspirational Goals)
   - 7.4 [Use the Canonical "verified by … while preserving … Use … Between iterations … If blocked …" Pattern](references/craft-template-pattern.md) — MEDIUM (prevents partial Goals by surfacing empty clauses before activation)
8. [Research Goals & Anti-Patterns](references/_sections.md#8-research-goals-&-anti-patterns) — **MEDIUM**
   - 8.1 [Avoid the Three Common Goal Anti-Patterns — Keep-Going Wishes, Hidden Uncertainty, Overclaim on Proxy](references/research-anti-patterns.md) — MEDIUM (prevents three common Goal failure modes that produce untrustworthy completions)
   - 8.2 [Decompose Research Goals into a Claim Inventory Mapped to Evidence Channels](references/research-build-claim-inventory.md) — MEDIUM (prevents dropping or relabeling unverifiable claims by forcing per-claim status)
   - 8.3 [Final Report Must Preserve Epistemic Levels Per Claim — Use a Structured Ledger Entry](references/research-preserve-epistemic-ledger.md) — MEDIUM (prevents flattening confirmed/approximate/blocked into a single "done" claim)
   - 8.4 [For Research Goals, Define the Evidence Standard Before Investigation Begins](references/research-define-evidence-standard-first.md) — MEDIUM (prevents the final report from quietly drifting toward a single "done" claim across different epistemic levels)

---

## References

1. [https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |