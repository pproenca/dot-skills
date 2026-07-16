---
name: adversarial-tanstack
description: Use this skill to gate TanStack Start plus TypeScript web-app changes with a pass/fail adversarial review — two blind reviewer subagents independently judge a diff or file set against 22 decidable rules covering client/server boundary leaks, server-function and server-route usage, auth and security, SSR data loading, boundary type safety, and compiler config. Trigger it before merging TanStack Start work, when asked to gate, adversarially review, or pass/fail a Start or TanStack codebase, or as a final check on agent-authored Start features. It renders verdicts only and never fixes the work; for teaching-style review feedback use a distillation skill instead.
---

# Adversarial TanStack Gate

A merge gate for TanStack Start + TypeScript web-app changes — a pass/fail gate: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

Rules are pinned to `@tanstack/react-start` 1.168+ (v1 RC, July 2026) and TypeScript 5.8–6.x semantics.

## When to Apply

- A TanStack Start feature, route, or server function is about to merge and needs an objective PASS/FAIL, not advisory feedback.
- An agent (Claude, Codex) authored Start app code and you want an independent check its author bias cannot rubber-stamp.
- A diff touches the client/server boundary — env vars, loaders, server functions, auth — where a wrong PASS ships secrets or unauthorized data access.
- Auditing an existing Start codebase file set against the current v1 RC API surface (stale `.inputValidator()`, removed `createServerFileRoute`).

Do not apply to non-Start React apps (most `serverfn`/`boundary`/`ssr` rules will return N/A and the gate degenerates to a TypeScript check) or when the user wants explanations and refactors rather than a verdict.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Always include `tsconfig.json`, `src/router.tsx`, and `src/start.ts` (if present) in the target paths — several rules are decided by those files even when the diff does not touch them.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `boundary-*.md`, `serverfn-*.md`, `sec-*.md`, `ssr-*.md`, `types-*.md`, `tscfg-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules and the target. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose final result is FAIL or CONTESTED must appear in the fix list with a change concrete enough to apply as written — if a reviewer's suggestion only restates the violation, derive the fix from the rule's Correct example before rendering.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Client/Server Boundary | `boundary-` | Env vars in server contexts only, loader isomorphism, public-prefix discipline |
| 2 | Server Functions & Routes | `serverfn-` | Input validators, POST for mutations, current v1 RC APIs, static imports |
| 3 | Auth & Security | `sec-` | Auth at the handler, CSRF with custom start config, cache privacy, cookie flags, enumeration |
| 4 | SSR & Data Loading | `ssr-` | Per-request router/QueryClient, useSuspenseQuery for loader data, deterministic render |
| 5 | Type Safety at Boundaries | `types-` | Schema-parse external data, exhaustive switches, escape-hatch audit, non-null assertions |
| 6 | Compiler Configuration | `tscfg-` | strict + noUncheckedIndexedAccess, erasableSyntaxOnly, verbatimModuleSyntax off (Start-specific) |

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
