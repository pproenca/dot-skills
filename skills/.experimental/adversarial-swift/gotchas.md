# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at creation (dry run, 2026-07-11)

Two blind reviewers per artifact, identical composed prompt, Swift 6.3 / iOS 17 target:

- **Planted-violation artifact** (single-file SwiftUI feature, 14 planted violations across all 9 categories): both reviewers returned overall FAIL and unanimously failed all 14 planted rules (`state-observable-not-observableobject`, `conc-resume-continuation-every-path`, `conc-preserve-underlying-error`, `conc-weak-self-in-retained-closures`, `identity-branch-free-modifier-helpers`, `update-no-side-effects-in-view-init`, `task-modifier-not-onappear-task`, `list-no-anyview-rows`, `list-ongeometrychange-over-georeader`, `access-button-title-and-icon`, `access-semantic-fonts-and-colors`, `api-unknown-default-external-enums`, `flow-count-where-over-filter-count`, `flow-reduce-into-for-collections`), each with file:line evidence and a concrete fix. Zero contested rules.
- **Clean equivalent artifact**: both reviewers returned overall PASS with per-rule evidence. Zero contested rules.
- Near-miss traps behaved as designed: a row view reading two model properties went N/A on `update-pass-minimal-data` (the rule fails only the single-read case); an `if/else` yielding one view per branch inside `ForEach` did not fire `list-constant-foreach-view-count`; both reviewers ignored the artifact's `// Planted:` comments and judged from the code.
- The only per-rule splits were PASS-vs-N/A on rules whose subject was absent or trivially satisfied (`conc-offload-cpu-work-off-mainactor`, `state-own-models-in-state`, `state-computed-over-stored-derived`, `list-constant-foreach-view-count`, `access-button-not-ontapgesture`) — all resolve to PASS under the merge table and are expected reviewer-granularity noise, not decidability bugs.

Added: 2026-07-11

### Book-fidelity guards the reviewers must not override (pre-recorded at creation)

The gate's rules are grounded in *Swift Gems* and *The SwiftUI Way* (both Natalia Panferova, Nil Coalescing), and the books deliberately diverge from common community lore in ways reviewers trained on that lore may try to re-impose:

- `id: \.self` on constant collections is **endorsed** by the source book (its own recommended examples use it on `[String]`) — there is no unstable-ForEach-id rule in this gate, and flagging it is out of scope.
- Synchronous, lightweight work in `.onAppear` is **endorsed**; only the `.onAppear { Task { ... } }` combination fails `task-modifier-not-onappear-task`.
- The book prescribes `@concurrent` (Swift 6.2) as the primary offloading tool for `conc-offload-cpu-work-off-mainactor`; `nonisolated`, a non-main actor, and `Task.detached` are accepted equivalents, not preferred ones.
- `withAnimation` on ordinary hierarchies is fine; the book only warns about generic containers and heavy trees, which this gate deliberately excluded as too rare.

Added: 2026-07-11

### try? await Task.sleep does not propagate cancellation

`conc-check-cancellation-in-loops` explicitly names `try? await Task.sleep(...)` as NOT counting as cancellation propagation — `try?` swallows the `CancellationError`, so a loop whose only suspension point is a `try?`-wrapped sleep runs to completion after `cancel()`. Reviewers repeatedly want to credit the sleep as a cancellation check; the rule text forbids it.

Added: 2026-07-11
