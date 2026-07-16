# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Data Modeling & Observation (state)

**Description:** How view data dependencies are modeled against SwiftUI's observation machinery — legacy `ObservableObject`/`@Published` stacks where the `@Observable` macro tracks per-property, view-created observable models held in plain properties that reset on every struct re-initialization, `State(initialValue:)` fed from init parameters that silently ignores later parent updates, `.task(id:)` model re-creation without an identity guard, bare closures stored in `EnvironmentValues` that defeat change comparison, and high-frequency values pushed through the environment struct. The costliest category because these bugs present as stale, vanishing, or thrashing UI state with no crash pointing at the cause.

## 2. View Update Cost (update)

**Description:** Work attached to the wrong point in SwiftUI's update cycle — UI extracted into computed `some View` properties instead of standalone structs (so its logic can never be skipped), leaf views depending on whole models they read one field of, side effects in view `init` (which runs on every parent invalidation), O(n) collection derivations recomputed in `body` by unrelated high-frequency state, and large collection-bearing structs compared per list row. Each violation multiplies silently: the cost lands on every keystroke, every toggle, every row.

## 3. Structural View Identity (identity)

**Description:** Conditional code that silently changes a view's structural identity — `if/else` branches on runtime state inside modifier helpers and `View` extensions (the `applyIf` anti-pattern), branches that rebuild the same view just to vary a modifier, and layout-container switches (`HStack`/`VStack`) around identical children. Each toggle destroys the subtree's state: in-flight downloads, scroll positions, animations, and navigation reset with no error anywhere.

## 4. Data Loading & Task Lifecycle (task)

**Description:** Async work tied to view lifetime through the wrong entry point — `Task {}` inside `.onAppear` (uncancellable, stacks on reappearance) instead of `.task`, manual `Task` spawning inside `.onChange` instead of `.task(id:)` (races and leaks instead of automatic cancel-and-restart), whole collections used as the compared `id:`/`of:` value, and CPU-bound work left on the main actor inside `@MainActor`-isolated observable models because a `Task {}` wrapper was mistaken for offloading.

## 5. Lists & Geometry (list)

**Description:** Patterns that defeat lazy evaluation or destabilize layout — per-element `if` filters and `AnyView` wrappers inside `ForEach` (both force upfront evaluation of every row), `GeometryReader` used only to measure (a layout participant that alters what it measures), measured geometry fed back into the measured view's own frame (an infinite layout loop), and per-frame scroll state piped through `@State` for what `visualEffect` computes at the render level.

## 6. Animation Scope (anim)

**Description:** Animations that leak beyond the attribute they were meant to move — value-based `.animation(_:value:)` applied over arbitrary `@ViewBuilder` content in a generic container (every animatable attribute in the child subtree inherits the animation) instead of the attribute-scoped `animation(_:body:)` form, and custom `Animatable` conformances that re-run `body` every frame to interpolate attributes the built-in animatable modifiers already handle off the main thread.

## 7. Platform Conventions & Accessibility (access)

**Description:** Controls that opt out of the system's semantics — icon-only `Button` label closures with no accessibility label, `.onTapGesture` standing in for `Button` (no traits, no highlight state), custom controls rebuilt from primitives when a style protocol (`ToggleStyle`, `ButtonStyle`, `LabelStyle`) could restyle the semantic built-in, gesture-driven bespoke controls that never populate the accessibility tree, fixed-size fonts and hardcoded color literals that ignore Dynamic Type and Dark Mode, and fixed spacing around text that stays cramped when type scales up.
