---
name: swift-refactor
description: Swift and SwiftUI refactoring patterns for code quality, API modernization, state architecture, view decomposition, navigation refactoring, architecture patterns, type safety, and Swift language fundamentals. This skill should be used when refactoring Swift/SwiftUI code, migrating deprecated APIs, restructuring state management, decomposing views, modernizing navigation, improving architecture, or learning Swift language basics.
---

# Swift Refactor — Code Quality & Modernization

Comprehensive guide for refactoring Swift and SwiftUI code. Contains 42 rules across 7 categories covering API modernization, state architecture, view decomposition, navigation refactoring, architecture patterns, type safety, and Swift fundamentals.

## When to Apply

Reference these guidelines when:
- Migrating from deprecated SwiftUI APIs (ObservableObject, NavigationView, old onChange)
- Restructuring state management to reduce re-renders
- Decomposing large views into maintainable components
- Refactoring navigation to use NavigationStack and NavigationPath
- Improving architecture with protocol dependencies and Environment keys
- Strengthening type safety with tagged identifiers and Result types
- Writing idiomatic Swift with proper naming, optionals, and closures

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | API Modernization | CRITICAL | `api-` |
| 2 | State Architecture | CRITICAL | `state-` |
| 3 | View Decomposition | HIGH | `view-` |
| 4 | Navigation Refactoring | HIGH | `nav-` |
| 5 | Architecture Patterns | HIGH | `arch-` |
| 6 | Type Safety & Protocols | MEDIUM-HIGH | `type-` |
| 7 | Swift Language Fundamentals | MEDIUM | `swift-` |

## Quick Reference

### 1. API Modernization (CRITICAL)

- [`api-observable-macro`](references/api-observable-macro.md) - Migrate ObservableObject to @Observable macro
- [`api-navigationstack-migration`](references/api-navigationstack-migration.md) - Replace NavigationView with NavigationStack
- [`api-onchange-signature`](references/api-onchange-signature.md) - Migrate to new onChange signature
- [`api-environment-object-removal`](references/api-environment-object-removal.md) - Replace @EnvironmentObject with @Environment
- [`api-alert-confirmation-dialog`](references/api-alert-confirmation-dialog.md) - Migrate Alert to confirmationDialog API
- [`api-list-foreach-identifiable`](references/api-list-foreach-identifiable.md) - Replace id: \.self with Identifiable conformance
- [`api-toolbar-migration`](references/api-toolbar-migration.md) - Replace navigationBarItems with toolbar modifier

### 2. State Architecture (CRITICAL)

- [`state-scope-minimization`](references/state-scope-minimization.md) - Minimize state scope to nearest consumer
- [`state-derived-over-stored`](references/state-derived-over-stored.md) - Use computed properties over redundant @State
- [`state-binding-extraction`](references/state-binding-extraction.md) - Extract @Binding to isolate child re-renders
- [`state-remove-observation`](references/state-remove-observation.md) - Remove unnecessary @ObservedObject
- [`state-onappear-to-task`](references/state-onappear-to-task.md) - Replace onAppear closures with .task modifier
- [`state-stateobject-placement`](references/state-stateobject-placement.md) - Move @StateObject to app root for shared state

### 3. View Decomposition (HIGH)

- [`view-extract-subviews`](references/view-extract-subviews.md) - Extract subviews for composition
- [`view-eliminate-anyview`](references/view-eliminate-anyview.md) - Replace AnyView with @ViewBuilder or generics
- [`view-computed-to-struct`](references/view-computed-to-struct.md) - Convert computed view properties to struct views
- [`view-modifier-extraction`](references/view-modifier-extraction.md) - Extract repeated modifiers into custom ViewModifiers
- [`view-conditional-content`](references/view-conditional-content.md) - Use Group or conditional modifiers over conditional views
- [`view-preference-keys`](references/view-preference-keys.md) - Replace callback closures with PreferenceKey
- [`view-body-complexity`](references/view-body-complexity.md) - Reduce view body to under 30 lines

### 4. Navigation Refactoring (HIGH)

- [`nav-centralize-destinations`](references/nav-centralize-destinations.md) - Centralize navigationDestination at stack root
- [`nav-value-based-links`](references/nav-value-based-links.md) - Replace destination-based NavigationLink with value-based
- [`nav-path-state-management`](references/nav-path-state-management.md) - Use NavigationPath for programmatic navigation
- [`nav-split-view-adoption`](references/nav-split-view-adoption.md) - Use NavigationSplitView for multi-column layouts
- [`nav-sheet-item-pattern`](references/nav-sheet-item-pattern.md) - Replace boolean sheet triggers with item binding

### 5. Architecture Patterns (HIGH)

- [`arch-viewmodel-elimination`](references/arch-viewmodel-elimination.md) - Eliminate unnecessary view models
- [`arch-protocol-dependencies`](references/arch-protocol-dependencies.md) - Extract protocol interfaces for external dependencies
- [`arch-environment-key-injection`](references/arch-environment-key-injection.md) - Use Environment keys for service injection
- [`arch-feature-module-extraction`](references/arch-feature-module-extraction.md) - Extract features into independent modules
- [`arch-model-view-separation`](references/arch-model-view-separation.md) - Separate model logic from view code

### 6. Type Safety & Protocols (MEDIUM-HIGH)

- [`type-tagged-identifiers`](references/type-tagged-identifiers.md) - Replace String IDs with tagged types
- [`type-result-over-optionals`](references/type-result-over-optionals.md) - Use Result type over optional with error flag
- [`type-phantom-types`](references/type-phantom-types.md) - Use phantom types for compile-time state machines
- [`type-force-unwrap-elimination`](references/type-force-unwrap-elimination.md) - Eliminate force unwraps with safe alternatives

### 7. Swift Language Fundamentals (MEDIUM)

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
