---
name: swift-ui-best-practices
description: SwiftUI best practices for building Apple-quality iOS app UIs. This skill should be used when writing, reviewing, or refactoring SwiftUI code to achieve native app polish matching Apple's Weather, Calendar, Photos, and Notes apps. Triggers on tasks involving SwiftUI views, iOS app development, HIG compliance, animations, accessibility, or performance optimization.
---

# Apple Design Patterns SwiftUI Best Practices

Comprehensive guide for building Apple-quality iOS app UIs with SwiftUI, designed for AI agents to achieve principal-level one-shot native app development. Contains 51 rules across 9 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Building new SwiftUI views and screens
- Implementing navigation flows and modal presentations
- Adding animations, haptics, and transitions
- Ensuring accessibility compliance (VoiceOver, Dynamic Type)
- Optimizing performance for smooth 120fps scrolling

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Data Flow & State Management | CRITICAL | `state-` |
| 2 | Visual Design System | CRITICAL | `design-` |
| 3 | Component Selection | HIGH | `comp-` |
| 4 | Navigation Patterns | HIGH | `nav-` |
| 5 | View Composition | HIGH | `view-` |
| 6 | Animation & Haptics | MEDIUM-HIGH | `anim-` |
| 7 | Accessibility | MEDIUM-HIGH | `acc-` |
| 8 | Lists & Scroll Performance | MEDIUM | `perf-` |
| 9 | Platform Integration | MEDIUM | `platform-` |

## Quick Reference

### 1. Data Flow & State Management (CRITICAL)

- [`state-observable-macro`](references/state-observable-macro.md) - Use @Observable for model classes
- [`state-use-state-for-view-local`](references/state-use-state-for-view-local.md) - Use @State for view-local value types
- [`state-binding-for-child-mutation`](references/state-binding-for-child-mutation.md) - Use @Binding for child view mutations
- [`state-environment-for-shared-data`](references/state-environment-for-shared-data.md) - Use @Environment for shared app data
- [`state-avoid-state-in-body`](references/state-avoid-state-in-body.md) - Avoid creating state inside view body
- [`state-minimize-state-scope`](references/state-minimize-state-scope.md) - Minimize state scope to reduce re-renders

### 2. Visual Design System (CRITICAL)

- [`design-typography-system-fonts`](references/design-typography-system-fonts.md) - Use system typography styles
- [`design-spacing-hig-values`](references/design-spacing-hig-values.md) - Use HIG-compliant spacing values
- [`design-colors-semantic-system`](references/design-colors-semantic-system.md) - Use semantic system colors
- [`design-safe-areas`](references/design-safe-areas.md) - Respect safe areas for content layout
- [`design-visual-hierarchy`](references/design-visual-hierarchy.md) - Establish clear visual hierarchy
- [`design-padding-consistency`](references/design-padding-consistency.md) - Apply consistent padding patterns
- [`design-dark-mode-support`](references/design-dark-mode-support.md) - Support Dark Mode from day one
- [`design-material-backgrounds`](references/design-material-backgrounds.md) - Use material backgrounds for depth

### 3. Component Selection (HIGH)

- [`comp-list-vs-lazyvstack`](references/comp-list-vs-lazyvstack.md) - Choose List vs LazyVStack by feature needs
- [`comp-sheet-vs-fullscreen`](references/comp-sheet-vs-fullscreen.md) - Choose sheet vs fullScreenCover by content type
- [`comp-picker-variants`](references/comp-picker-variants.md) - Choose the right picker style
- [`comp-grid-vs-lazygrid`](references/comp-grid-vs-lazygrid.md) - Choose Grid vs LazyVGrid by data size
- [`comp-textfield-vs-texteditor`](references/comp-textfield-vs-texteditor.md) - Choose TextField vs TextEditor by content length
- [`comp-button-vs-toggle`](references/comp-button-vs-toggle.md) - Choose Button vs Toggle by interaction type

### 4. Navigation Patterns (HIGH)

- [`nav-navigationstack-modern`](references/nav-navigationstack-modern.md) - Use NavigationStack for modern navigation
- [`nav-tabview-organization`](references/nav-tabview-organization.md) - Organize app sections with TabView
- [`nav-sheet-item-binding`](references/nav-sheet-item-binding.md) - Use item binding for sheet presentation
- [`nav-dismiss-environment`](references/nav-dismiss-environment.md) - Use environment dismiss for modal closure
- [`nav-toolbar-placement`](references/nav-toolbar-placement.md) - Place toolbar items correctly

### 5. View Composition (HIGH)

- [`view-extract-subviews`](references/view-extract-subviews.md) - Extract subviews for composition
- [`view-avoid-anyview`](references/view-avoid-anyview.md) - Avoid AnyView for type erasure
- [`view-equatable-conformance`](references/view-equatable-conformance.md) - Conform views to Equatable for diffing
- [`view-prefer-value-types`](references/view-prefer-value-types.md) - Prefer value types for view data
- [`view-viewbuilder-composition`](references/view-viewbuilder-composition.md) - Use @ViewBuilder for flexible composition
- [`view-modifier-order`](references/view-modifier-order.md) - Apply modifiers in correct order

### 6. Animation & Haptics (MEDIUM-HIGH)

- [`anim-spring-default`](references/anim-spring-default.md) - Use spring animations as default
- [`anim-haptic-feedback`](references/anim-haptic-feedback.md) - Add haptic feedback for interactions
- [`anim-matchedgeometry`](references/anim-matchedgeometry.md) - Use matchedGeometryEffect for shared transitions
- [`anim-transition-modifiers`](references/anim-transition-modifiers.md) - Use semantic transitions for appearing views
- [`anim-gesture-driven`](references/anim-gesture-driven.md) - Make animations gesture-driven
- [`anim-loading-states`](references/anim-loading-states.md) - Animate loading and empty states

### 7. Accessibility (MEDIUM-HIGH)

- [`acc-accessibility-labels`](references/acc-accessibility-labels.md) - Add accessibility labels to interactive elements
- [`acc-dynamic-type-support`](references/acc-dynamic-type-support.md) - Support Dynamic Type for all text
- [`acc-touch-targets`](references/acc-touch-targets.md) - Ensure minimum touch target size
- [`acc-color-contrast`](references/acc-color-contrast.md) - Maintain sufficient color contrast
- [`acc-reduce-motion`](references/acc-reduce-motion.md) - Respect reduce motion preference

### 8. Lists & Scroll Performance (MEDIUM)

- [`perf-lazy-loading`](references/perf-lazy-loading.md) - Use lazy containers for large collections
- [`perf-async-image`](references/perf-async-image.md) - Use AsyncImage for remote images
- [`perf-task-modifier`](references/perf-task-modifier.md) - Use task modifier for async work
- [`perf-drawinggroup`](references/perf-drawinggroup.md) - Use drawingGroup for complex graphics
- [`perf-instruments-profiling`](references/perf-instruments-profiling.md) - Profile SwiftUI with Instruments

### 9. Platform Integration (MEDIUM)

- [`platform-sf-symbols`](references/platform-sf-symbols.md) - Use SF Symbols for consistent iconography
- [`platform-system-features`](references/platform-system-features.md) - Integrate system features natively
- [`platform-app-storage`](references/platform-app-storage.md) - Use AppStorage for user preferences
- [`platform-scene-phase`](references/platform-scene-phase.md) - Respond to app lifecycle with ScenePhase
- [`platform-widget-integration`](references/platform-widget-integration.md) - Design for widget and Live Activity integration

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
