---
name: adversarial-phoenix-liveview
description: Use this skill to gate Phoenix LiveView realtime UIs with a pass/fail adversarial review — two blind reviewer subagents judge a diff or file set against 32 decidable rules covering state ownership and lifecycle (patch vs remount, callback load placement, connected-mount guards, form recovery), realtime data flow (broadcast placement, scoped topics, presence mechanisms), async responsiveness (blocking external calls, socket-copying closures, lifecycle-owned tasks, rendered failure states), render and wire efficiency (the constructs that silently disable HEEx change tracking), streams (growing collections in assigns, the stream DOM contract, bounded infinite scroll), component and context boundaries, client trust (per-event authorization, scoped lookups, live_session boundaries, revocation disconnects), and mechanism-presence interaction feedback (JS commands, in-flight feedback, debounce, hook contracts, overlay focus). Verdicts only, never fixes.
---

# Adversarial Phoenix LiveView Gate

A realtime-UI architecture review gate for Phoenix LiveView — pass/fail: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The rules target one failure mode: **LiveView written as a page-controller bolted to a JS framework, instead of what it is — a stateful process rendering change-tracked diffs over a lossy socket**. Remounts that destroy state a patch would keep, broadcasts emitted where only one writer fires them, external calls that freeze the whole view, template constructs that silently disable change tracking, collections that grow per-socket memory without bound, events trusted because the button was hidden, and interactions designed against localhost latency. These all compile cleanly and demo perfectly; they surface as memory bloat, stale UIs, frozen views, and IDOR reports in production. Each rule carries an **Evidence of violation** paragraph so a reviewer can decide PASS/FAIL/N/A from artifact evidence alone. Sibling gates: `adversarial-beam` judges message-delivery semantics, `adversarial-elixir` judges paradigm fit — run all three for full coverage of substantial Phoenix work.

## When to Apply

- A Phoenix LiveView feature — live views, live components, HEEx templates, PubSub-driven UI updates, presence, infinite scroll — is about to merge and needs an objective PASS/FAIL on its realtime-UI architecture.
- An agent (Claude, Codex) authored LiveView code and you want an independent check that it did not fake realtime correctness — controller habits, unscoped topics, unbounded assigns, unauthorized event handlers, zero-latency assumptions.
- A LiveView app is being prepared for real traffic and the localhost-era assumptions (no latency, one node, small data, trusted clients) need to be surfaced as verdicts.
- A production incident (memory bloat, frozen view, IDOR, stale UI) was fixed at one site and you want the same class hunted across the affected area.

Do not apply to non-Phoenix codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. Version note: every FAIL trigger rests on LiveView 1.0+ APIs (streams, async, JS commands); the missing-`:key` leg is version-gated to LiveView 1.1+ (colocated hooks never trigger a FAIL), and `current_scope` spellings are Phoenix 1.8 scaffolding — pre-1.8 targets are judged on the underlying shape (actor-filtered access). The reviewer prompt carries the applicability axes.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Record the stack facts (from `mix.exs`, the router, and `config/`) — phoenix/phoenix_live_view versions, scope module presence, PubSub/Presence usage, `live_session` blocks and their `on_mount` hooks, where global CSS lives. Include the repo root in the target description — several rules must search beyond the diff for context callers, router auth hooks, revocation flows, loading-class styling, and component definitions (the reviewer prompt lists them).
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `state-*.md`, `flow-*.md`, `async-*.md`, `render-*.md`, `stream-*.md`, `bound-*.md`, `trust-*.md`, `ui-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, and the stack facts. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (not a Phoenix LiveView target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | The wrong assumption it gates |
|---|----------|--------|-------------------------------|
| 1 | State Ownership & Lifecycle | `state-` | "A LiveView is a page" — remounts where patches suffice, loads in the wrong callback, stateful work in the disconnected mount, forms that lose input on reconnect |
| 2 | Realtime Data Flow | `flow-` | "Realtime means broadcasting whatever, from wherever" — broadcasts in the LiveView instead of beside the context write, global unscoped topics, hand-rolled presence |
| 3 | Async & Process Responsiveness | `async-` | "The LiveView process is free" — blocking external calls, sockets copied into closures, fire-and-forget work tied to UI lifetime, async results with no failure branch |
| 4 | Render & Wire Efficiency | `render-` | "HEEx is a template language" — data loading in templates, template variables, whole-`assigns` passing, `Map.put` on assigns, unkeyed `Enum.map` rendering |
| 5 | Collections & Streams | `stream-` | "Assigns are free" — growing collections in socket memory, broken stream DOM contract, unbounded infinite scroll |
| 6 | Component & Context Boundaries | `bound-` | "The LiveView is the app" — Repo/Ecto in web modules, LiveComponents as code folders, PubSub between a component and its own parent, missing `@myself` targets |
| 7 | Client Trust & Event Security | `trust-` | "The UI constrains the user" — unauthorized `handle_event`s, bare-id lookups (IDOR), mixed-auth `live_session`s, sockets that outlive revocation |
| 8 | Interaction Feedback & Client Commands | `ui-` | "Localhost latency is the product" — round-trips for pure presentation, zero in-flight feedback, undebounced inputs, broken hook/ignore contracts, focus-less overlays |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching reviewers — it pre-records scope guards (sibling-gate boundaries, every-rule-fails-closed, mechanism-presence-not-appearance for `ui-*`, shapes-not-brands, the `current_scope` spelling note, the Repo-CRUD exemption, the wire-cost-not-breakage framing) so reviewers do not judge outside the rules.

## Related Skills

- `adversarial-beam` — the runtime-semantics sibling gate: delivery guarantees, backpressure, supervision, shared-state races. This gate stops where the socket meets PubSub; that one owns what happens to the messages.
- `adversarial-elixir` — the paradigm-fit sibling gate: OO/enterprise habits ported onto the BEAM. Same protocol, complementary rules.
- `staff-level-elixir` — the advisory sibling: greenfield "which tool, which convention" guidance and judgment calls the gates deliberately exclude. Use it to write or fix code; use the gates to verdict it.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
