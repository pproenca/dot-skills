# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. State & Observation (state)

**Description:** SwiftUI state modeled against the framework's ownership and observation machinery — legacy `ObservableObject`/`@Published` stacks where the `@Observable` macro tracks per-property, view-created models held in plain properties that reset on every struct re-initialization, `State(initialValue:)` fed from init parameters that silently ignores later parent updates, and derived values stored and synced by hand. The costliest category because these bugs present as stale or vanishing UI state with no crash to point at the cause.

## 2. Concurrency & Error Propagation (conc)

**Description:** Swift concurrency and error-handling structure a reviewer can verify path-by-path — continuations with a reachable branch that never resumes (a permanently hung task), strong `self` captured in closures the instance itself retains (a leak that disables `deinit`), cancellable loops that never check for cancellation, independent awaits run serially, CPU-bound work left on the main actor, and `catch` blocks that discard the underlying error while rethrowing. Severe because the failures are hangs, leaks, and lost diagnostics rather than visible defects.

## 3. View Identity & Structure (identity)

**Description:** Conditional code that silently changes a view's structural identity — `if/else` branches on runtime state inside modifier helpers (the `applyIf` anti-pattern), branches that rebuild the same view just to vary a modifier, and layout-container switches (`HStack`/`VStack`) around identical children. Each toggle destroys the subtree's state: in-flight downloads, scroll positions, and navigation reset with no error anywhere.

## 4. View Update Cost (update)

**Description:** Work attached to the wrong point in SwiftUI's update cycle — side effects in view `init` (which runs on every parent invalidation), O(n) derivations recomputed in `body` by unrelated state changes, view chunks expressed as computed properties instead of standalone structs (so they can never be skipped), leaf views depending on whole models they read one field of, large shared structs compared per list row, and bare closures in `EnvironmentValues` that defeat change comparison.

## 5. Data Loading & Task Lifecycle (task)

**Description:** Async work tied to view lifetime through the wrong entry point — `Task {}` inside `.onAppear` (uncancellable, stacks on reappearance) instead of `.task`, manual `Task` spawning inside `.onChange` instead of `.task(id:)` (races and leaks instead of automatic cancel-and-restart), and whole collections used as the compared `id:`/`of:` value.

## 6. Lists, Layout & Geometry (list)

**Description:** Patterns that defeat lazy evaluation or destabilize layout — per-element `if` filters and `AnyView` wrappers inside `ForEach` (both force upfront evaluation of every row), `GeometryReader` used only to measure (a layout participant that alters what it measures), measured geometry fed back into the measured view's own frame (an infinite layout loop), and per-frame scroll state piped through `@State` for what `.visualEffect` computes at the render level.

## 7. Platform & Accessibility (access)

**Description:** Controls that opt out of the system's semantics — icon-only `Button` label closures with no accessibility label, `.onTapGesture` standing in for `Button` (no traits, no highlight state), fixed-size fonts and hardcoded color literals that ignore Dynamic Type, Dark Mode, and contrast settings, and gesture-driven custom controls that never populate the accessibility tree.

## 8. API & Type Design (api)

**Description:** Swift type and API surface decisions with compiler-checkable right answers — `default:` instead of `@unknown default:` over external enums, `fatalError` stubs not marked `@available(*, unavailable)`, hand-maintained case lists instead of `CaseIterable`, internally-mutated `var`s without `private(set)`, custom initializers declared in the struct body (losing the memberwise init) instead of an extension, `throws` where only a closure parameter throws (`rethrows`), instantiable structs posing as namespaces, and `#if os(...)` chains tracking framework availability that `canImport` tracks automatically.

## 9. Control Flow & Collections (flow)

**Description:** Local patterns with a strictly better standard-library form — placeholder-initialized `var`s where a branch-assigned `let` gets compiler exhaustiveness checking, hand-rolled dictionary upserts instead of `subscript(_:default:)`, collection accumulation via copying `reduce(_:_:)` instead of `reduce(into:)`, `.filter{}.count` allocating a throwaway array, and `String(decoding:)` silently repairing untrusted bytes that `String(validating:)` would reject.
