---
name: swift-ui-architect
description: Opinionated SwiftUI architecture enforcement for iOS 26 / Swift 6.2 clinic modular MVVM-C apps using local SPM package boundaries. Enforces App-target `DependencyContainer` + route shells, @Observable ViewModels/coordinators, Domain repository/coordinator/error-routing protocols, Data-owned I/O, stale-while-revalidate reads, and optimistic queued sync. Use when writing, reviewing, or refactoring SwiftUI architecture, navigation, dependency wiring, or repository boundaries.
---

# SwiftUI Modular MVVM-C Architecture

Opinionated architecture enforcement for SwiftUI clinic-style apps. This skill aligns to the iOS 26 / Swift 6.2 clinic architecture: modular MVVM-C in local SPM packages, concrete coordinators and route shells in the App target, pure Domain protocols, and Data as the only I/O layer.

## Mandated Architecture Stack

```
┌───────────────────────────────────────────────────────────────┐
│ App target: DependencyContainer, Coordinators, Route Shells   │
├───────────────┬───────────────┬───────────────┬──────────────┤
│ Feature* SPM  │ Feature* SPM  │ Feature* SPM  │ Feature* SPM │
│ View + VM     │ View + VM     │ View + VM     │ View + VM    │
├───────────────────────────────────────────────────────────────┤
│ Data SPM: repository impls, remote/local, retry, sync queue   │
├───────────────────────────────────────────────────────────────┤
│ Domain SPM: models, repository protocols, coordinator protocols│
│ and ErrorRouting/AppError                                      │
├───────────────────────────────────────────────────────────────┤
│ Shared SPMs: DesignSystem, SharedKit                           │
└───────────────────────────────────────────────────────────────┘
```

**Dependency Rule**: Feature modules import `Domain` + `DesignSystem` only. Features never import `Data` or other features. App target is the only convergence point.


## Clinic Architecture Contract (iOS 26 / Swift 6.2)

All guidance in this skill assumes the clinic modular MVVM-C architecture:

- Feature modules import `Domain` + `DesignSystem` only (never `Data`, never sibling features)
- App target is the convergence point and owns `DependencyContainer`, concrete coordinators, and Route Shell wiring
- `Domain` stays pure Swift and defines models plus repository, `*Coordinating`, `ErrorRouting`, and `AppError` contracts
- `Data` owns SwiftData/network/sync/retry/background I/O and implements Domain protocols
- Read/write flow defaults to stale-while-revalidate reads and optimistic queued writes
- ViewModels call repository protocols directly (no default use-case/interactor layer)

## When to Apply

Reference these guidelines when:
- Building or refactoring feature modules under local SPM packages
- Wiring coordinators, route shells, and dependency container factories
- Defining Domain protocols for repositories, coordinators, and error routing
- Enforcing Data-only ownership of networking, persistence, and sync
- Reviewing stale-while-revalidate reads and optimistic queued writes

## Non-Negotiable Constraints (iOS 26 / Swift 6.2)

- `@Observable` for ViewModels/coordinators, `ObservableObject` / `@Published` never
- No dedicated use-case/interactor layer: ViewModels call Domain repository protocols directly
- Coordinator protocols live in Domain; concrete coordinators own `NavigationPath` in App target
- Route shells live in App target and own `.navigationDestination` mapping
- `AppError` + `ErrorRouting` drive presentation policy; ViewModels do not hardcode global error UI
- SwiftData / URLSession / retry / sync queue logic stays in Data package only

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | View Identity & Diffing | CRITICAL | `diff-` | 6 |
| 2 | State Architecture | CRITICAL | `state-` | 7 |
| 3 | View Composition | HIGH | `view-` | 6 |
| 4 | Navigation & Coordination | HIGH | `nav-` | 5 |
| 5 | Layer Architecture | HIGH | `layer-` | 6 |
| 6 | Dependency Injection | MEDIUM-HIGH | `di-` | 4 |
| 7 | List & Collection Performance | MEDIUM | `list-` | 4 |
| 8 | Async & Data Flow | MEDIUM | `data-` | 5 |

## Quick Reference

### 1. View Identity & Diffing (CRITICAL)

- [`diff-equatable-views`](references/diff-equatable-views.md) - Apply @Equatable macro to every SwiftUI view
- [`diff-closure-skip`](references/diff-closure-skip.md) - Use @SkipEquatable for closure/handler properties
- [`diff-reference-types`](references/diff-reference-types.md) - Never store reference types without Equatable conformance
- [`diff-identity-stability`](references/diff-identity-stability.md) - Use stable O(1) identifiers in ForEach
- [`diff-avoid-anyview`](references/diff-avoid-anyview.md) - Never use AnyView — use @ViewBuilder or generics
- [`diff-printchanges-debug`](references/diff-printchanges-debug.md) - Use _printChanges() to diagnose unnecessary re-renders

### 2. State Architecture (CRITICAL)

- [`state-observable-class`](references/state-observable-class.md) - Use @Observable classes for all ViewModels
- [`state-ownership`](references/state-ownership.md) - @State for owned data, plain property for injected data
- [`state-single-source`](references/state-single-source.md) - One source of truth per piece of state
- [`state-scoped-observation`](references/state-scoped-observation.md) - Leverage @Observable property-level tracking
- [`state-binding-minimal`](references/state-binding-minimal.md) - Pass @Binding only for two-way data flow
- [`state-environment-global`](references/state-environment-global.md) - Use @Environment for app-wide shared dependencies
- [`state-no-published`](references/state-no-published.md) - Never use @Published or ObservableObject

### 3. View Composition (HIGH)

- [`view-body-complexity`](references/view-body-complexity.md) - Maximum 10 nodes in view body
- [`view-extract-subviews`](references/view-extract-subviews.md) - Extract computed properties/helpers into separate View structs
- [`view-no-logic-in-body`](references/view-no-logic-in-body.md) - Zero business logic in body
- [`view-minimal-dependencies`](references/view-minimal-dependencies.md) - Pass only needed properties, not entire models
- [`view-viewbuilder-composition`](references/view-viewbuilder-composition.md) - Use @ViewBuilder for conditional composition
- [`view-no-init-sideeffects`](references/view-no-init-sideeffects.md) - Never perform work in View init

### 4. Navigation & Coordination (HIGH)

- [`nav-coordinator-pattern`](references/nav-coordinator-pattern.md) - Every feature has a coordinator owning NavigationStack
- [`nav-routes-enum`](references/nav-routes-enum.md) - Define all routes as a Hashable enum
- [`nav-deeplink-support`](references/nav-deeplink-support.md) - Coordinators must support URL-based deep linking
- [`nav-modal-sheets`](references/nav-modal-sheets.md) - Present modals via coordinator, not inline
- [`nav-no-navigationlink`](references/nav-no-navigationlink.md) - Never use NavigationLink(destination:) — use navigationDestination(for:)

### 5. Layer Architecture (HIGH)

- [`layer-dependency-rule`](references/layer-dependency-rule.md) - Domain layer has zero framework imports
- [`layer-usecase-protocol`](references/layer-usecase-protocol.md) - Do not add a use-case layer; keep orchestration in ViewModel + repository protocols
- [`layer-repository-protocol`](references/layer-repository-protocol.md) - Repository protocols in Domain, implementations in Data
- [`layer-model-value-types`](references/layer-model-value-types.md) - Domain models are structs, never classes
- [`layer-no-view-repository`](references/layer-no-view-repository.md) - Views never access repositories directly; ViewModel calls repository protocols
- [`layer-viewmodel-boundary`](references/layer-viewmodel-boundary.md) - ViewModels expose display-ready state only

### 6. Dependency Injection (MEDIUM-HIGH)

- [`di-environment-injection`](references/di-environment-injection.md) - Inject container-managed protocol dependencies via @Environment
- [`di-protocol-abstraction`](references/di-protocol-abstraction.md) - All injected dependencies are protocol types
- [`di-container-composition`](references/di-container-composition.md) - Compose `DependencyContainer` in App target and expose VM factories
- [`di-mock-testing`](references/di-mock-testing.md) - Every protocol dependency has a mock for testing

### 7. List & Collection Performance (MEDIUM)

- [`list-constant-viewcount`](references/list-constant-viewcount.md) - ForEach must produce constant view count per element
- [`list-filter-in-model`](references/list-filter-in-model.md) - Filter/sort in ViewModel, never inside ForEach
- [`list-lazy-stacks`](references/list-lazy-stacks.md) - Use LazyVStack/LazyHStack for unbounded content
- [`list-id-keypath`](references/list-id-keypath.md) - Provide explicit id keyPath — never rely on implicit identity

### 8. Async & Data Flow (MEDIUM)

- [`data-task-modifier`](references/data-task-modifier.md) - Use `.task(id:)` as the primary feature data-loading trigger
- [`data-async-init`](references/data-async-init.md) - Never perform async work in init
- [`data-error-loadable`](references/data-error-loadable.md) - Model loading states as enum, not booleans
- [`data-combine-avoid`](references/data-combine-avoid.md) - Prefer async/await over Combine for new code
- [`data-cancellation`](references/data-cancellation.md) - Use .task automatic cancellation — never manage Tasks manually

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
