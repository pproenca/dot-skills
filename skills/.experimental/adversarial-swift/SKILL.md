---
name: adversarial-swift
description: Use this skill to gate Swift language code with a pass/fail adversarial review — a single blind reviewer subagent judges a diff or file set against 36 decidable rules covering concurrency (unresumed continuations, cancellation checks, async let, TaskGroup, @concurrent), property invariants (stored-derived state, private(set), observers skipped in init, discard self), error handling (underlying errors preserved, rethrows, Result.get(), #file/#line capture), enum evolution (@unknown default, CaseIterable, synthesized Comparable, caseless namespaces), API surface (memberwise inits, OptionSet, opaque returns, unavailable stubs, Never, @autoclosure), collections (reduce(into:), mapValues, count(where:), dictionary default subscripts), and control flow and strings (branch-assigned let, raw strings, validated bytes). Works on any Swift target including server-side and CLI; verdicts only, never fixes. For SwiftUI use adversarial-swift-ui.
---

# Adversarial Swift Gate

A Swift language review gate — pass/fail: a single blind reviewer subagent judges the work against this gate's rules with an adversarial mandate, and the work passes only when every rule is PASS or N/A. This skill renders verdicts; it never fixes the work.

The rules are filtered down to the checks a reviewer can decide from code evidence alone. The gate judges the failure modes agents and experienced-but-not-expert developers actually produce: continuations that hang, loops that ignore cancellation, serialized independent awaits, hand-synchronized derived state, discarded underlying errors, hand-maintained case lists that rot, boolean parameter rows, O(n²) collection accumulation, and index arithmetic that corrupts on slices.

## When to Apply

- A Swift diff, feature, or PR is about to merge and needs an objective PASS/FAIL, not advisory feedback — any target: app logic, server-side Swift, CLI tools, packages.
- An agent (Claude, Codex) authored the code and you want an independent check that it is not reproducing the classic concurrency and error-handling failure shapes (unresumed continuation branches, `try? await Task.sleep` posing as a cancellation check, `catch` blocks that throw payload-free domain cases) or hand-rolling what the compiler synthesizes (`CaseIterable`, `Comparable`, memberwise inits, definite-initialization checking).
- Pre-concurrency or Objective-C-era Swift is being modernized and the ported surface needs auditing against current language affordances (`@unknown default`, `rethrows`, `canImport`, `reduce(into:)`, `count(where:)`, `String(validating:)`).

Do not apply to non-Swift codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. SwiftUI-specific review (state ownership, view identity, update cost, task lifecycle, lists, accessibility) is owned entirely by the sibling `adversarial-swift-ui` gate — this gate's rules are framework-independent and stay in scope alongside it. Rules whose remedy needs a newer toolchain than the project's are N/A, not FAIL — the reviewer prompt carries the version-gate table.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

Two preconditions before step 1 — both exist because their violation is the gate family's recorded field-failure mode (July 2026: gates run as cleanup drivers on a moving target rendered zero verdicts while the diff grew to 33 files):

- **Frozen target.** Dispatch only against a fixed ref — a commit SHA, stash, or saved diff — recorded as the target manifest. If the code under review is still changing (the worktree keeps collecting edits, other agents are active on it), do not dispatch. A target change while the reviewer is in flight voids the run: report `GATE VOID — target changed` in place of a verdict and re-dispatch against the new frozen state. A dispatched gate must always end in a rendered verdict, a `GATE NOT APPLICABLE`, or a recorded void — never silence, which is indistinguishable from "reviewed".
- **Verdicts, not cleanup.** This gate is a terminal check on finished work. "Run the gate and fix everything aggressively" inverts the contract and is the documented path to scope explosion: implement first, freeze, then gate. After a FAIL, the caller applies fixes within the original target only, and the re-gate dispatches a fresh blind reviewer against the **same target manifest** — the surface never widens between rounds; new code means a new gate invocation with its own manifest.

When other agents may mutate the workspace mid-review, the reviewer reads the rules from an immutable snapshot (e.g. `git archive <ref> <skill-dir> | tar -x -C "$TMPDIR"`) rather than the live checkout — and skill directories are read-only infrastructure, excluded from every cleanup or fix scope.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so the review runs against an unambiguous, fixed target. Record the stack facts the reviewer prompt requires: Swift toolchain version (from `Package.swift` or project settings), the target's default actor isolation setting (MainActor default or not — decides `conc-concurrent-offload-under-mainactor-default`), and any visible warnings-as-errors or TODO-linter conventions (carve-outs for `err-warning-directive-for-pending-work`). Include the repo root in the target description — `enum-unknown-default-external-enums`, `prop-private-set-internal-mutation`, `prop-computed-over-stored-derived`, `enum-caseless-namespaces`, `api-final-or-private-classes`, and `api-autoclosure-conditional-params` require searching beyond the diff for declaring modules, write sites, instantiations, subclasses, and call sites.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `conc-*.md`, `prop-*.md`, `err-*.md`, `enum-*.md`, `api-*.md`, `coll-*.md`, `flow-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, and the stack facts. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch one blind reviewer.** Launch a single Task subagent whose entire input is the composed prompt — no conversation context, no commentary alongside it.
5. **Render fail-closed.** The reviewer's structured output is the verdict — there is no merge step. Overall verdict is PASS only when every rule is PASS or N/A; any single FAIL fails the gate. Never average, weigh severity, or waive a rule — a "minor" FAIL is a FAIL. If the reviewer returns "GATE NOT APPLICABLE" (not a Swift target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate the reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose final result is FAIL must appear in the fix list with a change concrete enough to apply as written — if the reviewer's suggestion only restates the violation, derive the fix from the rule's Correct example before rendering. The fix list is verification material — proof that each FAIL is decidable and flippable — not a work queue: every fix names the minimal change that flips its rule inside the declared target, and a fix that reaches for an unsafe escape hatch (`@unchecked Sendable`, `try!`, force-unwraps) to satisfy a rule does not flip it. Violations the reviewer noticed outside the target manifest go under the verdict's out-of-scope observations — reported for a future gate invocation, never fixed under this one, never counted in the verdict.

If the same rule flips verdicts across re-reviews of an unchanged target, or a human reads the evidence and overrides the verdict, that is a decidability bug in the rule — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

The reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Concurrency & Task Structure | `conc-` | Continuations resume on every path, cancellation checks in long loops (`try?`-wrapped sleeps do not count), `async let` for independent awaits, `TaskGroup` over per-element unstructured spawning, `@concurrent` for CPU work under MainActor default isolation |
| 2 | Property & Resource Invariants | `prop-` | Computed over stored-derived values, `private(set)` on internally-mutated vars, `defer` for observer-firing init assignments, `discard self` when consuming cleanup duplicates `deinit` |
| 3 | Error Handling & Diagnostics | `err-` | Underlying errors attached when wrapping, `rethrows` for closure-only throws, `try result.get()` over manual switches, `#file`/`#line` as default arguments, `#warning` over shipped TODO comments |
| 4 | Enum Evolution & Exhaustiveness | `enum-` | `@unknown default` over external enums, `CaseIterable` over hand lists, synthesized `Comparable` over hand-rolled ladders, caseless-enum namespaces |
| 5 | API & Type Surface | `api-` | Memberwise init preserved via extension inits, `OptionSet` over boolean rows, `some P` over nested concrete returns, `@available(*, unavailable)` stubs, `-> Never` for trap-only paths, `@autoclosure` for gated parameters, `final`/`private` classes for static dispatch |
| 6 | Collections & Dictionaries | `coll-` | Dictionary `default:` subscripts, optional-chaining in-place mutation, `mapValues()`, `reduce(into:)`, `count(where:)` |
| 7 | Control Flow, Strings & Conditional Compilation | `flow-` | Branch-assigned `let` over placeholder `var`, `zip(indices,)` over `enumerated()` subscripting, raw strings for escape-heavy literals, `String(validating:)` for untrusted bytes, `canImport` over `#if os` chains, `Optional.take()` for one-shot consumption |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching the reviewer — it pre-records source-fidelity guards (patterns the source material endorses that community lore condemns, such as untyped `throws` remaining the recommended default over typed throws) and the rules pre-flagged as decidability-risk at creation, so the reviewer does not import outside rules and repeated verdict flips get recognized fast.

## Related Skills

- `adversarial-swift-ui` — the sibling gate owning all SwiftUI architecture review (state, identity, update cost, task lifecycle, lists, accessibility); run both on SwiftUI features.
- `ios-taste` (curated) — judgment-call iOS design guidance this gate deliberately excludes; use it when the goal is taste, not a verdict.
- `search-ios26-docs` / `search-macos26-docs` — verify current-SDK API availability when a version-gate question decides a rule.
- `adversarial-ts-patterns` / `adversarial-zod` / `adversarial-tanstack` — sibling gates for TypeScript stacks; same protocol, different rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for the blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
