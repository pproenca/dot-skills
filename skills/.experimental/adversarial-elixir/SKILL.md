---
name: adversarial-elixir
description: Use this skill to gate Elixir, OTP, Ecto, and Phoenix code with a pass/fail adversarial review — two blind reviewer subagents independently judge a diff or file set against 19 decidable rules that catch architecture ported from an alien paradigm, covering enterprise layering (repository wrappers over Ecto, service-object tiers, DI behaviours with a single implementation, logic trapped in effectful callbacks), processes as objects (GenServer-per-entity, Agents as mutable variables, leaked message protocols, singleton managers), anemic data (bare maps as entities, boolean-flag state, hand-rolled type dispatch, 32+-field structs), defensive control flow (raise/rescue as branching, nil-guard swallowing, raw input past the boundary), transliterated loops, and needless metaprogramming (macro DSLs for data, use-as-import, compile-time coupling). Trigger it before merging Elixir work, or to check agent-authored code. It renders verdicts only, never fixes; Ecto-dependent rules go N/A without Ecto.
---

# Adversarial Elixir Gate

An Elixir/OTP/Ecto/Phoenix review gate — pass/fail: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The rules target one failure mode: **code that imported the wrong mental model onto the BEAM** — OO/enterprise layering, processes treated as objects, anemic data, defensive control flow, transliterated loops, and needless metaprogramming. They are grounded in the official Elixir anti-pattern catalogs and each carries an **Evidence of violation** paragraph so a reviewer can decide PASS/FAIL/N/A from artifact evidence alone. Judgment-call refactor guidance stays in the advisory sibling `staff-level-elixir`.

## When to Apply

- An Elixir diff, feature, or PR is about to merge and needs an objective PASS/FAIL, not advisory feedback.
- An agent (Claude, Codex) authored the code and you want an independent check that it did not reproduce OO habits — repository wrappers over Ecto, `*Service`/`*Manager` tiers, a GenServer per entity, DI behaviours for a single implementation, raise/rescue as an `if`.
- Code ported from Java/Ruby/Python (or written by developers newer to the BEAM) needs auditing for paradigm fit before it calcifies.
- A refactor claims to have "made it idiomatic" and you want the claim verified, not assumed.

Do not apply to non-Elixir codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict — that is `staff-level-elixir`'s job. `arch-delete-repository-over-ecto` goes N/A when the target has no Ecto; `flow-normalize-at-boundary` goes N/A when the target has no external-input path. Remedies newer than the project's Elixir version are judged against the nearest available remedy — the reviewer prompt carries the version-gate table.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Record the Elixir version and key deps (from `mix.exs` — the `elixir:` requirement, Phoenix/Ecto presence). Include the repo root in the target description — `arch-drop-di-behaviour-single-impl`, `type-protocol-over-type-dispatch`, `proc-consolidate-interface`, and `meta-use-is-not-import` require searching beyond the diff for implementing modules, duplicate dispatch sites, callback owners, and `__using__` bodies.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `arch-*.md`, `proc-*.md`, `type-*.md`, `flow-*.md`, `iter-*.md`, `meta-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, and the stack facts. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (not an Elixir target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | The alien model it gates |
|---|----------|--------|--------------------------|
| 1 | Enterprise Ceremony & Layering | `arch-` | Repository/DAO wrappers over Ecto, per-entity `*Service`/`*Manager` modules, DI behaviours with one implementation, domain decisions computed inside effectful callbacks |
| 2 | Processes as Objects | `proc-` | GenServer-per-entity mirroring DB rows, Agents as mutable variables, message tuples leaked outside the owning module, globally-named singleton managers over partitionable state |
| 3 | Anemic Data Modeling | `type-` | Fixed-shape bare maps passed as entities, multi-boolean and stringly state, type-tag dispatch duplicated across modules, structs at the 32-field runtime cliff |
| 4 | Defensive Control Flow | `flow-` | raise/rescue converting expected outcomes into branches, nil-guards that silently swallow required values, raw external input re-checked through the core |
| 5 | Imperative Iteration | `iter-` | `reduce`/recursion reimplementing a nameable `Enum` combinator — FAIL requires naming the exact replacement |
| 6 | Needless Metaprogramming & Coupling | `meta-` | First-party macro DSLs that encode plain data, `__using__` bodies that only import, module attributes calling other modules at compile time |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching reviewers — it pre-records scope guards (style lore reviewers try to import, the two name-the-replacement rules, the numeric god-struct line) so reviewers do not judge outside the rules.

## Related Skills

- `staff-level-elixir` — the advisory sibling: greenfield "which tool, which convention" guidance and the judgment calls this gate deliberately excludes. Use it to write or fix code; use this gate to verdict it.
- `elixir-meta-programming` — how to build macros/DSLs correctly once one is genuinely warranted (the complement to this gate's `meta-` rules).
- `adversarial-swift` / `adversarial-rust` / `adversarial-zod` / `adversarial-ts-patterns` / `adversarial-tanstack` — sibling gates for other stacks; same protocol, different rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
