---
name: adversarial-ts-patterns
description: Use this skill to gate TypeScript and React application code with a pass/fail adversarial review of design-pattern usage — two blind reviewer subagents independently judge a diff or file set against 18 decidable rules covering implicit state machines (boolean-flag lifecycles, useEffect chains, stored derived state, non-exhaustive union matches) and over-engineered OO/enterprise ports (getInstance singletons, factory and builder classes, single-method strategy classes, State/Visitor hierarchies, event buses inside a React tree, pass-through repositories, DI containers, single-implementation interfaces, component inheritance, logic-only HOCs, static-only classes, trivial accessors). Trigger it before merging TS/React work, when asked to gate or pass/fail pattern usage, or as a check that agent-authored code is not porting Java/C# idioms. It renders verdicts only; for teaching-style guidance use implementation-design-patterns or implementation-functional-patterns.
---

# Adversarial TS Patterns Gate

A design-pattern usage gate for TypeScript and React application code — a pass/fail gate: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The gate judges in both directions. **Over-abstraction** — Gang of Four and enterprise machinery ported from Java/C# where idiomatic TypeScript reaches for a function, a module, or a tagged union. **Under-modeling** — implicit state machines whose impossible states compile: boolean-flag lifecycles, effect chains, hand-synced derived state, silent `default` branches.

## When to Apply

- A TypeScript/React diff or feature is about to merge and needs an objective PASS/FAIL on pattern usage, not advisory feedback.
- An agent (Claude, Codex) authored the code and you want an independent check that it is not reproducing Java/C# training-data idioms — Singleton classes, factory hierarchies, repository wrappers, JavaBean accessors.
- A migration from another stack (Java, C#, Angular-style DI) claims completion and the ported architecture needs auditing for layers that lost their justification in TypeScript.
- Component or store state grew organically and you want the implicit-state-machine failure modes (contradictory booleans, effect chains, non-exhaustive matches) caught before they ship.

Do not apply to non-TypeScript codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict — that is the job of the curated `implementation-design-patterns` and `implementation-functional-patterns` skills. React-specific rules go N/A in non-React TypeScript projects; the rest of the gate works in any TypeScript application.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Include the repo root in the target description — the `layer-no-single-impl-interface` and `layer-no-di-container-in-app` rules require searching beyond the diff for second implementations and registrations.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `state-*.md`, `create-*.md`, `behave-*.md`, `layer-*.md`, `react-*.md`, `oo-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules and the target. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (not a TypeScript target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | State Modeling & Machines | `state-` | Discriminated unions over boolean flags, no effect chains, no stored derived state, exhaustive matches with `never` |
| 2 | Creational Ports | `create-` | No `getInstance()` singletons, no factory-class hierarchies, no builders for option bags |
| 3 | Behavioral Ports | `behave-` | Functions over single-method classes, unions over State/Visitor hierarchies, no event buses inside a React tree |
| 4 | Enterprise Layers | `layer-` | No pass-through repositories, no DI containers with single implementations, no single-implementation interfaces |
| 5 | React Composition | `react-` | No component inheritance, hooks over logic-only HOCs, props over imperative handles |
| 6 | OO Ceremony | `oo-` | No static-only container classes, no trivial accessor pairs |

## Related Skills

- `implementation-design-patterns` (curated) — the teaching-style reference for when a GoF class form is warranted; use it when the goal is guidance or refactoring rather than a verdict.
- `implementation-functional-patterns` (curated) — the GoF-to-functional map this gate's `create-`/`behave-` rules enforce the reviewable subset of.
- `adversarial-tanstack` / `adversarial-zod` — framework- and library-level gates for TanStack Start apps; run alongside this gate for full coverage of a Start diff.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
