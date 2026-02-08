# SwiftUI Refactoring Patterns — Best Practices

> Version 0.1.0 | Apple Developer Patterns | February 2026

> **Note:** These rules target SwiftUI refactoring and modernization of existing iOS/macOS codebases.

## Abstract

Comprehensive refactoring guide for SwiftUI applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (API modernization, state architecture) to incremental (performance optimization). Each rule includes detailed explanations, real-world before/after examples comparing legacy vs. modern implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

### 1. API Modernization (CRITICAL)
- [1.1 Migrate Alert to confirmationDialog API](references/api-alert-confirmation-dialog.md)
- [1.2 Migrate ObservableObject to @Observable Macro](references/api-observable-macro.md)
- [1.3 Migrate to New onChange Signature](references/api-onchange-signature.md)
- [1.4 Replace @EnvironmentObject with @Environment](references/api-environment-object-removal.md)
- [1.5 Replace id: \.self with Identifiable Conformance](references/api-list-foreach-identifiable.md)
- [1.6 Replace NavigationView with NavigationStack](references/api-navigationstack-migration.md)
- [1.7 Replace navigationBarItems with toolbar Modifier](references/api-toolbar-migration.md)

### 2. State Architecture (CRITICAL)
- [2.1 Extract @Binding to Isolate Child Re-renders](references/state-binding-extraction.md)
- [2.2 Minimize State Scope to Nearest Consumer](references/state-scope-minimization.md)
- [2.3 Move @StateObject to App Root for Shared State](references/state-stateobject-placement.md)
- [2.4 Remove @ObservedObject When Only Reading](references/state-remove-unnecessary-observation.md)
- [2.5 Replace onAppear Closures with .task Modifier](references/state-onappear-to-task.md)
- [2.6 Use Computed Properties Over Redundant @State](references/state-derived-over-stored.md)

### 3. View Decomposition (HIGH)
- [3.1 Convert Computed View Properties to Struct Views](references/view-computed-to-struct.md)
- [3.2 Extract Repeated Modifiers into Custom ViewModifiers](references/view-modifier-extraction.md)
- [3.3 Extract Subviews to Create Diffing Checkpoints](references/view-extract-subviews.md)
- [3.4 Reduce View Body to Under 30 Lines](references/view-body-complexity.md)
- [3.5 Replace AnyView with @ViewBuilder](references/view-eliminate-anyview.md)
- [3.6 Replace Callback Closures with PreferenceKey](references/view-preference-keys.md)
- [3.7 Use Group or Conditional Modifiers Over Conditional Views](references/view-conditional-content.md)

### 4. Navigation Refactoring (HIGH)
- [4.1 Centralize navigationDestination at Stack Root](references/nav-centralize-destinations.md)
- [4.2 Replace Boolean Sheet Triggers with Item Binding](references/nav-sheet-item-pattern.md)
- [4.3 Replace Destination-Based NavigationLink with Value-Based](references/nav-value-based-links.md)
- [4.4 Use NavigationPath for Programmatic Navigation](references/nav-path-state-management.md)
- [4.5 Use NavigationSplitView for Multi-Column Layouts](references/nav-split-view-adoption.md)

### 5. Concurrency Migration (MEDIUM-HIGH)
- [5.1 Replace Combine Publishers with async/await](references/conc-combine-to-async.md)
- [5.2 Replace Lock-Based Shared State with Actors](references/conc-actor-for-shared-state.md)
- [5.3 Replace NotificationCenter Observers with AsyncSequence](references/conc-asyncsequence-streams.md)
- [5.4 Use @MainActor Instead of DispatchQueue.main](references/conc-mainactor-isolation.md)
- [5.5 Use .task(id:) for Reactive Data Loading](references/conc-task-id-pattern.md)

### 6. Architecture Patterns (MEDIUM)
- [6.1 Eliminate Unnecessary View Models](references/arch-viewmodel-elimination.md)
- [6.2 Extract Features into Independent Modules](references/arch-feature-module-extraction.md)
- [6.3 Extract Protocol Interfaces for External Dependencies](references/arch-protocol-dependencies.md)
- [6.4 Separate Model Logic from View Code](references/arch-model-view-separation.md)
- [6.5 Use Environment Keys for Service Injection](references/arch-environment-key-injection.md)

### 7. Type Safety & Protocols (LOW-MEDIUM)
- [7.1 Eliminate Force Unwraps with Safe Alternatives](references/type-force-unwrap-elimination.md)
- [7.2 Replace String IDs with Tagged Types](references/type-tagged-identifiers.md)
- [7.3 Use Phantom Types for Compile-Time State Machines](references/type-phantom-types.md)
- [7.4 Use Result Type Over Optional with Error Flag](references/type-result-over-optionals.md)

### 8. Performance Optimization (LOW)
- [8.1 Add Equatable Conformance to Prevent Spurious Redraws](references/perf-equatable-views.md)
- [8.2 Migrate VStack/HStack to Lazy Variants for Large Collections](references/perf-lazy-migration.md)
- [8.3 Use drawingGroup for Complex Vector Graphics](references/perf-drawing-group.md)

---

## References

1. https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
2. https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types
3. https://developer.apple.com/videos/play/wwdc2023/10160/
4. https://developer.apple.com/videos/play/wwdc2024/10150/
5. https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance
6. https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896
7. https://www.swiftbysundell.com/articles/avoiding-massive-swiftui-views/
8. https://www.swiftbysundell.com/articles/avoiding-anyview-in-swiftui/
9. https://www.avanderlee.com/optimization/refactoring-swift-best-practices/
10. https://www.jessesquires.com/blog/2024/09/09/swift-observable-macro/
11. https://www.donnywals.com/comparing-observable-to-observableobjects/
12. https://holyswift.app/three-ways-to-refactor-massive-swiftui-views/
