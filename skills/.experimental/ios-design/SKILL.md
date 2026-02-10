---
name: ios-design
description: SwiftUI implementation patterns for building Apple-quality iOS UIs. Covers design system (colors, typography, spacing), state management, layout, view composition, navigation, components, accessibility, and animation polish. This skill should be used when writing, reviewing, or refactoring SwiftUI views, layouts, state management, navigation flows, or component selection.
---

# Apple SwiftUI iOS Design Best Practices

Comprehensive guide for building Apple-quality iOS UIs with SwiftUI. Contains 62 rules across 8 categories covering design systems, state management, layout, view composition, navigation, components, accessibility, and animation polish.

## When to Apply

Reference these guidelines when:
- Building new SwiftUI views and screens
- Implementing design systems with semantic colors, typography, and spacing
- Managing state with @State, @Binding, @Observable, @Environment
- Laying out content with stacks, grids, and adaptive layouts
- Composing views with @ViewBuilder and custom modifiers
- Implementing navigation with NavigationStack, TabView, sheets
- Choosing and configuring SwiftUI components
- Ensuring VoiceOver support, touch targets, and reduce motion
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
| 7 | Accessibility | HIGH | `access-` |
| 8 | Animation & Polish | MEDIUM | `anim-` |

## Quick Reference

### 1. Design System (CRITICAL)

- [`design-semantic-colors`](references/design-semantic-colors.md) - Use semantic and system colors
- [`design-typography`](references/design-typography.md) - Use system typography styles
- [`design-visual-hierarchy`](references/design-visual-hierarchy.md) - Establish clear visual hierarchy
- [`design-dark-mode`](references/design-dark-mode.md) - Support Dark Mode from day one
- [`design-material-backgrounds`](references/design-material-backgrounds.md) - Use material backgrounds for depth
- [`design-sf-symbols`](references/design-sf-symbols.md) - Use SF Symbols for consistent iconography
- [`design-safe-areas`](references/design-safe-areas.md) - Respect safe areas for content layout
- [`design-gradients`](references/design-gradients.md) - Apply gradients for visual depth
- [`design-foreground-style`](references/design-foreground-style.md) - Use foregroundStyle over foregroundColor

### 2. State & Data Flow (CRITICAL)

- [`state-local`](references/state-local.md) - Use @State for view-local value types
- [`state-binding`](references/state-binding.md) - Use @Binding for child view mutations
- [`state-environment`](references/state-environment.md) - Use @Environment for shared app data
- [`state-observable`](references/state-observable.md) - Use @Observable for model classes
- [`state-avoid-in-body`](references/state-avoid-in-body.md) - Avoid creating state inside view body
- [`state-minimize-scope`](references/state-minimize-scope.md) - Minimize state scope to reduce re-renders
- [`state-bindable`](references/state-bindable.md) - Use @Bindable for @Observable bindings

### 3. Layout & Sizing (HIGH)

- [`layout-8pt-grid`](references/layout-8pt-grid.md) - Use 8pt grid for spacing
- [`layout-readable-width`](references/layout-readable-width.md) - Constrain text to readable width on iPad
- [`layout-adaptive`](references/layout-adaptive.md) - Use adaptive layouts for different size classes
- [`layout-standard-margins`](references/layout-standard-margins.md) - Use system standard margins
- [`layout-scroll-indicators`](references/layout-scroll-indicators.md) - Show scroll indicators for long content
- [`layout-stacks`](references/layout-stacks.md) - Use stacks instead of manual positioning
- [`layout-stack-config`](references/layout-stack-config.md) - Configure stack alignment and spacing
- [`layout-spacer`](references/layout-spacer.md) - Use Spacer for flexible distribution
- [`layout-frame-sizing`](references/layout-frame-sizing.md) - Use frame() for explicit size constraints
- [`layout-zstack`](references/layout-zstack.md) - Use ZStack for layered view composition
- [`layout-grid`](references/layout-grid.md) - Use Grid for aligned tabular layouts
- [`layout-lazy-grids`](references/layout-lazy-grids.md) - Use LazyVGrid for scrollable grid layouts

### 4. View Composition (HIGH)

- [`view-body-some-view`](references/view-body-some-view.md) - Return some View from body property
- [`view-custom-properties`](references/view-custom-properties.md) - Use properties to make views configurable
- [`view-modifier-order`](references/view-modifier-order.md) - Apply modifiers in correct order
- [`view-viewbuilder`](references/view-viewbuilder.md) - Use @ViewBuilder for flexible composition
- [`view-prefer-value-types`](references/view-prefer-value-types.md) - Prefer value types for view data
- [`view-prefer-composition`](references/view-prefer-composition.md) - Prefer composition over inheritance

### 5. Navigation (HIGH)

- [`nav-navigationstack`](references/nav-navigationstack.md) - Use NavigationStack for modern navigation
- [`nav-tabview`](references/nav-tabview.md) - Organize app sections with TabView
- [`nav-sheet-item`](references/nav-sheet-item.md) - Use item binding for sheet presentation
- [`nav-dismiss`](references/nav-dismiss.md) - Use environment dismiss for modal closure
- [`nav-toolbar`](references/nav-toolbar.md) - Place toolbar items correctly
- [`nav-tab-bar`](references/nav-tab-bar.md) - Use tab bar for top-level navigation
- [`nav-bar`](references/nav-bar.md) - Configure navigation bar
- [`nav-hierarchy`](references/nav-hierarchy.md) - Design clear navigation hierarchy
- [`nav-search`](references/nav-search.md) - Integrate search using searchable modifier

### 6. Components & Controls (HIGH)

- [`comp-list-vs-lazyvstack`](references/comp-list-vs-lazyvstack.md) - Choose List vs LazyVStack by feature needs
- [`comp-sheet-vs-fullscreen`](references/comp-sheet-vs-fullscreen.md) - Choose sheet vs fullScreenCover
- [`comp-picker`](references/comp-picker.md) - Choose the right picker style
- [`comp-grid-vs-lazygrid`](references/comp-grid-vs-lazygrid.md) - Choose Grid vs LazyVGrid by data size
- [`comp-textfield`](references/comp-textfield.md) - Configure text input components
- [`comp-button`](references/comp-button.md) - Use appropriate button styles
- [`comp-list-cells`](references/comp-list-cells.md) - Design list cells with standard layouts
- [`comp-alerts`](references/comp-alerts.md) - Use alerts sparingly for critical information
- [`comp-action-sheets`](references/comp-action-sheets.md) - Use action sheets for contextual choices
- [`comp-segmented`](references/comp-segmented.md) - Use segmented controls for exclusive options
- [`comp-menus`](references/comp-menus.md) - Use menus for secondary actions
- [`comp-content-unavailable`](references/comp-content-unavailable.md) - Use ContentUnavailableView for empty states

### 7. Accessibility (HIGH)

- [`access-voiceover-labels`](references/access-voiceover-labels.md) - Add VoiceOver labels to interactive elements
- [`access-touch-targets`](references/access-touch-targets.md) - Ensure minimum 44pt touch targets
- [`access-reduce-motion`](references/access-reduce-motion.md) - Respect reduce motion preference

### 8. Animation & Polish (MEDIUM)

- [`anim-transitions`](references/anim-transitions.md) - Use semantic transitions for appearing views
- [`anim-loading-states`](references/anim-loading-states.md) - Animate loading and empty states
- [`anim-with-animation`](references/anim-with-animation.md) - Use withAnimation for explicit state changes
- [`anim-matched-geometry`](references/anim-matched-geometry.md) - Use matchedGeometryEffect for smooth view transitions

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
