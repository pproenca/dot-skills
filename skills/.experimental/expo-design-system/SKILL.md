---
name: expo-design-system
description: Airbnb-DLS-aligned design system engineering for Expo / React Native apps built on Unistyles v3, Reanimated, Skia, and FlashList. Use whenever building, reviewing, or refactoring shared UI for the clinic mobile app — design tokens, theming, primitive and composite components, variant-driven component APIs, typography, spacing, native-feel performance, or the calendar, treatment-note, and body-chart drawing surfaces. Covers token architecture, theming and adaptivity, component API contracts (variants over style props), the Unistyles styling engine, and governance. Trigger even when the user does not say "design system" but is creating or changing reusable React Native components, tokens, or theme code. This skill teaches how to BUILD the design system; pair it with expo-react-native-coder for feature work.
---

# Airbnb DLS Expo React Native Design System Best Practices

Opinionated, strict design system engineering for Expo / React Native apps on the New Architecture. Contains 54 rules across 9 categories, prioritized by impact. Derived from Airbnb's Design Language System (DLS), the Unistyles v3 documentation, and the React Native ecosystem (Reanimated, Gesture Handler, Skia, FlashList, Expo SDK). The styling engine is Unistyles v3; the component API follows the Airbnb DLS pattern of variant props over style escape hatches.

## Mandated Architecture Alignment

This skill is the **infrastructure layer** — it teaches how to BUILD the design system itself, the React Native counterpart to `ios-design-system`. All code examples follow the same non-negotiable constraints:

- Feature modules import `@clinic/design-system` + `domain`; never another feature's internals
- The design system owns the Unistyles theme (tokens, breakpoints) and exports a curated public surface
- Components expose variant and slot props (Airbnb DLS); no raw `style` escape hatch
- Animation and gestures run on the UI thread (Reanimated worklets + Gesture Handler)
- Lists use FlashList; the body-chart drawing surface uses React Native Skia
- Targets the New Architecture (Fabric/JSI), Expo SDK 53+ / React Native 0.81+

## Scope & Relationship to Sibling Skills

| Sibling Skill | Its Focus | This Skill's Focus |
|---------------|-----------|-------------------|
| `ios-design-system` | The SwiftUI design system for the **same clinic app** | The Expo / React Native counterpart |
| `expo-react-native-coder` | **Feature development** (screens, navigation, data fetching) | **Design system infrastructure** (tokens, components, theming) |
| `expo-react-native-performance` | **App-wide performance** optimization | **Native-feel performance inside the design system** |
| `react` | General **React** patterns | **Expo / React Native** design system specifics |

## Clinic Architecture Contract (Expo / React Native)

All guidance in this skill assumes the clinic modular architecture:

- Feature modules depend on `@clinic/design-system` + `domain` only; the app target wires navigation (Expo Router) and dependency injection
- The design system is a local package with a single public entry; raw token layers stay private
- Token source of truth is the Unistyles theme; features never define local tokens
- Server state uses TanStack Query: reads default to stale-while-revalidate, writes are optimistic and queued for offline sync
- The New Architecture is required for Unistyles v3, Reanimated worklets, Skia, and FlashList v2

## When to Apply

Reference these guidelines when:
- Setting up a design system for a new Expo / React Native app
- Building token architecture (colors, typography, spacing, radius, elevation) in the Unistyles theme
- Designing component APIs — variants, slots, controlled/uncontrolled state, refs, accessibility
- Authoring component styles with Unistyles StyleSheet, variants, and dynamic functions
- Building the calendar, treatment-note editor, or Skia body-chart drawing surfaces
- Migrating ad-hoc styles to a governed token system
- Reviewing PRs for raw colors, inline styles, leaked `style` props, or feature-local tokens
- Tuning native feel — list virtualization, UI-thread animation, gestures, haptics, safe areas

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Token Architecture | CRITICAL | `token-` | 6 |
| 2 | Theming & Adaptivity | CRITICAL | `theme-` | 5 |
| 3 | Component API Contracts | CRITICAL | `api-` | 8 |
| 4 | Styling Engine (Unistyles) | HIGH | `style-` | 6 |
| 5 | Typography & Iconography | HIGH | `type-` | 5 |
| 6 | Spacing, Layout & Safe Areas | HIGH | `space-` | 5 |
| 7 | Native-Feel & Performance | HIGH | `perf-` | 7 |
| 8 | Complex Domain Components | MEDIUM-HIGH | `domain-` | 6 |
| 9 | Governance & Consistency | MEDIUM | `govern-` | 6 |

## Quick Reference

### 1. Token Architecture (CRITICAL)

- [`token-three-layer-scale`](references/token-three-layer-scale.md) - Layer tokens as raw, semantic, and component scales
- [`token-define-in-unistyles-theme`](references/token-define-in-unistyles-theme.md) - Keep the Unistyles theme as the single token source
- [`token-no-raw-values-in-components`](references/token-no-raw-values-in-components.md) - Route every color and size through tokens
- [`token-semantic-naming`](references/token-semantic-naming.md) - Name tokens by role, not by value
- [`token-elevation-pairs`](references/token-elevation-pairs.md) - Tokenize elevation as surface and shadow pairs
- [`token-avoid-over-abstraction`](references/token-avoid-over-abstraction.md) - Stop at three token layers

### 2. Theming & Adaptivity (CRITICAL)

- [`theme-runtime-not-rerender`](references/theme-runtime-not-rerender.md) - Switch themes via the runtime, no re-render
- [`theme-stylesheet-theme-arg`](references/theme-stylesheet-theme-arg.md) - Read theme from the StyleSheet argument
- [`theme-adaptive-system`](references/theme-adaptive-system.md) - Follow the system color scheme by default
- [`theme-breakpoints-responsive`](references/theme-breakpoints-responsive.md) - Use breakpoints, not Dimensions checks
- [`theme-config-single-module`](references/theme-config-single-module.md) - One typed config module for themes and breakpoints

### 3. Component API Contracts (CRITICAL)

- [`api-variants-over-style-prop`](references/api-variants-over-style-prop.md) - Express visual options as variant props
- [`api-no-style-escape-hatch`](references/api-no-style-escape-hatch.md) - No raw style prop on components
- [`api-compound-variants`](references/api-compound-variants.md) - Compound variants over per-combination components
- [`api-slots-for-composition`](references/api-slots-for-composition.md) - Slot props over a prop per element
- [`api-controlled-uncontrolled`](references/api-controlled-uncontrolled.md) - Support controlled and uncontrolled state
- [`api-forward-ref`](references/api-forward-ref.md) - Forward refs from leaf components
- [`api-accessibility-in-contract`](references/api-accessibility-in-contract.md) - Require accessibility props in the contract
- [`api-aschild-polymorphism`](references/api-aschild-polymorphism.md) - Offer asChild instead of wrapper nesting

### 4. Styling Engine (Unistyles) (HIGH)

- [`style-stylesheet-create`](references/style-stylesheet-create.md) - StyleSheet.create over inline objects
- [`style-variants-api`](references/style-variants-api.md) - Variants over ternary style arrays
- [`style-dynamic-functions`](references/style-dynamic-functions.md) - Dynamic functions for prop-driven values
- [`style-no-inline-array-merge`](references/style-no-inline-array-merge.md) - No inline array merges in lists
- [`style-withunistyles-third-party`](references/style-withunistyles-third-party.md) - Theme third-party components with withUnistyles
- [`style-press-states-from-variants`](references/style-press-states-from-variants.md) - Press and disabled states as variants

### 5. Typography & Iconography (HIGH)

- [`type-scale-tokens`](references/type-scale-tokens.md) - Define a named typography scale
- [`type-respect-font-scaling`](references/type-respect-font-scaling.md) - Respect OS font scaling
- [`type-text-component-wrapper`](references/type-text-component-wrapper.md) - Route text through one typed component
- [`type-font-loading-expo-font`](references/type-font-loading-expo-font.md) - Load fonts before first paint
- [`type-icon-registry`](references/type-icon-registry.md) - Centralize icons in a typed registry

### 6. Spacing, Layout & Safe Areas (HIGH)

- [`space-spacing-scale`](references/space-spacing-scale.md) - Use a spacing scale on a 4pt grid
- [`space-safe-area-insets`](references/space-safe-area-insets.md) - Apply safe-area insets at screen edges
- [`space-touch-targets`](references/space-touch-targets.md) - Size touch targets to at least 44 points
- [`space-gap-over-margins`](references/space-gap-over-margins.md) - Use gap over per-child margins
- [`space-radius-tokens`](references/space-radius-tokens.md) - Tokenize corner radius by role

### 7. Native-Feel & Performance (HIGH)

- [`perf-flashlist-for-lists`](references/perf-flashlist-for-lists.md) - FlashList over ScrollView lists
- [`perf-reanimated-ui-thread`](references/perf-reanimated-ui-thread.md) - Animate on the UI thread
- [`perf-gesture-handler`](references/perf-gesture-handler.md) - Gesture Handler over PanResponder
- [`perf-expo-image`](references/perf-expo-image.md) - Load images with expo-image and caching
- [`perf-memoize-list-items`](references/perf-memoize-list-items.md) - Memoize rows and callbacks
- [`perf-haptics-key-actions`](references/perf-haptics-key-actions.md) - Add haptics on confirmations and toggles
- [`perf-defer-offscreen-work`](references/perf-defer-offscreen-work.md) - Defer work past transitions

### 8. Complex Domain Components (MEDIUM-HIGH)

- [`domain-calendar-virtualization`](references/domain-calendar-virtualization.md) - Virtualize the appointment calendar by day
- [`domain-note-editor-autosave`](references/domain-note-editor-autosave.md) - Offline-first debounced note autosave
- [`domain-bodychart-skia-canvas`](references/domain-bodychart-skia-canvas.md) - Draw body charts on a Skia canvas
- [`domain-bodychart-gesture-paths`](references/domain-bodychart-gesture-paths.md) - Capture strokes via gestures and shared values
- [`domain-compose-from-primitives`](references/domain-compose-from-primitives.md) - Build domain components from primitives
- [`domain-optimistic-writes`](references/domain-optimistic-writes.md) - Render optimistic UI for writes

### 9. Governance & Consistency (MEDIUM)

- [`govern-design-system-package`](references/govern-design-system-package.md) - Package the design system with one entry
- [`govern-lint-no-raw-values`](references/govern-lint-no-raw-values.md) - Lint against raw colors and inline styles
- [`govern-prevent-local-tokens`](references/govern-prevent-local-tokens.md) - Prevent feature-local tokens
- [`govern-storybook-catalog`](references/govern-storybook-catalog.md) - Catalog component variants in Storybook
- [`govern-naming-conventions`](references/govern-naming-conventions.md) - Enforce one naming convention
- [`govern-incremental-migration`](references/govern-incremental-migration.md) - Migrate to tokens incrementally

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
