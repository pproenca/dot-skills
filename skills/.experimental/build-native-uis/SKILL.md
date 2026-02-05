---
name: apple-build-native-uis
description: SwiftUI interface development guidelines from Apple's official tutorials. This skill should be used when building, reviewing, or refactoring SwiftUI views, layouts, state management, navigation, and accessibility. Triggers on tasks involving SwiftUI components, view composition, layout containers, or iOS/macOS interface development.
---

# Apple Build Native UIs Best Practices

Comprehensive SwiftUI interface development guide, extracted from Apple's official [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/) and [SwiftUI Concepts](https://developer.apple.com/tutorials/swiftui-concepts/). Contains 49 rules across 10 categories, prioritized by impact to guide view composition, layout, styling, state management, and accessibility.

## When to Apply

Reference these guidelines when:
- Building new SwiftUI views and screens
- Composing views with stacks, grids, and custom layouts
- Managing state with @State, @Binding, @Observable, and @Environment
- Implementing navigation with NavigationStack, TabView, and sheets
- Adding accessibility, Dynamic Type, and inclusive features

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | View Composition | CRITICAL | `comp-` |
| 2 | Layout & Sizing | CRITICAL | `layout-` |
| 3 | Styling & Theming | HIGH | `style-` |
| 4 | State & Data Flow | HIGH | `state-` |
| 5 | Navigation & Presentation | HIGH | `nav-` |
| 6 | Lists & Dynamic Content | MEDIUM-HIGH | `list-` |
| 7 | User Input & Interaction | MEDIUM-HIGH | `input-` |
| 8 | Accessibility & Adaptivity | MEDIUM | `access-` |
| 9 | Testing & Debugging | MEDIUM | `test-` |
| 10 | App Polish & Refinement | LOW | `polish-` |

## Quick Reference

### 1. View Composition (CRITICAL)

- [`comp-body-some-view`](references/comp-body-some-view.md) - Return some View from body property
- [`comp-custom-view-properties`](references/comp-custom-view-properties.md) - Use properties to make views configurable
- [`comp-extract-subviews`](references/comp-extract-subviews.md) - Extract subviews to reduce body complexity
- [`comp-modifier-order`](references/comp-modifier-order.md) - Apply modifiers in correct order
- [`comp-prefer-composition`](references/comp-prefer-composition.md) - Prefer composition over inheritance for views
- [`comp-preview-macro`](references/comp-preview-macro.md) - Use #Preview for live development feedback
- [`comp-view-builder`](references/comp-view-builder.md) - Use @ViewBuilder for conditional view content

### 2. Layout & Sizing (CRITICAL)

- [`layout-frame-sizing`](references/layout-frame-sizing.md) - Use frame() for explicit size constraints
- [`layout-grid-for-tables`](references/layout-grid-for-tables.md) - Use Grid for aligned tabular layouts
- [`layout-lazy-grids`](references/layout-lazy-grids.md) - Use LazyVGrid for scrollable grid layouts
- [`layout-spacer-for-distribution`](references/layout-spacer-for-distribution.md) - Use Spacer to push views apart
- [`layout-stack-alignment-spacing`](references/layout-stack-alignment-spacing.md) - Configure stack alignment and spacing
- [`layout-stacks-over-position`](references/layout-stacks-over-position.md) - Use stacks instead of manual positioning
- [`layout-zstack-layering`](references/layout-zstack-layering.md) - Use ZStack for layered view composition

### 3. Styling & Theming (HIGH)

- [`style-font-hierarchy`](references/style-font-hierarchy.md) - Use semantic font styles for typography
- [`style-foreground-over-color`](references/style-foreground-over-color.md) - Use foregroundStyle over deprecated foregroundColor
- [`style-gradients`](references/style-gradients.md) - Apply gradients for visual depth
- [`style-sf-symbols`](references/style-sf-symbols.md) - Use SF Symbols for platform-consistent icons
- [`style-system-colors`](references/style-system-colors.md) - Use system colors for automatic dark mode

### 4. State & Data Flow (HIGH)

- [`state-bindable-for-observable`](references/state-bindable-for-observable.md) - Use @Bindable to create bindings from observable objects
- [`state-binding-for-children`](references/state-binding-for-children.md) - Use @Binding for two-way data flow to child views
- [`state-environment-for-shared`](references/state-environment-for-shared.md) - Use @Environment for system and shared values
- [`state-observable-for-models`](references/state-observable-for-models.md) - Use @Observable for shared model classes
- [`state-private-state`](references/state-private-state.md) - Mark @State properties as private
- [`state-state-for-local`](references/state-state-for-local.md) - Use @State for view-local value types

### 5. Navigation & Presentation (HIGH)

- [`nav-navigation-stack`](references/nav-navigation-stack.md) - Use NavigationStack for hierarchical navigation
- [`nav-programmatic-path`](references/nav-programmatic-path.md) - Manage navigation state with path binding
- [`nav-sheets-for-modal`](references/nav-sheets-for-modal.md) - Use sheets for modal presentation
- [`nav-tabview-sections`](references/nav-tabview-sections.md) - Use TabView for top-level app sections
- [`nav-toolbar-actions`](references/nav-toolbar-actions.md) - Place actions in toolbar for consistent placement

### 6. Lists & Dynamic Content (MEDIUM-HIGH)

- [`list-foreach-dynamic`](references/list-foreach-dynamic.md) - Use ForEach for dynamic content in containers
- [`list-identifiable-data`](references/list-identifiable-data.md) - Use List with Identifiable data
- [`list-searchable`](references/list-searchable.md) - Use searchable for built-in search
- [`list-swipe-actions`](references/list-swipe-actions.md) - Add swipe actions for contextual operations

### 7. User Input & Interaction (MEDIUM-HIGH)

- [`input-button-actions`](references/input-button-actions.md) - Use Button with action closures
- [`input-picker-selection`](references/input-picker-selection.md) - Use Picker for single-value selection
- [`input-textfield-binding`](references/input-textfield-binding.md) - Use TextField with binding for text input
- [`input-toggle-forms`](references/input-toggle-forms.md) - Use Toggle and Form for settings interfaces

### 8. Accessibility & Adaptivity (MEDIUM)

- [`access-accessibility-labels`](references/access-accessibility-labels.md) - Add accessibility labels to interactive elements
- [`access-dynamic-type`](references/access-dynamic-type.md) - Support Dynamic Type for all text
- [`access-scaled-metric`](references/access-scaled-metric.md) - Use @ScaledMetric for size-adaptive values
- [`access-view-that-fits`](references/access-view-that-fits.md) - Use ViewThatFits for adaptive layouts

### 9. Testing & Debugging (MEDIUM)

- [`test-breakpoints`](references/test-breakpoints.md) - Use breakpoints to debug runtime issues
- [`test-preview-sample-data`](references/test-preview-sample-data.md) - Use Preview with sample data for visual testing
- [`test-swift-testing`](references/test-swift-testing.md) - Write tests with Swift Testing framework

### 10. App Polish & Refinement (LOW)

- [`polish-inclusive-features`](references/polish-inclusive-features.md) - Add inclusive features for broader reach
- [`polish-transition-effects`](references/polish-transition-effects.md) - Apply transition effects for view insertion and removal
- [`polish-with-animation`](references/polish-with-animation.md) - Use withAnimation for state-driven transitions

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
