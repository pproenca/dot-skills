---
name: expo-ios-hig
description: Use this skill whenever building, reviewing, or refactoring an Expo / React Native app's iOS interface so it feels like a genuine iOS 26 app under Apple's Human Interface Guidelines — native navigation (Expo Router native stack and tabs), platform controls (Alert, ActionSheetIOS, SF Symbols via expo-symbols), safe areas, dark mode, Dynamic Type, haptics, Liquid Glass, accessibility, and 60fps motion. Trigger even when the user does not say "HIG" or "native feel" but is writing TSX screens, navigation, lists, forms, or styling for iOS in Expo. Covers the architecture and styling decisions made in React Native/TypeScript; for the @expo/ui SwiftUI component API use the expo-ui skill, and for native Swift use ios-hig.
---

# Expo iOS HIG Best Practices

Design rules for building iOS 26 apps in **Expo (React Native)** that feel genuinely native under Apple's Human Interface Guidelines. Contains **46 rules across 8 categories**, prioritized by how much each decision affects native feel and HIG compliance. Every example is **TSX/Expo** — the decisions you make in React Native and TypeScript, not Swift.

The core idea: a React Native app feels native when it *reaches for the platform* — the system navigation controller, system controls, semantic colors, SF Symbols, real haptics, the system share sheet — instead of re-implementing iOS in JavaScript. These rules say which decision earns the native feel and which one quietly forfeits it.

## When to Apply

Reference these guidelines when:

- Building or reviewing iOS screens, navigation, lists, or forms in an Expo app
- Choosing navigation: Expo Router native stack vs JS stack, native tabs, sheets, modals, large titles
- Picking controls: when to use the native `Alert`, `ActionSheetIOS`, date picker, `Switch`, SF Symbols, or drop to `@expo/ui`
- Styling for the platform: safe areas, dark mode, semantic colors, the iOS type scale, spacing, Liquid Glass
- Making interaction feel native: touch targets, press feedback, swipe actions, pull-to-refresh, gestures, haptics
- Adding motion, loading/empty states, accessibility, permissions, and launch polish

## When NOT to Use This Skill

- **The `@expo/ui` component API** — for how to use `@expo/ui/swift-ui` components, Host boundaries, and modifiers, use the **`expo-ui`** skill. This skill says *which decisions* make an app native and points to `@expo/ui` when dropping to SwiftUI is the right call; it does not re-document that API.
- **Native Swift / SwiftUI** — for HIG in a native Swift codebase, use **`ios-hig`** or **`ios-design`**. This skill's examples are all React Native/TSX.
- **Android** — these rules target iOS conventions. Use platform-adaptive code so Android gets Material; don't apply iOS idioms there.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Native Navigation Architecture | CRITICAL | `nav-` |
| 2 | Native Component Fidelity | CRITICAL | `native-` |
| 3 | Layout & Adaptivity | HIGH | `layout-` |
| 4 | Touch, Gestures & Haptics | HIGH | `touch-` |
| 5 | Visual System & Liquid Glass | HIGH | `visual-` |
| 6 | Motion & Feedback | MEDIUM-HIGH | `motion-` |
| 7 | Accessibility | MEDIUM-HIGH | `acc-` |
| 8 | System Integration & Polish | MEDIUM | `system-` |

## Quick Reference

### 1. Native Navigation Architecture (CRITICAL)

- [`nav-native-stack`](references/nav-native-stack.md) — Use Expo Router's native Stack for screen hierarchy
- [`nav-native-tabs`](references/nav-native-tabs.md) — Adopt native tabs for top-level sections
- [`nav-large-titles`](references/nav-large-titles.md) — Enable large titles on top-level screens
- [`nav-sheet-detents`](references/nav-sheet-detents.md) — Present secondary tasks as sheets with detents
- [`nav-push-vs-present`](references/nav-push-vs-present.md) — Push for hierarchy and present for self-contained tasks
- [`nav-search-in-header`](references/nav-search-in-header.md) — Place search in the navigation bar
- [`nav-system-back`](references/nav-system-back.md) — Keep the system back button and swipe-back gesture

### 2. Native Component Fidelity (CRITICAL)

- [`native-avoid-material-ui`](references/native-avoid-material-ui.md) — Avoid Material Design component kits on iOS
- [`native-sf-symbols`](references/native-sf-symbols.md) — Use SF Symbols for iconography
- [`native-system-alert`](references/native-system-alert.md) — Use the native alert for confirmations
- [`native-action-sheet`](references/native-action-sheet.md) — Use an action sheet to choose among actions
- [`native-datetime-picker`](references/native-datetime-picker.md) — Use the native date and time picker
- [`native-switch-toggle`](references/native-switch-toggle.md) — Use the platform Switch for boolean settings

### 3. Layout & Adaptivity (HIGH)

- [`layout-safe-area-insets`](references/layout-safe-area-insets.md) — Respect safe-area insets with the safe-area context
- [`layout-edge-to-edge`](references/layout-edge-to-edge.md) — Extend scrollable content under translucent bars
- [`layout-keyboard-avoidance`](references/layout-keyboard-avoidance.md) — Keep inputs visible above the keyboard
- [`layout-dark-mode-semantic`](references/layout-dark-mode-semantic.md) — Drive colors from the active color scheme
- [`layout-content-inset-under-bars`](references/layout-content-inset-under-bars.md) — Inset list content past the tab bar and home indicator
- [`layout-readable-width-ipad`](references/layout-readable-width-ipad.md) — Constrain reading width on iPad and large screens

### 4. Touch, Gestures & Haptics (HIGH)

- [`touch-hit-target`](references/touch-hit-target.md) — Size touch targets to at least 44pt
- [`touch-pressable-feedback`](references/touch-pressable-feedback.md) — Give every control immediate press feedback
- [`touch-swipe-actions`](references/touch-swipe-actions.md) — Offer swipe actions on list rows
- [`touch-pull-to-refresh`](references/touch-pull-to-refresh.md) — Use RefreshControl for pull-to-refresh
- [`touch-gesture-handler-thread`](references/touch-gesture-handler-thread.md) — Drive interactive gestures with Gesture Handler
- [`touch-haptics-on-outcome`](references/touch-haptics-on-outcome.md) — Pair haptics with meaningful outcomes

### 5. Visual System & Liquid Glass (HIGH)

- [`visual-semantic-colors`](references/visual-semantic-colors.md) — Use semantic system colors instead of hardcoded hex
- [`visual-system-font`](references/visual-system-font.md) — Use the system font for interface text
- [`visual-type-scale`](references/visual-type-scale.md) — Map text styles to the iOS type scale
- [`visual-spacing-rhythm`](references/visual-spacing-rhythm.md) — Derive spacing from a single base unit
- [`visual-liquid-glass-gated`](references/visual-liquid-glass-gated.md) — Apply Liquid Glass through a version-gated native view
- [`visual-tint-discipline`](references/visual-tint-discipline.md) — Reserve the accent tint for interactive elements

### 6. Motion & Feedback (MEDIUM-HIGH)

- [`motion-ui-thread-animation`](references/motion-ui-thread-animation.md) — Run animations on the UI thread
- [`motion-virtualized-lists`](references/motion-virtualized-lists.md) — Render long lists with a virtualized list
- [`motion-loading-states`](references/motion-loading-states.md) — Show content-shaped placeholders while loading
- [`motion-empty-states`](references/motion-empty-states.md) — Design empty states that guide the next action
- [`motion-optimistic-updates`](references/motion-optimistic-updates.md) — Apply optimistic updates for user actions

### 7. Accessibility (MEDIUM-HIGH)

- [`acc-roles-labels`](references/acc-roles-labels.md) — Label interactive and icon-only controls for VoiceOver
- [`acc-dynamic-type`](references/acc-dynamic-type.md) — Let text scale with Dynamic Type
- [`acc-reduce-motion`](references/acc-reduce-motion.md) — Honor the Reduce Motion setting
- [`acc-state-and-hint`](references/acc-state-and-hint.md) — Expose control state to assistive technology
- [`acc-grouping-focus`](references/acc-grouping-focus.md) — Group related elements for a logical focus order

### 8. System Integration & Polish (MEDIUM)

- [`system-permissions-jit`](references/system-permissions-jit.md) — Request permissions just in time with a rationale
- [`system-status-bar`](references/system-status-bar.md) — Match the status bar style to the content behind it
- [`system-keyboard-type`](references/system-keyboard-type.md) — Configure each text field for its content
- [`system-share-sheet`](references/system-share-sheet.md) — Share through the system share sheet
- [`system-app-icon-launch`](references/system-app-icon-launch.md) — Configure a real app icon and launch screen

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules
- Reference files: `references/{prefix}-{slug}.md`

Each rule file contains a short explanation of *why* it matters for native feel, an **Incorrect** (non-native) TSX example, a **Correct** (native) example that is a minimal diff from it, and an authoritative reference URL. Where relevant, rules add a "When NOT to use this pattern" or "Alternative" section.

## Related Skills

- **`expo-ui`** — `@expo/ui/swift-ui` component API reference. Use it when the rules here point you to native SwiftUI components.
- **`ios-hig`** / **`ios-design`** — HIG and Apple design principles for native Swift/SwiftUI codebases.
- **`expo`** — Expo React Native performance optimization, complementary to the motion/list rules here.
