# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at creation (dry run, 2026-07-16)

Two blind reviewers per artifact, identical composed prompt, Swift 6.2 / iOS 18 target:

- **Planted-violation artifact** (single-file SwiftUI feature, violations across all 7 categories): both reviewers returned overall FAIL and unanimously failed the same 13 rules (`state-observable-not-observableobject`, `state-no-initialvalue-from-params`, `update-no-side-effects-in-view-init`, `identity-branch-free-modifier-helpers`, `identity-branch-in-modifier-not-around-view`, `task-modifier-not-onappear-task`, `task-scalar-ids-for-onchange`, `list-constant-foreach-view-count`, `list-no-anyview-rows`, `anim-body-scoped-animation-in-generic-containers`, `access-button-title-and-icon`, `access-scaledmetric-custom-spacing`, `access-semantic-fonts-and-colors`), each with file:line evidence and a concrete fix. Zero contested rules.
- **Clean equivalent artifact**: both reviewers returned overall PASS with per-rule evidence. Zero contested rules.
- Near-miss traps behaved as designed: a row view reading two model properties went N/A on `update-pass-minimal-data`; a synchronous `print` in `.onChange` did not fire `task-id-for-async-state-reactions`; a run-once-guarded synchronous `.onAppear` did not fire `task-modifier-not-onappear-task`; both reviewers ignored planted comments and judged from code.
- One planted violation did NOT fire, unanimously: a lookup inside a `@ViewBuilder` computed var on a row whose stored properties are all `let`s passed the second evidence leg of `update-subview-structs-not-computed-vars` ("the view has other change sources") — both reviewers reasoned identically that nothing can invalidate the row independently of its inputs, so the extraction is harmless there. This is the rule's conjunction working, not a miss: the harm the rule names requires an independent invalidation source. Keep the conjunction; it is what kept the verdict unanimous.
- The only per-rule splits were PASS-vs-N/A on rules whose subject was absent or trivially satisfied — expected reviewer-granularity noise that resolves to PASS under the merge table.

(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

Added: 2026-07-16

### Rule-fidelity guards the reviewer must not override (pre-recorded at creation)

The gate's rules deliberately diverge from common community lore in ways a reviewer trained on that lore may try to re-impose:

- `id: \.self` on constant collections is **endorsed** — there is no unstable-ForEach-id rule in this gate, and flagging it is out of scope.
- Synchronous, lightweight work in `.onAppear` is **endorsed**; only the `.onAppear { Task { ... } }` combination fails `task-modifier-not-onappear-task`.
- View models held in `@State` are the **endorsed** pattern (`@State private var viewModel = ...`), not an MVVM smell — `state-own-models-in-state` requires it.
- `withAnimation` on ordinary, non-generic hierarchies is fine; only value-based animation applied over arbitrary `@ViewBuilder` content in a generic container fails `anim-body-scoped-animation-in-generic-containers`.
- An `if/else` yielding exactly one view per branch inside `ForEach` does **not** fire `list-constant-foreach-view-count` — the per-element view count is still constant at 1. Only count-changing conditionals (an `if` without `else`) fail.
- `URLSession` awaits inside `@MainActor` observables are **not** violations of `task-concurrent-offload-cpu-work` — Foundation offloads the transfer; only CPU-bound work (decoding, parsing, transforms) needs `@concurrent`.

Added: 2026-07-16

### Code examples share a fixed domain (authoring policy)

Per the author's direction at creation, every rule's Incorrect/Correct fence draws on the same shared example domain (AnimalDetailView, BirdRegistryView, TrackCard, LockableContentCard, EditObservationButton, ...), with snippets minimally completed to typecheck (stubbed supporting types) and each rule's Incorrect/Correct pair kept as a minimal delta. When evolving a rule, keep this consistency — do not swap in invented domains.

Added: 2026-07-16

### Interlocking-rule precedence (pre-recorded at creation)

`update-subview-structs-not-computed-vars` and `update-cache-expensive-derivations` can both match a computed property that transforms data. Precedence: if the property returns `some View`, judge it under `update-subview-structs-not-computed-vars`; if it returns data read by `body`, judge it under `update-cache-expensive-derivations`. One finding, one rule — the reviewer reporting the same line under both is expected granularity noise, not a decidability bug.

`access-style-protocols-for-custom-controls` and `access-representation-for-custom-controls` split by whether a style protocol exists for the control's semantic role: Toggle/Button/Label roles → the style-protocol rule; roles with no style protocol (segmented control/Picker, sliders drawn with Canvas) → the representation rule.

Added: 2026-07-16

### Field failure: perf rules without a materiality floor drove a refactor treadmill (maddie-ios, July 2026)

Across ~7 fresh reviewer pairs in one session, `update-cache-expensive-derivations` and
`task-concurrent-offload-cpu-work` kept relocating the "main-actor work" boundary
(treatment search → startup store init → prepared-ledger helpers → booking selection →
detail refresh), each finding individually defensible, none material — reducing one
appointment's handful of payments is O(tiny). The cumulative fix list drove an
app-wide async-store rearchitecture from a payment-flow review, and the offload rule
was satisfied with 7 `@unchecked Sendable` conformances (maddie-ios a90d254) that a
later repair pass had to remove. Both rules now carry a materiality leg (unbounded
input cited via its loading site; small bounded collections are N/A) and the explicit
`@unchecked Sendable`-does-not-flip clause — do not weaken either on evolve.

Added: 2026-07-17

### Rule candidates from the July 2026 field audit (next evolve)

Two decidable checks the audit showed no gate currently owns:

- **Deleted regression test requires behavior evidence** — a diff that deletes or
  rewrites a UI/regression test must carry evidence the guarded interaction still
  works. Field case: the agent "dropped the legacy stationary-hold regression" test
  and the same rewrite broke exactly that path (resize handles never mounted).
- **Resilient XCUITest locators** — element lookups scoped to an element type
  (`app.otherElements["schedule.timeline"]`) silently match nothing when a refactor
  changes the element's class (`Other` → `ScrollView`); prefer type-agnostic queries
  (`app.descendants(matching: .any)` / `firstMatch` on the identifier). Field case: a
  brand-new 5-cycle tap test failed at its locator, not the behavior it claimed to test.

Added: 2026-07-17
