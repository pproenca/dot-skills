---
name: adversarial-swift
description: Use this skill to gate Swift and SwiftUI code with a pass/fail adversarial review — two blind reviewer subagents independently judge a diff or file set against 44 decidable rules distilled from Natalia Panferova's Swift Gems and The SwiftUI Way, covering SwiftUI state and observation (@Observable over ObservableObject, @State ownership), view identity (applyIf-style branching, AnyLayout), view update cost (init side effects, body derivations), task lifecycle (.task over onAppear+Task), lists and geometry (AnyView rows, GeometryReader measurement), accessibility (icon-only buttons, semantic styling), Swift concurrency (unresumed continuations, retain cycles, cancellation, serialized awaits, main-actor CPU work), and API and type design (@unknown default, CaseIterable, private(set), rethrows). Trigger it before merging Swift or SwiftUI work, or to check agent-authored code. It renders verdicts only, never fixes; SwiftUI categories go N/A on non-UI Swift.
---

# Adversarial Swift Gate

A Swift and SwiftUI review gate — pass/fail: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The rules are derived from two named-expert books — *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025) for the Swift language rules and *The SwiftUI Way* (Panferova, 2026) for the SwiftUI rules — filtered down to the checks a reviewer can decide from code evidence alone. The gate judges the failure modes agents and experienced-but-not-expert developers actually produce: legacy observation stacks, identity-destroying conditionals, work attached to the wrong lifecycle point, hung continuations, retain cycles, and API surface that skips the compiler's help.

## When to Apply

- A Swift or SwiftUI diff, feature, or PR is about to merge and needs an objective PASS/FAIL, not advisory feedback.
- An agent (Claude, Codex) authored the code and you want an independent check that it is not reproducing pre-Observation SwiftUI idioms (`ObservableObject`/`@StateObject`, `.onAppear { Task { ... } }`, `AnyView`, `GeometryReader`-to-measure) or concurrency habits that hang and leak (unresumed continuation branches, strong `self` in retained closures, uncancellable loops).
- UIKit-era or cross-platform Swift is being modernized and the ported surface needs auditing against current language affordances (`@unknown default`, `CaseIterable`, `rethrows`, `canImport`, `reduce(into:)`).
- Accessibility and platform-convention compliance must be verified, not assumed — icon-only buttons, tap gestures posing as controls, hardcoded fonts and colors, silent custom controls.

Do not apply to non-Swift codebases (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. SwiftUI-specific categories (`state-`, `identity-`, `update-`, `task-`, `list-`, `access-`) go N/A in non-UI Swift targets (server-side Swift, CLI tools, packages); the `conc-`, `api-`, and `flow-` rules work in any Swift code. Rules whose remedy needs a newer toolchain or deployment target than the project's are N/A, not FAIL — the reviewer prompt carries the version-gate table.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so both reviewers see the same thing. Record the Swift toolchain version and minimum deployment target (from `Package.swift`, the Xcode project, or availability annotations) — several rules version-gate on them. Include the repo root in the target description — `api-unknown-default-external-enums`, `api-private-set-internal-mutation`, and `api-caseless-enum-namespaces` require searching beyond the diff for the enum's declaring module, other mutation sites, and instantiations.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `state-*.md`, `conc-*.md`, `identity-*.md`, `update-*.md`, `task-*.md`, `list-*.md`, `access-*.md`, `api-*.md`, `flow-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, and the toolchain/deployment facts. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (not a Swift target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | State & Observation | `state-` | `@Observable` over `ObservableObject`, `@State` ownership of view-created models, no `State(initialValue:)` from init params, computed over stored-derived values |
| 2 | Concurrency & Error Propagation | `conc-` | Continuations resume on every path, `[weak self]` in self-retained closures, cancellation checks in long loops, `async let` for independent awaits, CPU work off the main actor, underlying errors preserved when wrapping |
| 3 | View Identity & Structure | `identity-` | No runtime `if/else` in modifier helpers, branch inside modifiers not around views, `AnyLayout` over container branches |
| 4 | View Update Cost | `update-` | No side effects in view `init`, cached derivations, subview structs over computed `some View` vars, minimal data per subview, no large structs on rows, `callAsFunction` wrappers for environment closures |
| 5 | Data Loading & Task Lifecycle | `task-` | `.task` over `.onAppear`+`Task`, `.task(id:)` over `.onChange`+`Task`, scalar compared values |
| 6 | Lists, Layout & Geometry | `list-` | Constant per-element view count in `ForEach`, no `AnyView` rows, `onGeometryChange` over measurement `GeometryReader`, no geometry feedback loops, `visualEffect` for render-level transforms |
| 7 | Platform & Accessibility | `access-` | Buttons built with title and icon, `Button` over `onTapGesture`, semantic fonts and colors, accessibility representations for custom controls |
| 8 | API & Type Design | `api-` | `@unknown default`, `@available(*, unavailable)` stubs, `CaseIterable`, `private(set)`, memberwise init via extension, `rethrows`, caseless-enum namespaces, `canImport` |
| 9 | Control Flow & Collections | `flow-` | Branch-assigned `let` over placeholder `var`, dictionary default subscripts, `reduce(into:)`, `count(where:)`, `String(validating:)` for untrusted bytes |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching reviewers — it pre-records book-fidelity guards (patterns the source books endorse that community lore condemns, such as `id: \.self` on constant collections) so reviewers do not import outside rules.

## Related Skills

- `ios-taste` (curated) — judgment-call iOS design guidance this gate deliberately excludes; use it when the goal is taste, not a verdict.
- `search-ios26-docs` / `search-macos26-docs` — verify current-SDK API availability when a version-gate question decides a rule.
- `adversarial-ts-patterns` / `adversarial-zod` / `adversarial-tanstack` — sibling gates for TypeScript stacks; same protocol, different rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
