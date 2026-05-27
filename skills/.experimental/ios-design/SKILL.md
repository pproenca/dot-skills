---
name: ios-design
description: SwiftUI interface implementation patterns aligned with the iOS 26 / Swift 6.2 clinic modular MVVM-C architecture, grounded in Creative Selection and Design Like Apple principles. Use when building new SwiftUI views/screens while respecting Domain/Data boundaries, App-target route-shell navigation, and production-grade accessibility/interaction standards.
---

# Apple SwiftUI iOS Design Best Practices

A builder's guide for implementing Apple-quality iOS interfaces in SwiftUI, grounded in two foundational design texts:

- **Ken Kocienda** — *Creative Selection* (empathy for the user, craft in coding, taste in choosing the best solution, demo culture of iterative refinement)
- **John Edson** — *Design Like Apple* (systems thinking, the product is the marketing, design out loud, design with conviction)

Contains 62 rules across 8 principle-based categories. Each rule identifies a specific anti-pattern, grounds the fix in a named principle, and provides the correct iOS 26 / Swift 6.2 SwiftUI implementation.

## Scope & Relationship to Sibling Skills

This skill is the **building and implementation guide** — it teaches how to construct new SwiftUI interfaces from scratch using Apple-quality patterns. When loaded alongside `ios-ui-refactor` (reviewing/refactoring existing UI), this skill covers the greenfield implementation that `ios-ui-refactor` later audits. Use this skill for building new screens; use the sibling for evaluating and improving existing ones.


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
- Building new SwiftUI views and screens from scratch
- Choosing between semantic colors, system typography, and spacing grids (Edson's Systems Thinking)
- Managing state with @State, @Binding, @Observable, @Environment (Kocienda's Craft)
- Selecting the right component: List vs LazyVStack, Sheet vs FullScreenCover (Kocienda's Taste)
- Composing views with @ViewBuilder, custom modifiers, and value types (Kocienda's Creative Selection)
- Implementing navigation with NavigationStack, TabView, sheets (Edson's Conversation)
- Laying out content with stacks, grids, frames, and adaptive layouts (Edson's Design Out Loud)
- Ensuring VoiceOver, touch targets, Dark Mode, and reduce motion support (Kocienda's Empathy)
- Adding transitions, loading states, and animation polish (Edson's Product Is the Marketing)

## Rule Categories by Priority

| Priority | Category | Principle | Impact | Prefix | Rules |
|----------|----------|-----------|--------|--------|-------|
| 1 | Empathy in Every Pixel | Kocienda "Empathy" · Edson "Design Is About People" | CRITICAL | `empathy-` | 8 |
| 2 | The Visual System | Edson "Systems Thinking" · Kocienda "Convergence" | CRITICAL | `system-` | 8 |
| 3 | Craft: State as Foundation | Kocienda "Craft" | CRITICAL | `craft-` | 7 |
| 4 | Creative Composition | Kocienda "Creative Selection" | HIGH | `compose-` | 6 |
| 5 | Taste: The Right Choice | Kocienda "Taste" · Edson "Design with Conviction" | HIGH | `taste-` | 8 |
| 6 | Navigation as Conversation | Edson "Design Is a Conversation" · Kocienda "The Demo" | HIGH | `converse-` | 9 |
| 7 | Design Out Loud: Layout | Edson "Design Out Loud" · Kocienda "Intersection" | HIGH | `layout-` | 8 |
| 8 | The Product Speaks | Edson "Product Is the Marketing" · Kocienda "Demo Culture" | MEDIUM | `product-` | 8 |

## Quick Reference

### 1. Empathy in Every Pixel (CRITICAL)

Kocienda: "Empathy — trying to see the world from other people's perspectives." Edson: design begins with the person holding the device.

- [`empathy-semantic-colors`](references/empathy-semantic-colors.md) - Use semantic colors, never hard-coded values
- [`empathy-dark-mode`](references/empathy-dark-mode.md) - Support Dark Mode from day one
- [`empathy-foreground-style`](references/empathy-foreground-style.md) - Use foregroundStyle over foregroundColor
- [`empathy-safe-areas`](references/empathy-safe-areas.md) - Always respect safe areas for content
- [`empathy-voiceover-labels`](references/empathy-voiceover-labels.md) - Add VoiceOver labels to every interactive element
- [`empathy-touch-targets`](references/empathy-touch-targets.md) - Ensure 44x44 point minimum touch targets
- [`empathy-reduce-motion`](references/empathy-reduce-motion.md) - Always provide reduce motion fallback
- [`empathy-readable-width`](references/empathy-readable-width.md) - Constrain text to readable width on iPad

### 2. The Visual System (CRITICAL)

Edson: "Zoom out to see relationships between objects." Kocienda: convergence — many decisions narrowing toward one coherent whole.

- [`system-typography`](references/system-typography.md) - Use system typography styles, never fixed sizes
- [`system-visual-hierarchy`](references/system-visual-hierarchy.md) - Establish clear visual hierarchy through size, weight, and color
- [`system-spacing-grid`](references/system-spacing-grid.md) - Use a 4pt base unit for all spacing
- [`system-material-backgrounds`](references/system-material-backgrounds.md) - Use material backgrounds for depth and layering
- [`system-sf-symbols`](references/system-sf-symbols.md) - Use SF Symbols for consistent iconography
- [`system-gradients`](references/system-gradients.md) - Apply gradients for visual depth, not decoration
- [`system-standard-margins`](references/system-standard-margins.md) - Use system standard margins consistently
- [`system-stack-config`](references/system-stack-config.md) - Configure stack alignment and spacing explicitly

### 3. Craft: State as Foundation (CRITICAL)

Kocienda: "Craft — applying skill to achieve a high-quality result."

- [`craft-state-local`](references/craft-state-local.md) - Use @State for view-local value types
- [`craft-state-binding`](references/craft-state-binding.md) - Use @Binding for child view mutations
- [`craft-state-environment`](references/craft-state-environment.md) - Use @Environment for shared app-wide data
- [`craft-state-observable`](references/craft-state-observable.md) - Use @Observable for model classes
- [`craft-avoid-body-state`](references/craft-avoid-body-state.md) - Never create state inside the view body
- [`craft-minimize-scope`](references/craft-minimize-scope.md) - Minimize state scope to reduce re-renders
- [`craft-state-bindable`](references/craft-state-bindable.md) - Use @Bindable for @Observable bindings

### 4. Creative Composition (HIGH)

Kocienda: "Creative selection — great software is built through composition and recombination."

- [`compose-body-some-view`](references/compose-body-some-view.md) - Return some View from body, never concrete types
- [`compose-custom-properties`](references/compose-custom-properties.md) - Use properties to make views configurable
- [`compose-modifier-order`](references/compose-modifier-order.md) - Apply view modifiers in the correct order
- [`compose-viewbuilder`](references/compose-viewbuilder.md) - Use @ViewBuilder for flexible slot-based composition
- [`compose-prefer-value-types`](references/compose-prefer-value-types.md) - Prefer value types for view data
- [`compose-prefer-composition`](references/compose-prefer-composition.md) - Prefer composition over inheritance for view reuse

### 5. Taste: The Right Choice (HIGH)

Kocienda: "Taste — refined judgment, the ability to choose the one right solution." Edson: commit to one approach and perfect it.

- [`taste-list-vs-lazyvstack`](references/taste-list-vs-lazyvstack.md) - Choose List for system features, LazyVStack for custom layouts
- [`taste-sheet-vs-fullscreen`](references/taste-sheet-vs-fullscreen.md) - Choose sheet for tasks, fullScreenCover for immersion
- [`taste-picker`](references/taste-picker.md) - Choose the right picker style for the data type
- [`taste-grid-vs-lazygrid`](references/taste-grid-vs-lazygrid.md) - Choose Grid for aligned data, LazyVGrid for scrollable collections
- [`taste-button`](references/taste-button.md) - Use button styles that match the action's importance
- [`taste-textfield`](references/taste-textfield.md) - Configure text input with the right keyboard and content type
- [`taste-alerts`](references/taste-alerts.md) - Use alerts only for critical, blocking information
- [`taste-action-sheets`](references/taste-action-sheets.md) - Use confirmation dialogs for contextual multi-choice actions

### 6. Navigation as Conversation (HIGH)

Edson: "Design is a conversation between the product and the person." Kocienda: demos as conversations about whether the interface speaks clearly.

- [`converse-navigationstack`](references/converse-navigationstack.md) - Use NavigationStack for programmatic, type-safe navigation
- [`converse-tabview`](references/converse-tabview.md) - Organize app sections with TabView for parallel navigation
- [`converse-sheet-item`](references/converse-sheet-item.md) - Use item binding for data-driven sheet presentation
- [`converse-dismiss`](references/converse-dismiss.md) - Use environment dismiss for modal closure
- [`converse-toolbar`](references/converse-toolbar.md) - Place toolbar items in the correct semantic positions
- [`converse-tab-bar`](references/converse-tab-bar.md) - Use tab bar for top-level section navigation
- [`converse-nav-bar`](references/converse-nav-bar.md) - Configure navigation bar to communicate context
- [`converse-hierarchy`](references/converse-hierarchy.md) - Design clear navigation hierarchy before writing code
- [`converse-search`](references/converse-search.md) - Integrate search with the searchable modifier

### 7. Design Out Loud: Layout (HIGH)

Edson: "Design Out Loud — prototype relentlessly until layout feels inevitable." Kocienda: the intersection of technology and liberal arts.

- [`layout-stacks`](references/layout-stacks.md) - Use stacks instead of manual positioning
- [`layout-spacer`](references/layout-spacer.md) - Use Spacer for flexible space distribution
- [`layout-frame-sizing`](references/layout-frame-sizing.md) - Use frame() for explicit size constraints
- [`layout-zstack`](references/layout-zstack.md) - Use ZStack for purposeful layered composition
- [`layout-grid`](references/layout-grid.md) - Use Grid for aligned non-scrolling tabular content
- [`layout-lazy-grids`](references/layout-lazy-grids.md) - Use LazyVGrid for scrollable multi-column layouts
- [`layout-adaptive`](references/layout-adaptive.md) - Use adaptive layouts for different size classes
- [`layout-scroll-indicators`](references/layout-scroll-indicators.md) - Show scroll indicators for long scrollable content

### 8. The Product Speaks (MEDIUM)

Edson: "The product itself is the marketing." Kocienda: every animation and loading state built to survive Steve Jobs' scrutiny.

- [`product-transitions`](references/product-transitions.md) - Use semantic transitions for appearing views
- [`product-loading-states`](references/product-loading-states.md) - Show honest loading states, not indefinite spinners
- [`product-with-animation`](references/product-with-animation.md) - Use withAnimation for explicit state-driven animation
- [`product-matched-geometry`](references/product-matched-geometry.md) - Use matchedGeometryEffect for contextual origin transitions
- [`product-list-cells`](references/product-list-cells.md) - Design list cells with standard layouts
- [`product-content-unavailable`](references/product-content-unavailable.md) - Use ContentUnavailableView for empty and error states
- [`product-segmented`](references/product-segmented.md) - Use segmented controls for visible, mutually exclusive options
- [`product-menus`](references/product-menus.md) - Use menus for secondary actions without cluttering the interface

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure, principle sources, and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and principle grounding |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
