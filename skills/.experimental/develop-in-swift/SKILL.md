---
name: develop-in-swift
description: Comprehensive guide to Swift and SwiftUI development based on Apple's official Develop in Swift Tutorials. This skill should be used when learning Swift, building SwiftUI apps, working with SwiftData, or developing for iOS/visionOS. Triggers on tasks involving Swift code, SwiftUI views, data persistence, or Apple platform development.
---

# Develop in Swift Best Practices

Comprehensive guide for Swift and SwiftUI app development, extracted from Apple's official [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/). Contains 41 rules across 13 categories, covering Swift fundamentals through app distribution.

## When to Apply

Reference these guidelines when:
- Learning Swift programming language
- Building SwiftUI views and interfaces
- Managing state and data flow
- Working with SwiftData persistence
- Implementing navigation patterns
- Adding accessibility and localization
- Debugging and testing your app
- Preparing for App Store distribution

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Swift Language Fundamentals | CRITICAL | `swift-` |
| 2 | SwiftUI View Basics | CRITICAL | `view-` |
| 3 | State & Data Flow | CRITICAL | `state-` |
| 4 | SwiftData & Persistence | HIGH | `data-` |
| 5 | Navigation & Presentation | HIGH | `nav-` |
| 6 | Lists & Dynamic Content | HIGH | `list-` |
| 7 | User Input & Forms | MEDIUM-HIGH | `input-` |
| 8 | Testing & Quality | MEDIUM-HIGH | `test-` |
| 9 | Accessibility & Localization | MEDIUM-HIGH | `access-` |
| 10 | Debugging & Refinement | MEDIUM | `debug-` |
| 11 | Machine Learning Integration | MEDIUM | `ml-` |
| 12 | visionOS & Spatial Computing | MEDIUM | `spatial-` |
| 13 | App Distribution | LOW | `dist-` |

## Quick Reference

### 1. Swift Language Fundamentals (CRITICAL)

- [`swift-let-vs-var`](references/swift-let-vs-var.md) - Use let for constants, var for variables
- [`swift-structs-vs-classes`](references/swift-structs-vs-classes.md) - Prefer structs over classes
- [`swift-camel-case-naming`](references/swift-camel-case-naming.md) - Use camelCase naming convention
- [`swift-string-interpolation`](references/swift-string-interpolation.md) - Use string interpolation for dynamic text
- [`swift-functions-clear-names`](references/swift-functions-clear-names.md) - Name functions and parameters for clarity
- [`swift-for-in-loops`](references/swift-for-in-loops.md) - Use for-in loops for collections
- [`swift-optionals`](references/swift-optionals.md) - Handle optionals safely with unwrapping
- [`swift-closures`](references/swift-closures.md) - Use closures for inline functions

### 2. SwiftUI View Basics (CRITICAL)

- [`view-body-some-view`](references/view-body-some-view.md) - Return some View from body property
- [`view-vstack-hstack-zstack`](references/view-vstack-hstack-zstack.md) - Use VStack, HStack, ZStack for layout
- [`view-modifier-order-matters`](references/view-modifier-order-matters.md) - Apply modifiers in correct order
- [`view-custom-properties`](references/view-custom-properties.md) - Use properties to customize views
- [`view-preview-macro`](references/view-preview-macro.md) - Use #Preview for live development
- [`view-sf-symbols`](references/view-sf-symbols.md) - Use SF Symbols for system icons
- [`view-colors-system`](references/view-colors-system.md) - Use system colors for dark mode support
- [`view-gradients`](references/view-gradients.md) - Apply gradients for visual interest

### 3. State & Data Flow (CRITICAL)

- [`state-state-for-local`](references/state-state-for-local.md) - Use @State for view-local value types
- [`state-binding-for-two-way`](references/state-binding-for-two-way.md) - Use @Binding for two-way data flow
- [`state-observable-for-models`](references/state-observable-for-models.md) - Use @Observable for shared model classes
- [`state-environment-for-system`](references/state-environment-for-system.md) - Use @Environment for system and shared values

### 4. SwiftData & Persistence (HIGH)

- [`data-model-macro`](references/data-model-macro.md) - Use @Model for SwiftData persistence
- [`data-query-for-fetching`](references/data-query-for-fetching.md) - Use @Query to fetch SwiftData models
- [`data-model-container`](references/data-model-container.md) - Configure modelContainer in app entry point
- [`data-relationships`](references/data-relationships.md) - Define model relationships with properties
- [`data-crud-operations`](references/data-crud-operations.md) - Perform CRUD with modelContext

### 5. Navigation & Presentation (HIGH)

- [`nav-navigationstack`](references/nav-navigationstack.md) - Use NavigationStack for hierarchical navigation
- [`nav-tabview`](references/nav-tabview.md) - Use TabView for top-level sections
- [`nav-sheets`](references/nav-sheets.md) - Use sheets for modal presentation

### 6. Lists & Dynamic Content (HIGH)

- [`list-foreach-identifiable`](references/list-foreach-identifiable.md) - Use List and ForEach with Identifiable data
- [`list-swipe-actions`](references/list-swipe-actions.md) - Add swipe actions to list rows

### 7. User Input & Forms (MEDIUM-HIGH)

- [`input-textfield`](references/input-textfield.md) - Use TextField with binding for text input
- [`input-buttons-actions`](references/input-buttons-actions.md) - Use Button with action closures
- [`input-picker-toggle`](references/input-picker-toggle.md) - Use Picker and Toggle for selection input

### 8. Testing & Quality (MEDIUM-HIGH)

- [`test-swift-testing`](references/test-swift-testing.md) - Write unit tests with Swift Testing

### 9. Accessibility & Localization (MEDIUM-HIGH)

- [`access-accessibility-labels`](references/access-accessibility-labels.md) - Add accessibility labels to interactive elements
- [`access-dynamic-type`](references/access-dynamic-type.md) - Support Dynamic Type for all text

### 10. Debugging & Refinement (MEDIUM)

- [`debug-breakpoints`](references/debug-breakpoints.md) - Use breakpoints to debug code
- [`debug-console-output`](references/debug-console-output.md) - Use debug console for runtime inspection

### 11. Machine Learning Integration (MEDIUM)

- [`ml-natural-language`](references/ml-natural-language.md) - Use Natural Language framework for text analysis

### 12. visionOS & Spatial Computing (MEDIUM)

- [`spatial-visionos-windows`](references/spatial-visionos-windows.md) - Build visionOS apps with windows

### 13. App Distribution (LOW)

- [`dist-testflight`](references/dist-testflight.md) - Test with TestFlight before release

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
