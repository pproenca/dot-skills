---
name: apple-developer-patterns-swift-ui-refactor-patterns
description: SwiftUI refactoring patterns for modernizing and improving existing SwiftUI codebases. This skill should be used when refactoring SwiftUI code, migrating deprecated APIs, restructuring state management, decomposing views, modernizing navigation, or replacing Combine with structured concurrency. Triggers on tasks involving SwiftUI refactoring, migration, modernization, deprecated API replacement, or code improvement.
---

# Apple Developer Patterns SwiftUI Refactoring Best Practices

Comprehensive refactoring guide for SwiftUI applications, maintained by Apple Developer Patterns. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Migrating deprecated SwiftUI APIs to modern equivalents
- Restructuring state management to reduce re-renders
- Decomposing massive view bodies into focused subviews
- Modernizing navigation from NavigationView to NavigationStack
- Replacing Combine with structured concurrency (async/await)

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | API Modernization | CRITICAL | `api-` |
| 2 | State Architecture | CRITICAL | `state-` |
| 3 | View Decomposition | HIGH | `view-` |
| 4 | Navigation Refactoring | HIGH | `nav-` |
| 5 | Concurrency Migration | MEDIUM-HIGH | `conc-` |
| 6 | Architecture Patterns | MEDIUM | `arch-` |
| 7 | Type Safety & Protocols | LOW-MEDIUM | `type-` |
| 8 | Performance Optimization | LOW | `perf-` |

## Quick Reference

### 1. API Modernization (CRITICAL)

- [`api-observable-macro`](references/api-observable-macro.md) - Migrate ObservableObject to @Observable Macro
- [`api-navigationstack-migration`](references/api-navigationstack-migration.md) - Replace NavigationView with NavigationStack
- [`api-onchange-signature`](references/api-onchange-signature.md) - Migrate to New onChange Signature
- [`api-environment-object-removal`](references/api-environment-object-removal.md) - Replace @EnvironmentObject with @Environment
- [`api-alert-confirmation-dialog`](references/api-alert-confirmation-dialog.md) - Migrate Alert to confirmationDialog API
- [`api-list-foreach-identifiable`](references/api-list-foreach-identifiable.md) - Replace id: \.self with Identifiable Conformance
- [`api-toolbar-migration`](references/api-toolbar-migration.md) - Replace navigationBarItems with toolbar Modifier

### 2. State Architecture (CRITICAL)

- [`state-scope-minimization`](references/state-scope-minimization.md) - Minimize State Scope to Nearest Consumer
- [`state-derived-over-stored`](references/state-derived-over-stored.md) - Use Computed Properties Over Redundant @State
- [`state-binding-extraction`](references/state-binding-extraction.md) - Extract @Binding to Isolate Child Re-renders
- [`state-remove-unnecessary-observation`](references/state-remove-unnecessary-observation.md) - Remove @ObservedObject When Only Reading
- [`state-onappear-to-task`](references/state-onappear-to-task.md) - Replace onAppear Closures with .task Modifier
- [`state-stateobject-placement`](references/state-stateobject-placement.md) - Move @StateObject to App Root for Shared State

### 3. View Decomposition (HIGH)

- [`view-extract-subviews`](references/view-extract-subviews.md) - Extract Subviews to Create Diffing Checkpoints
- [`view-eliminate-anyview`](references/view-eliminate-anyview.md) - Replace AnyView with @ViewBuilder
- [`view-computed-to-struct`](references/view-computed-to-struct.md) - Convert Computed View Properties to Struct Views
- [`view-modifier-extraction`](references/view-modifier-extraction.md) - Extract Repeated Modifiers into Custom ViewModifiers
- [`view-conditional-content`](references/view-conditional-content.md) - Use Group or Conditional Modifiers Over Conditional Views
- [`view-preference-keys`](references/view-preference-keys.md) - Replace Callback Closures with PreferenceKey
- [`view-body-complexity`](references/view-body-complexity.md) - Reduce View Body to Under 30 Lines

### 4. Navigation Refactoring (HIGH)

- [`nav-centralize-destinations`](references/nav-centralize-destinations.md) - Centralize navigationDestination at Stack Root
- [`nav-value-based-links`](references/nav-value-based-links.md) - Replace Destination-Based NavigationLink with Value-Based
- [`nav-path-state-management`](references/nav-path-state-management.md) - Use NavigationPath for Programmatic Navigation
- [`nav-split-view-adoption`](references/nav-split-view-adoption.md) - Use NavigationSplitView for Multi-Column Layouts
- [`nav-sheet-item-pattern`](references/nav-sheet-item-pattern.md) - Replace Boolean Sheet Triggers with Item Binding

### 5. Concurrency Migration (MEDIUM-HIGH)

- [`conc-combine-to-async`](references/conc-combine-to-async.md) - Replace Combine Publishers with async/await
- [`conc-mainactor-isolation`](references/conc-mainactor-isolation.md) - Use @MainActor Instead of DispatchQueue.main
- [`conc-task-id-pattern`](references/conc-task-id-pattern.md) - Use .task(id:) for Reactive Data Loading
- [`conc-actor-for-shared-state`](references/conc-actor-for-shared-state.md) - Replace Lock-Based Shared State with Actors
- [`conc-asyncsequence-streams`](references/conc-asyncsequence-streams.md) - Replace NotificationCenter Observers with AsyncSequence

### 6. Architecture Patterns (MEDIUM)

- [`arch-viewmodel-elimination`](references/arch-viewmodel-elimination.md) - Eliminate Unnecessary View Models
- [`arch-protocol-dependencies`](references/arch-protocol-dependencies.md) - Extract Protocol Interfaces for External Dependencies
- [`arch-environment-key-injection`](references/arch-environment-key-injection.md) - Use Environment Keys for Service Injection
- [`arch-feature-module-extraction`](references/arch-feature-module-extraction.md) - Extract Features into Independent Modules
- [`arch-model-view-separation`](references/arch-model-view-separation.md) - Separate Model Logic from View Code

### 7. Type Safety & Protocols (LOW-MEDIUM)

- [`type-tagged-identifiers`](references/type-tagged-identifiers.md) - Replace String IDs with Tagged Types
- [`type-result-over-optionals`](references/type-result-over-optionals.md) - Use Result Type Over Optional with Error Flag
- [`type-phantom-types`](references/type-phantom-types.md) - Use Phantom Types for Compile-Time State Machines
- [`type-force-unwrap-elimination`](references/type-force-unwrap-elimination.md) - Eliminate Force Unwraps with Safe Alternatives

### 8. Performance Optimization (LOW)

- [`perf-equatable-views`](references/perf-equatable-views.md) - Add Equatable Conformance to Prevent Spurious Redraws
- [`perf-lazy-migration`](references/perf-lazy-migration.md) - Migrate VStack/HStack to Lazy Variants for Large Collections
- [`perf-drawing-group`](references/perf-drawing-group.md) - Use drawingGroup for Complex Vector Graphics

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Full Compiled Document

For a complete compiled guide with all rules in a single document, see [AGENTS.md](AGENTS.md).

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
