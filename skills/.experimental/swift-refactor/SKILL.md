---
name: swift-refactor
description: Swift and SwiftUI refactoring patterns aligned with the iOS 26 / Swift 6.2 modular MVVM-C architecture (Airbnb + OLX SPM layout). Enforces @Observable ViewModels/coordinators, App-target dependency container + route shells, Domain repository/coordinator/error-routing protocols, and Data-owned I/O with sync/retry boundaries. Use when refactoring existing SwiftUI code into the new modular architecture.
---

# Swift/SwiftUI Refactor (Modular MVVM-C)

Comprehensive refactoring guide for migrating Swift/SwiftUI code to modular MVVM-C with local SPM package boundaries and App-target composition root wiring.

## Mandated Architecture Stack

```
┌───────────────────────────────────────────────────────────────┐
│ App target: DependencyContainer, Coordinators, Route Shells   │
├───────────────────────────────────────────────────────────────┤
│ Feature modules: View + ViewModel (Domain + DesignSystem deps)│
├───────────────────────────────────────────────────────────────┤
│ Data package: repositories, remote/local stores, sync, retry  │
├───────────────────────────────────────────────────────────────┤
│ Domain package: models, repository/coordinator/error protocols │
└───────────────────────────────────────────────────────────────┘
```

**Dependency Rule**: Feature modules never import `Data` and never import sibling features.

## When to Apply

Reference these guidelines when:
- Migrating from deprecated SwiftUI APIs (ObservableObject, NavigationView, old onChange)
- Restructuring state management to use @Observable ViewModels
- Adding @Equatable diffing to views for performance
- Decomposing large views into 10-node maximum bodies
- Refactoring navigation to coordinator + route shell pattern
- Refactoring to Domain/Data/Feature/App package boundaries
- Setting up dependency injection through `DependencyContainer`
- Improving list/collection scroll performance
- Replacing manual Task management with `.task(id:)` and cancellable loading

## Non-Negotiable Constraints (iOS 26 / Swift 6.2)

- `@Observable` ViewModels/coordinators, `ObservableObject` / `@Published` never
- `NavigationStack` is owned by App-target route shells and coordinators
- `@Equatable` macro on every view, `AnyView` never
- Domain defines repository/coordinator/error-routing protocols; no framework-coupled I/O
- No dedicated use-case/interactor layer; ViewModels call repository protocols directly
- Views never access repositories directly

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | View Identity & Diffing | CRITICAL | `diff-` | 4 |
| 2 | API Modernization | CRITICAL | `api-` | 7 |
| 3 | State Architecture | CRITICAL | `state-` | 6 |
| 4 | View Composition | HIGH | `view-` | 7 |
| 5 | Navigation & Coordination | HIGH | `nav-` | 5 |
| 6 | Layer Architecture | HIGH | `layer-` | 5 |
| 7 | Architecture Patterns | HIGH | `arch-` | 5 |
| 8 | Dependency Injection | MEDIUM-HIGH | `di-` | 2 |
| 9 | Type Safety & Protocols | MEDIUM-HIGH | `type-` | 4 |
| 10 | List & Collection Performance | MEDIUM | `list-` | 4 |
| 11 | Async & Data Flow | MEDIUM | `data-` | 3 |
| 12 | Swift Language Fundamentals | MEDIUM | `swift-` | 8 |

## Quick Reference

### 1. View Identity & Diffing (CRITICAL)

- [`diff-equatable-views`](references/diff-equatable-views.md) - Add @Equatable macro to every SwiftUI view
- [`diff-closure-skip`](references/diff-closure-skip.md) - Use @EquatableIgnored for closure properties
- [`diff-identity-stability`](references/diff-identity-stability.md) - Use stable O(1) identifiers in ForEach
- [`diff-printchanges-debug`](references/diff-printchanges-debug.md) - Use _printChanges() to diagnose re-renders

### 2. API Modernization (CRITICAL)

- [`api-observable-macro`](references/api-observable-macro.md) - Migrate ObservableObject to @Observable macro
- [`api-navigationstack-migration`](references/api-navigationstack-migration.md) - Replace NavigationView with NavigationStack
- [`api-onchange-signature`](references/api-onchange-signature.md) - Migrate to new onChange signature
- [`api-environment-object-removal`](references/api-environment-object-removal.md) - Replace @EnvironmentObject with @Environment
- [`api-alert-confirmation-dialog`](references/api-alert-confirmation-dialog.md) - Migrate Alert to confirmationDialog API
- [`api-list-foreach-identifiable`](references/api-list-foreach-identifiable.md) - Replace id: \.self with Identifiable conformance
- [`api-toolbar-migration`](references/api-toolbar-migration.md) - Replace navigationBarItems with toolbar modifier

### 3. State Architecture (CRITICAL)

- [`state-scope-minimization`](references/state-scope-minimization.md) - Minimize state scope to nearest consumer
- [`state-derived-over-stored`](references/state-derived-over-stored.md) - Use computed properties over redundant @State
- [`state-binding-extraction`](references/state-binding-extraction.md) - Extract @Binding to isolate child re-renders
- [`state-remove-observation`](references/state-remove-observation.md) - Migrate @ObservedObject to @Observable tracking
- [`state-onappear-to-task`](references/state-onappear-to-task.md) - Replace onAppear closures with .task modifier
- [`state-stateobject-placement`](references/state-stateobject-placement.md) - Migrate @StateObject to @State with @Observable

### 4. View Composition (HIGH)

- [`view-extract-subviews`](references/view-extract-subviews.md) - Extract subviews for diffing checkpoints
- [`view-eliminate-anyview`](references/view-eliminate-anyview.md) - Replace AnyView with @ViewBuilder or generics
- [`view-computed-to-struct`](references/view-computed-to-struct.md) - Convert computed view properties to struct views
- [`view-modifier-extraction`](references/view-modifier-extraction.md) - Extract repeated modifiers into custom ViewModifiers
- [`view-conditional-content`](references/view-conditional-content.md) - Use Group or conditional modifiers over conditional views
- [`view-preference-keys`](references/view-preference-keys.md) - Replace callback closures with PreferenceKey
- [`view-body-complexity`](references/view-body-complexity.md) - Reduce view body to maximum 10 nodes

### 5. Navigation & Coordination (HIGH)

- [`nav-centralize-destinations`](references/nav-centralize-destinations.md) - Refactor navigation to coordinator pattern
- [`nav-value-based-links`](references/nav-value-based-links.md) - Replace NavigationLink with coordinator routes
- [`nav-path-state-management`](references/nav-path-state-management.md) - Use NavigationPath for programmatic navigation
- [`nav-split-view-adoption`](references/nav-split-view-adoption.md) - Use NavigationSplitView for multi-column layouts
- [`nav-sheet-item-pattern`](references/nav-sheet-item-pattern.md) - Replace boolean sheet triggers with item binding

### 6. Layer Architecture (HIGH)

- [`layer-dependency-rule`](references/layer-dependency-rule.md) - Extract domain layer with zero framework imports
- [`layer-usecase-protocol`](references/layer-usecase-protocol.md) - Remove use-case/interactor layer; keep orchestration in ViewModel + repository protocols
- [`layer-repository-protocol`](references/layer-repository-protocol.md) - Repository protocols in Domain, implementations in Data
- [`layer-no-view-repository`](references/layer-no-view-repository.md) - Remove direct repository access from views
- [`layer-viewmodel-boundary`](references/layer-viewmodel-boundary.md) - Refactor ViewModels to expose display-ready state only

### 7. Architecture Patterns (HIGH)

- [`arch-viewmodel-elimination`](references/arch-viewmodel-elimination.md) - Restructure inline state into @Observable ViewModel
- [`arch-protocol-dependencies`](references/arch-protocol-dependencies.md) - Extract protocol dependencies through ViewModel layer
- [`arch-environment-key-injection`](references/arch-environment-key-injection.md) - Use Environment keys for service injection
- [`arch-feature-module-extraction`](references/arch-feature-module-extraction.md) - Extract features into independent modules
- [`arch-model-view-separation`](references/arch-model-view-separation.md) - Extract business logic into Domain models and repository-backed ViewModels

### 8. Dependency Injection (MEDIUM-HIGH)

- [`di-container-composition`](references/di-container-composition.md) - Compose dependency container at app root
- [`di-mock-testing`](references/di-mock-testing.md) - Add mock implementation for every protocol dependency

### 9. Type Safety & Protocols (MEDIUM-HIGH)

- [`type-tagged-identifiers`](references/type-tagged-identifiers.md) - Replace String IDs with tagged types
- [`type-result-over-optionals`](references/type-result-over-optionals.md) - Use Result type over optional with error flag
- [`type-phantom-types`](references/type-phantom-types.md) - Use phantom types for compile-time state machines
- [`type-force-unwrap-elimination`](references/type-force-unwrap-elimination.md) - Eliminate force unwraps with safe alternatives

### 10. List & Collection Performance (MEDIUM)

- [`list-constant-viewcount`](references/list-constant-viewcount.md) - Ensure ForEach produces constant view count per element
- [`list-filter-in-model`](references/list-filter-in-model.md) - Move filter/sort logic from ForEach into ViewModel
- [`list-lazy-stacks`](references/list-lazy-stacks.md) - Replace VStack/HStack with Lazy variants for unbounded content
- [`list-id-keypath`](references/list-id-keypath.md) - Provide explicit id keyPath — never rely on implicit identity

### 11. Async & Data Flow (MEDIUM)

- [`data-task-modifier`](references/data-task-modifier.md) - Replace onAppear async work with .task modifier
- [`data-error-loadable`](references/data-error-loadable.md) - Model loading states as enum instead of boolean flags
- [`data-cancellation`](references/data-cancellation.md) - Use .task automatic cancellation — never manage Tasks manually

### 12. Swift Language Fundamentals (MEDIUM)

- [`swift-let-vs-var`](references/swift-let-vs-var.md) - Use let for constants, var for variables
- [`swift-structs-vs-classes`](references/swift-structs-vs-classes.md) - Prefer structs over classes
- [`swift-camel-case-naming`](references/swift-camel-case-naming.md) - Use camelCase naming convention
- [`swift-string-interpolation`](references/swift-string-interpolation.md) - Use string interpolation for dynamic text
- [`swift-functions-clear-names`](references/swift-functions-clear-names.md) - Name functions and parameters for clarity
- [`swift-for-in-loops`](references/swift-for-in-loops.md) - Use for-in loops for collections
- [`swift-optionals`](references/swift-optionals.md) - Handle optionals safely with unwrapping
- [`swift-closures`](references/swift-closures.md) - Use closures for inline functions

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
