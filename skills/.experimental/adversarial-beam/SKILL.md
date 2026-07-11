---
name: adversarial-beam
description: Use this skill to gate Elixir/OTP systems on BEAM runtime architecture with a pass/fail adversarial review — two blind reviewer subagents judge a diff or file set against 23 decidable rules covering supervision and failure design (restart strategy vs child dependencies, blocking init, durability in terminate, restart amnesia, unsupervised fire-and-forget), backpressure (cast on externally-driven ingest, push pipelines without demand, silenced or retried call timeouts, unbounded fan-out), event delivery semantics (PubSub treated as durable, jobs enqueued outside the creating transaction, non-idempotent consumers under at-least-once delivery, cross-source ordering, telemetry handlers that block or detach), shared-state races (check-then-act on ETS/Registry, hot reads through one mailbox, persistent_term churn), distribution (global singletons in netsplits, node-local uniqueness assumed cluster-wide), and runtime mechanics (wall-clock durations, sub-binary leaks, minted atoms). Verdicts only, never fixes.
---

# Adversarial BEAM Gate

A BEAM runtime-architecture review gate for Elixir systems — pass/fail: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The rules target one failure mode: **code that assumes guarantees the runtime never made** — that restarts restore data, that mailboxes push back, that broadcasts arrive, that delivery happens exactly once and in order, that a lookup is still true at the following insert, that node-local uniqueness holds cluster-wide, that the wall clock only moves forward. These bugs compile cleanly, pass unit tests, and surface as production incidents. Each rule carries an **Evidence of violation** paragraph so a reviewer can decide PASS/FAIL/N/A from artifact evidence alone. The sibling gate `adversarial-elixir` judges paradigm fit (OO habits ported onto the BEAM); this gate judges runtime semantics — run both for full coverage.

## When to Apply

- An Elixir feature that supervises processes, consumes events/jobs/streams, broadcasts over PubSub, or shares state via ETS/Registry is about to merge and needs an objective PASS/FAIL on its runtime assumptions.
- An agent (Claude, Codex) authored OTP-shaped code and you want an independent check that it did not assume durable broadcasts, exactly-once delivery, ordered cross-process messages, or restart-survivable in-memory state.
- A system is being prepared for clustering or higher load, and the single-node/low-traffic assumptions baked into it need to be surfaced as verdicts.
- An incident postmortem fixed one instance of a delivery/overload bug and you want the same class hunted across the affected area.

Do not apply to non-Elixir codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. The `dist-*` category goes N/A when the application demonstrably never clusters; Oban/Broadway appear in rules as canonical remedies but any mechanism with the same property passes — the reviewer prompt carries the applicability axes.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Record the stack facts (from `mix.exs` and `config/`) — Elixir/OTP requirement, clustering present or absent, Ecto/Oban/Broadway/PubSub presence, telemetry attachments. Include the repo root in the target description — several rules must search beyond the diff for sibling `init` bodies, rehydration paths, durable mechanisms, and clustering config (the reviewer prompt lists them).
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `sup-*.md`, `load-*.md`, `evt-*.md`, `state-*.md`, `dist-*.md`, `mech-*.md` files).
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

| # | Category | Prefix | The wrong assumption it gates |
|---|----------|--------|-------------------------------|
| 1 | Supervision & Failure Design | `sup-` | "The supervisor restarts it, so we recover" — strategies ignoring child dependencies, blocking `init`, durability in `terminate/2`, restart amnesia, unawaited/unsupervised tasks |
| 2 | Backpressure & Overload | `load-` | "The BEAM handles load" — `cast` on externally-driven ingest, push pipelines with no demand signal, `:infinity`/blind-retry timeout handling, input-sized `Task.async` fan-out |
| 3 | Event Delivery Semantics | `evt-` | "The event will arrive, once, in order" — PubSub as sole carrier of business facts, side effects enqueued outside the creating transaction, non-idempotent consumers, cross-source ordering, blocking/detaching telemetry handlers, persisted broadcast snapshots |
| 4 | Shared State & Consistency | `state-` | "I just checked, it's still true" — lookup-then-write races on ETS/Registry, pure-read `call`s serializing hot paths, `persistent_term.put` at runtime cadence |
| 5 | Distribution Reality | `dist-` | "One per cluster" enforced by node-local tools — `:global` singletons without fencing, Registry/ETS uniqueness assumed cluster-wide |
| 6 | Runtime Mechanics | `mech-` | Misused clocks, binaries, atoms — wall-clock duration math, sub-binaries pinning large parents in long-lived state, atoms minted from external input |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching reviewers — it pre-records scope guards (the one fail-open rule, the shapes-not-brands principle, telemetry attach-versus-emit, wall-clock-as-data, `cast` not being banned per se) so reviewers do not judge outside the rules.

## Related Skills

- `adversarial-elixir` — the paradigm-fit sibling gate: OO/enterprise habits ported onto the BEAM (layering, processes as objects, anemic data, defensive flow). Same protocol, complementary rules; run both on substantial OTP work.
- `staff-level-elixir` — the advisory sibling: greenfield "which tool, which convention" guidance and judgment calls both gates deliberately exclude. Use it to write or fix code; use the gates to verdict it.
- `elixir-meta-programming` — how to build macros/DSLs correctly when one is warranted; out of this gate's scope entirely.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
