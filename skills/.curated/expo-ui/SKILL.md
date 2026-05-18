---
name: expo-ui
description: Library reference for @expo/ui SwiftUI components on iOS — covers Host boundaries, modifier composition, iOS 26 Liquid Glass and Human Interface Guidelines composition rules, layout/input/navigation/display catalogues, and ObservableState patterns. Use this skill whenever writing or reviewing React Native code that imports from @expo/ui/swift-ui or @expo/ui/swift-ui/modifiers — including new Expo apps adopting native SwiftUI views, migrations from React Native primitives to expo-ui, and code targeting iOS 26 features (Liquid Glass, GlassEffectContainer, sheet detents). Trigger even if the user does not explicitly mention "expo-ui" but is writing iOS-targeted Expo UI code that should bridge to SwiftUI.
---

# Expo @expo/ui SwiftUI Best Practices

Library reference for `@expo/ui/swift-ui` and `@expo/ui/swift-ui/modifiers` — the iOS surface of Expo's native UI bridge. Contains 53 rules across 8 categories, prioritised by cascade impact for agents building Expo apps that render to native SwiftUI views on iOS 26 and earlier.

## When to Apply

Reference these guidelines when:

- Building a new screen with `@expo/ui/swift-ui` — pick the right container (Form vs List vs ScrollView), wrap in Host correctly, apply modifiers
- Migrating from React Native primitives (View, Text, TouchableOpacity) to native SwiftUI components
- Targeting iOS 26 features — Liquid Glass material, GlassEffectContainer, new sheet detent behaviours
- Reviewing code that imports from `@expo/ui/swift-ui` or `@expo/ui/swift-ui/modifiers`
- Debugging "the SwiftUI view doesn't render / is the wrong size / ignores styles" — usually a Host or modifier issue
- Composing presentation surfaces — Alert, ConfirmationDialog, BottomSheet, Popover — under HIG modality guidance
- Writing controlled inputs (TextField, Toggle, Picker, Slider) with `useNativeState` and worklet writes

## When NOT to Use This Skill

- **Android Jetpack Compose** — this skill covers iOS SwiftUI only. The `@expo/ui/jetpack-compose` surface has its own conventions
- **Universal (cross-platform) components** — `@expo/ui` exposes a small set; this skill scopes to the platform-specific iOS surface
- **Navigation routing** — for stack/tab routing, use `expo-router` and `expo-router/unstable-native-tabs`; this skill covers UI composition only
- **Pre-iOS-17 fallbacks** — most rules assume iOS 17 minimum; Liquid Glass rules require iOS 26

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Setup & Host Boundaries | CRITICAL | `host-` |
| 2 | iOS 26 HIG Composition Rules | CRITICAL | `hig-` |
| 3 | Modifiers System | CRITICAL | `mod-` |
| 4 | Layout Components | HIGH | `layout-` |
| 5 | Input & Controls | HIGH | `input-` |
| 6 | Navigation & Overlays | HIGH | `nav-` |
| 7 | Display & Feedback | MEDIUM-HIGH | `display-` |
| 8 | State & Cross-Cutting Patterns | MEDIUM | `state-` |

## Quick Reference

### 1. Setup & Host Boundaries (CRITICAL)

- [`host-wrap-all-swiftui-roots`](references/host-wrap-all-swiftui-roots.md) — Wrap every SwiftUI subtree in a Host
- [`host-match-contents`](references/host-match-contents.md) — Size Host to its SwiftUI content with matchContents
- [`host-viewport-size-for-form`](references/host-viewport-size-for-form.md) — Use useViewportSizeMeasurement for Form and List
- [`host-color-scheme-explicit`](references/host-color-scheme-explicit.md) — Pass explicit colorScheme when overriding the system
- [`host-ignore-safe-area`](references/host-ignore-safe-area.md) — Use ignoreSafeArea only for full-bleed surfaces

### 2. iOS 26 HIG Composition Rules (CRITICAL)

- [`hig-glass-effect-container`](references/hig-glass-effect-container.md) — Group glass siblings inside GlassEffectContainer
- [`hig-no-glass-on-glass`](references/hig-no-glass-on-glass.md) — Avoid nesting glassEffect on glass surfaces
- [`hig-no-stacked-modals`](references/hig-no-stacked-modals.md) — Resolve a sheet before presenting another
- [`hig-popover-iphone-fallback`](references/hig-popover-iphone-fallback.md) — Don't use Popover on iPhone — use BottomSheet
- [`hig-sheet-detents-partial`](references/hig-sheet-detents-partial.md) — Include a partial detent for Liquid Glass appearance
- [`hig-confirmation-dialog-destructive`](references/hig-confirmation-dialog-destructive.md) — ConfirmationDialog + destructive role
- [`hig-tint-only-for-brand`](references/hig-tint-only-for-brand.md) — Reserve tint for brand surfaces, not destructive

### 3. Modifiers System (CRITICAL)

- [`mod-prop-not-style`](references/mod-prop-not-style.md) — Modifiers go through the `modifiers` prop, not RN style
- [`mod-composition-order`](references/mod-composition-order.md) — Modifier order is meaningful — each wraps the previous
- [`mod-import-from-modifiers-subpath`](references/mod-import-from-modifiers-subpath.md) — Import from `@expo/ui/swift-ui/modifiers`
- [`mod-frame-vs-fixedsize`](references/mod-frame-vs-fixedsize.md) — frame proposes a size, fixedSize opts out of flex
- [`mod-padding-vs-frame`](references/mod-padding-vs-frame.md) — padding for inner space, frame for outer bounds
- [`mod-presentation-on-sheet-content`](references/mod-presentation-on-sheet-content.md) — Presentation modifiers attach to sheet content
- [`mod-disabled-prop`](references/mod-disabled-prop.md) — Use disabled modifier, don't conditionally render
- [`mod-animation-wraps-trigger`](references/mod-animation-wraps-trigger.md) — withAnimation wraps state-driven prop changes

### 4. Layout Components (HIGH)

- [`layout-hstack-vs-vstack`](references/layout-hstack-vs-vstack.md) — Pick stack direction by content flow
- [`layout-lazy-stack-for-long-lists`](references/layout-lazy-stack-for-long-lists.md) — LazyVStack inside ScrollView for long lists
- [`layout-form-for-settings`](references/layout-form-for-settings.md) — Form adopts iOS grouped chrome automatically
- [`layout-section-with-header-footer`](references/layout-section-with-header-footer.md) — Use Section header/footer slots
- [`layout-scrollview-axes`](references/layout-scrollview-axes.md) — Set axes explicitly for horizontal/2D scroll
- [`layout-grid-vs-stack`](references/layout-grid-vs-stack.md) — Grid for column-aligned content

### 5. Input & Controls (HIGH)

- [`input-button-role-for-destructive`](references/input-button-role-for-destructive.md) — Set role='destructive' for delete buttons
- [`input-button-systemimage`](references/input-button-systemimage.md) — Use systemImage SF Symbol for button icons
- [`input-textfield-observable-state`](references/input-textfield-observable-state.md) — useNativeState for TextField, not React state
- [`input-securefield-for-passwords`](references/input-securefield-for-passwords.md) — SecureField for passwords, not TextField
- [`input-toggle-on-async`](references/input-toggle-on-async.md) — SyncToggle for instant flicks, Toggle for async
- [`input-picker-style-via-modifier`](references/input-picker-style-via-modifier.md) — pickerStyle modifier picks appearance
- [`input-date-picker-range`](references/input-date-picker-range.md) — Constrain selectable dates with range
- [`input-stepper-bounded`](references/input-stepper-bounded.md) — Provide min and max on Stepper

### 6. Navigation & Overlays (HIGH)

- [`nav-alert-for-critical-only`](references/nav-alert-for-critical-only.md) — Alert for blocking notifications only
- [`nav-context-menu-vs-swipe`](references/nav-context-menu-vs-swipe.md) — ContextMenu or SwipeActions per row, not both
- [`nav-bottom-sheet-via-group`](references/nav-bottom-sheet-via-group.md) — Wrap BottomSheet content in Group
- [`nav-share-link-system`](references/nav-share-link-system.md) — ShareLink for the system share sheet
- [`nav-tabview-style-modifier`](references/nav-tabview-style-modifier.md) — tabViewStyle modifier picks appearance
- [`nav-disclosure-group-collapsible`](references/nav-disclosure-group-collapsible.md) — DisclosureGroup for collapsible sections
- [`nav-link-not-button-for-urls`](references/nav-link-not-button-for-urls.md) — Link for URLs, Button for in-app actions
- [`nav-menu-primary-action`](references/nav-menu-primary-action.md) — onPrimaryAction disambiguates tap from long-press

### 7. Display & Feedback (MEDIUM-HIGH)

- [`display-text-markdown`](references/display-text-markdown.md) — Enable markdownEnabled for inline rich text
- [`display-image-system-name`](references/display-image-system-name.md) — Prefer systemName SF Symbols over uiImage
- [`display-chart-data-points`](references/display-chart-data-points.md) — ChartDataPoint arrays drive native axes
- [`display-gauge-current-value-label`](references/display-gauge-current-value-label.md) — Provide currentValueLabel for accessibility
- [`display-progress-indeterminate`](references/display-progress-indeterminate.md) — Undefined value → spinner, 0 → frozen bar
- [`display-label-icon-vs-title`](references/display-label-icon-vs-title.md) — systemImage for SF Symbols, icon slot for custom

### 8. State & Cross-Cutting Patterns (MEDIUM)

- [`state-use-native-state-for-fields`](references/state-use-native-state-for-fields.md) — useNativeState for every bridged input
- [`state-worklet-writes`](references/state-worklet-writes.md) — Update ObservableState from worklets
- [`state-controlled-via-selection-prop`](references/state-controlled-via-selection-prop.md) — selection or defaultSelection, not both
- [`state-platform-check-pre-26`](references/state-platform-check-pre-26.md) — Guard iOS 26-only features with version check
- [`state-textfield-ref-imperative`](references/state-textfield-ref-imperative.md) — TextFieldRef for focus and selection

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules
- Reference files: `references/{prefix}-{slug}.md`

Each rule file contains:
- Brief explanation of why it matters in the SwiftUI bridge
- Incorrect code example anchored to a realistic domain
- Correct code example with a minimal diff from the incorrect one
- Where relevant: Alternative approach, When NOT to use, Warning callouts, authoritative reference URL

## Gotchas

See [gotchas.md](gotchas.md) — append entries as failure points surface during real use.

## Related Skills

- For Android Jetpack Compose components, the parallel skill would target `@expo/ui/jetpack-compose`
- For navigation routing (stack, tabs), use `expo-router` directly
- For form validation libraries, see the `react-hook-form` skill
