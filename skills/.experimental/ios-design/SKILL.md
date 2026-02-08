---
name: ios-design
description: SwiftUI implementation patterns for building Apple-quality iOS UIs. Covers design system (colors, typography, spacing), layout, view composition, state management, navigation, components, and animation polish. This skill should be used when writing, reviewing, or refactoring SwiftUI views, layouts, state management, navigation flows, or component selection.
---

# iOS Design — SwiftUI Implementation

Comprehensive guide for building Apple-quality iOS UIs with SwiftUI. Contains 61 rules across 7 categories covering design systems, layout, view composition, state management, navigation, components, and animation polish.

## When to Apply

Reference these guidelines when:
- Building new SwiftUI views and screens
- Implementing design systems with semantic colors, typography, and spacing
- Laying out content with stacks, grids, and adaptive layouts
- Composing views with @ViewBuilder and custom modifiers
- Managing state with @State, @Binding, @Observable, @Environment
- Implementing navigation with NavigationStack, TabView, sheets
- Choosing and configuring SwiftUI components
- Adding semantic transitions and loading state animations

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Design System | CRITICAL | `design-` |
| 2 | State & Data Flow | CRITICAL | `state-` |
| 3 | Layout & Sizing | HIGH | `layout-` |
| 4 | View Composition | HIGH | `view-` |
| 5 | Navigation | HIGH | `nav-` |
| 6 | Components & Controls | HIGH | `comp-` |
| 7 | Animation & Polish | MEDIUM | `anim-` |

## Quick Reference

### 1. Design System (CRITICAL)

- [`design-semantic-colors`](references/design-semantic-colors.md) - Use semantic system colors
- [`design-typography`](references/design-typography.md) - Use system typography styles
- [`design-spacing-hig`](references/design-spacing-hig.md) - Use HIG-compliant spacing values
- [`design-visual-hierarchy`](references/design-visual-hierarchy.md) - Establish clear visual hierarchy
- [`design-padding-consistency`](references/design-padding-consistency.md) - Apply consistent padding patterns
- [`design-dark-mode`](references/design-dark-mode.md) - Support Dark Mode from day one
- [`design-material-backgrounds`](references/design-material-backgrounds.md) - Use material backgrounds for depth
- [`design-sf-symbols`](references/design-sf-symbols.md) - Use SF Symbols for consistent iconography
- [`design-safe-areas`](references/design-safe-areas.md) - Respect safe areas for content layout
- [`design-gradients`](references/design-gradients.md) - Use gradients for visual depth
- [`design-foreground-style`](references/design-foreground-style.md) - Use foregroundStyle over foregroundColor

### 2. Layout & Sizing (HIGH)

- [`layout-8pt-grid`](references/layout-8pt-grid.md) - Use 8pt grid system for spacing
- [`layout-readable-width`](references/layout-readable-width.md) - Constrain text to readable width
- [`layout-adaptive`](references/layout-adaptive.md) - Use adaptive layouts for all screen sizes
- [`layout-standard-margins`](references/layout-standard-margins.md) - Use standard margins
- [`layout-scroll-indicators`](references/layout-scroll-indicators.md) - Configure scroll indicators appropriately
- [`layout-stacks`](references/layout-stacks.md) - Prefer stacks over absolute positioning
- [`layout-stack-config`](references/layout-stack-config.md) - Configure stack alignment and spacing
- [`layout-spacer`](references/layout-spacer.md) - Use Spacer for flexible distribution
- [`layout-frame-sizing`](references/layout-frame-sizing.md) - Use frame modifiers for sizing
- [`layout-zstack`](references/layout-zstack.md) - Use ZStack for layered content
- [`layout-grid`](references/layout-grid.md) - Use Grid for tabular layouts
- [`layout-lazy-grids`](references/layout-lazy-grids.md) - Use lazy grids for large collections
- [`layout-vhz-stacks`](references/layout-vhz-stacks.md) - Use VStack, HStack, ZStack for layout

### 3. View Composition (HIGH)

- [`view-body-some-view`](references/view-body-some-view.md) - Define views with body: some View
- [`view-custom-properties`](references/view-custom-properties.md) - Add custom properties to views
- [`view-modifier-order`](references/view-modifier-order.md) - Apply modifiers in correct order
- [`view-viewbuilder`](references/view-viewbuilder.md) - Use @ViewBuilder for flexible composition
- [`view-prefer-value-types`](references/view-prefer-value-types.md) - Prefer value types for view data
- [`view-prefer-composition`](references/view-prefer-composition.md) - Prefer composition over inheritance

### 4. State & Data Flow (CRITICAL)

- [`state-local`](references/state-local.md) - Use @State for view-local value types
- [`state-binding`](references/state-binding.md) - Use @Binding for child view mutations
- [`state-environment`](references/state-environment.md) - Use @Environment for shared app data
- [`state-observable`](references/state-observable.md) - Use @Observable for model classes
- [`state-avoid-in-body`](references/state-avoid-in-body.md) - Avoid creating state inside view body
- [`state-minimize-scope`](references/state-minimize-scope.md) - Minimize state scope to reduce re-renders
- [`state-private`](references/state-private.md) - Mark @State properties as private
- [`state-bindable`](references/state-bindable.md) - Use @Bindable for @Observable bindings

### 5. Navigation (HIGH)

- [`nav-navigationstack`](references/nav-navigationstack.md) - Use NavigationStack for modern navigation
- [`nav-tabview`](references/nav-tabview.md) - Organize app sections with TabView
- [`nav-sheet-item`](references/nav-sheet-item.md) - Use item binding for sheet presentation
- [`nav-dismiss`](references/nav-dismiss.md) - Use environment dismiss for modal closure
- [`nav-toolbar`](references/nav-toolbar.md) - Place toolbar items correctly
- [`nav-tab-bar`](references/nav-tab-bar.md) - Design tab bar navigation
- [`nav-bar`](references/nav-bar.md) - Configure navigation bar
- [`nav-hierarchy`](references/nav-hierarchy.md) - Structure hierarchical navigation
- [`nav-search`](references/nav-search.md) - Integrate search in navigation
- [`nav-programmatic-path`](references/nav-programmatic-path.md) - Use programmatic navigation paths

### 6. Components & Controls (HIGH)

- [`comp-list-vs-lazyvstack`](references/comp-list-vs-lazyvstack.md) - Choose List vs LazyVStack by feature needs
- [`comp-sheet-vs-fullscreen`](references/comp-sheet-vs-fullscreen.md) - Choose sheet vs fullScreenCover
- [`comp-picker`](references/comp-picker.md) - Choose the right picker style
- [`comp-grid-vs-lazygrid`](references/comp-grid-vs-lazygrid.md) - Choose Grid vs LazyVGrid by data size
- [`comp-textfield`](references/comp-textfield.md) - Configure text input components
- [`comp-button`](references/comp-button.md) - Style buttons appropriately
- [`comp-list-cells`](references/comp-list-cells.md) - Design list cells
- [`comp-alerts`](references/comp-alerts.md) - Use alerts and confirmation dialogs
- [`comp-action-sheets`](references/comp-action-sheets.md) - Present action sheets
- [`comp-segmented`](references/comp-segmented.md) - Use segmented controls
- [`comp-menus`](references/comp-menus.md) - Implement context menus

### 7. Animation & Polish (MEDIUM)

- [`anim-transitions`](references/anim-transitions.md) - Use semantic transitions for appearing views
- [`anim-loading-states`](references/anim-loading-states.md) - Animate loading and empty states

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
