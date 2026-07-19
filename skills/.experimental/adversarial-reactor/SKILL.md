---
name: adversarial-reactor
description: Use this skill to gate Elixir code built on the Reactor orchestration library (~> 1.0) with a pass/fail adversarial review — a single blind reviewer subagent judges a diff or file set against 28 decidable rules covering saga compensation and undo (side effects without undo, cleanup in the wrong callback, compensate returns that roll back vs continue, non-idempotent undo), retry discipline (uncapped retries under the max_retries infinity default, retrying business failures, missing backoff), dependency and data flow (lexical-order assumptions, context smuggling, missing return), step contracts (invalid run/3 returns, halt misused as failure, guard/where confusion, side effects in inline fns), composition (Reactor.run inside steps instead of compose, Enum loops over map steps, case over switch, unbounded recurse), concurrency (serial-by-default map, sandbox tests left async, process-context loss), and middleware contracts. Verdicts only, never fixes.
---

# Adversarial Reactor Gate

A saga/dataflow-orchestration review gate for Elixir code built on Reactor — pass/fail: a single blind reviewer subagent judges the work against this gate's rules with an adversarial mandate, and the work passes only when every rule is PASS or N/A. This skill renders verdicts; it never fixes the work.

The rules target one failure mode: **code that assumes guarantees Reactor never made** — that rollback is automatic, that cleanup in `compensate` fires on downstream failure, that `:ok` absorbs an error, that steps run in the order they were written, that `:retry` is bounded by default, that `{:halt, reason}` aborts, that map steps parallelize, that process-local state follows a step into its task process. These bugs compile cleanly, pass happy-path tests, and surface as orphaned payments, infinite retry loops, and races. Each rule carries an **Evidence of violation** paragraph so a reviewer can decide PASS/FAIL/N/A from artifact evidence alone. The sibling gates judge different layers: `adversarial-elixir` paradigm fit, `adversarial-beam` runtime semantics — run them alongside for full coverage of OTP-shaped work.

## When to Apply

- An Elixir feature that defines or modifies Reactor workflows (`use Reactor` modules, `Reactor.Step` implementations, `Reactor.run` call sites) is about to merge and needs an objective PASS/FAIL on its orchestration semantics.
- An agent (Claude, Codex) authored a Reactor saga and you want an independent check that it did not park cleanup in the wrong callback, leave side effects irreversible, or assume lexical step order.
- A workflow is being promoted from happy-path prototype to production (payments, provisioning, imports) and its failure/rollback/retry paths need to be surfaced as verdicts.
- An incident postmortem fixed one orphaned-side-effect or retry-storm bug and you want the same class hunted across the reactors in the affected area.

Do not apply to targets with no Reactor usage (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. General OTP/BEAM concerns (supervision, PubSub, ETS) belong to `adversarial-beam`; Elixir paradigm fit belongs to `adversarial-elixir`.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so the review runs against an unambiguous, fixed target. Record the stack facts (from `mix.exs`, `mix.lock`, `test_helper.exs`) — Reactor version, Ecto/sandbox presence, mocking library, telemetry consumers. Include the repo root in the target description — several rules must search beyond the diff for mounted step modules' callbacks, `Reactor.run` call sites, and middleware modules (the reviewer prompt lists them).
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `saga-*.md`, `retry-*.md`, `dep-*.md`, `step-*.md`, `comp-*.md`, `conc-*.md`, `obs-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, and the stack facts. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch one blind reviewer.** Launch a single Task subagent whose entire input is the composed prompt — no conversation context, no commentary alongside it.
5. **Render fail-closed.** The reviewer's structured output is the verdict — there is no merge step. Overall verdict is PASS only when every rule is PASS or N/A; any single FAIL fails the gate. Never average, weigh severity, or waive a rule — a "minor" FAIL is a FAIL. If the reviewer returns "GATE NOT APPLICABLE" (no Reactor usage in the target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate the reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose result is FAIL must appear in the fix list with a change concrete enough to apply as written — if the reviewer's suggestion only restates the violation, derive the fix from the rule's correct example before rendering.

If the same rule flips verdicts across re-reviews of an unchanged target, or a human reads the evidence and overrides the verdict, that is a decidability bug in the rule — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

The reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | The wrong assumption it gates |
|---|----------|--------|-------------------------------|
| 1 | Saga Compensation & Undo | `saga-` | "Rollback is automatic" — side effects without `undo/4`, cleanup in `compensate` (fires on the step's *own* failure, receives the error), `:ok` believed to absorb errors (only `{:continue, value}` does), undo that breaks on re-execution |
| 2 | Retry Discipline | `retry-` | "`:retry` is safe" — catch-all retries under the `max_retries :infinity` DSL default, retrying deterministic business failures, immediate-retry hot loops with no `backoff/4` |
| 3 | Dependency & Data Flow | `dep-` | "Steps run in the order I wrote them" — ordered side effects without `argument`/`wait_for` edges, inter-step data smuggled through `context` (no edge, races), fake unused arguments, multi-step reactors without `return` |
| 4 | Step Contracts | `step-` | Wrong callback shapes — non-documented `run/3` returns treated as failure, `{:halt, reason}` as an error signal (it pauses, skips rollback), boolean guards / `:cont` from `where`, skip-conditionals inlined in `run`, side effects in unmockable inline fns |
| 5 | Composition & Iteration | `comp-` | Hand-rolling what the DSL plans — `Reactor.run` inside steps (child escapes parent rollback), `Enum` loops over `map` steps, `case` side-effect branching over `switch`, `recurse` without `max_iterations`, materialized datasets as `map` sources |
| 6 | Concurrency & Process Context | `conc-` | "Async just works" — `map`'s `allow_async?` defaults `false` (serial), sandbox tests without `async?: false`, process-local state lost across the task boundary, `async? false` scattering instead of run-level `max_concurrency` |
| 7 | Observability & Middleware | `obs-` | Lifecycle logging hand-rolled in steps when `Reactor.Middleware.Telemetry` emits it all, middleware callbacks returning bare values, I/O inside `event/3` on the executor's critical path |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching the reviewer — it pre-records scope guards (shapes-not-brands, what counts as a side effect, the diff-vs-repo search obligations) so the reviewer does not judge outside the rules.

## Related Skills

- `adversarial-beam` — the runtime-semantics sibling gate: supervision, backpressure, event delivery, shared state, distribution. A Reactor workflow lives inside an OTP app; run both on substantial work.
- `adversarial-elixir` — the paradigm-fit sibling gate: OO/enterprise habits ported onto the BEAM. Same protocol, complementary rules.
- `staff-level-elixir` — the advisory sibling: greenfield "which tool, which convention" guidance and judgment calls the gates deliberately exclude. Use it to write or fix code; use the gates to verdict it.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
