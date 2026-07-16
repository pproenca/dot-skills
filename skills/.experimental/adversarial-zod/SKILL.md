---
name: adversarial-zod
description: Use this skill to gate Zod 4 schema code in TypeScript and TanStack Start apps with a pass/fail adversarial review — two blind reviewer subagents independently judge a diff or file set against 24 decidable rules covering silent Zod 3-to-4 semantic breaks (defaults, enum-keyed records, boolean coercion), removed APIs (including the z.interface hallucination), unified error customization, deprecated method forms, recursion and codec composition, adapter-free TanStack Start validators, and packaging. Trigger it before merging Zod schema work, when asked to gate, adversarially review, or pass/fail Zod usage, or as a currency check that agent-authored schemas use the latest Zod 4.x surface. It renders verdicts only and never fixes the work; for teaching-style Zod feedback use the curated zod skill instead.
---

# Adversarial Zod Gate

A currency and correctness gate for Zod schema code in TypeScript apps — a pass/fail gate: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

Rules are pinned to **zod 4.4.x** (package root since zod@4.0.0, July 2025) and, for the `start-` category, the **TanStack Start v1 RC** (`.validator()` current, `.inputValidator()` deprecated).

## When to Apply

- A diff or feature that defines or edits Zod schemas is about to merge and needs an objective PASS/FAIL on Zod 4 currency, not advisory feedback.
- An agent (Claude, Codex) authored schema code and you want an independent check that it is not reproducing Zod 3 training-data patterns — deprecated method forms, removed params, or the `z.interface()` hallucination.
- A Zod 3 → 4 migration claims completion and needs the silent semantic breaks audited (`.default()` short-circuiting, exhaustive enum-keyed records, `z.coerce.boolean()` on string flags).
- A TanStack Start app validates server-function input or search params with Zod and should be on the adapter-free Standard Schema patterns.

Do not apply to Zod 3 codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict — that is the curated `zod` distillation skill's job. The two `start-` rules go N/A outside TanStack apps; the rest of the gate works in any TypeScript project using Zod 4.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Always include `package.json` in the target paths — the Zod-4 precondition and the `pkg-`, `compose-native-json-schema`, and `start-` adapter rules are decided by its dependency pins even when the diff does not touch it.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `sem-*.md`, `gone-*.md`, `err-*.md`, `dep-*.md`, `compose-*.md`, `start-*.md`, `pkg-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules and the target. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (Zod 3 or no Zod), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose final result is FAIL or CONTESTED must appear in the fix list with a change concrete enough to apply as written — if a reviewer's suggestion only restates the violation, derive the fix from the rule's Correct example before rendering.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Silent Semantic Breaks | `sem-` | `.prefault()` for parsed defaults, `z.partialRecord()` for sparse enum keys, `z.stringbool()` for string flags |
| 2 | Removed APIs | `gone-` | `.ip()`/`.cidr()`, single-arg `z.record()`, error params trio, `.errors` getter, function factory, `z.interface()` hallucination |
| 3 | Error Customization & Formatting | `err-` | Unified `error` param over `message`, top-level `z.treeifyError`/`z.flattenError`/`z.prettifyError` |
| 4 | Deprecated Method Forms | `dep-` | Top-level string formats, `z.strictObject`/`z.looseObject`, `.extend` over `.merge`, `z.enum` over `z.nativeEnum`, `z.int()`, no `z.promise()` |
| 5 | Composition, Recursion & Codecs | `compose-` | Getter recursion, `z.codec()` for bidirectional wire transforms, native `z.toJSONSchema()` |
| 6 | TanStack Start Integration | `start-` | Bare schema to `.validator()`, adapter-free `validateSearch` |
| 7 | Packaging & Imports | `pkg-` | Root `"zod"` import path, zod/mini reserved for hard bundle constraints |

## Related Skills

- `zod` (curated) — the teaching-style distillation for Zod usage; use it when the goal is explanation or refactoring rather than a verdict.
- `adversarial-tanstack` — the framework-level gate for TanStack Start apps; run both on a Start diff for full coverage (its `serverfn-validate-input` checks that a validator exists; this gate's `start-` rules check the validator uses current Zod 4 patterns).

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
