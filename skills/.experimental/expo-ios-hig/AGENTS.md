# Expo (React Native) for iOS 26

**Version 0.1.1**  
Expo iOS HIG  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs maintaining, generating, or reviewing Expo (React Native) for iOS 26 code. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Human Interface Guidelines and native-experience design rules for building iOS 26 apps in Expo (React Native). Contains 46 rules across 8 categories — native navigation, component fidelity, layout and adaptivity, touch and haptics, visual system and Liquid Glass, motion, accessibility, and system integration — each with TSX examples comparing a non-native implementation against a native one, prioritized by impact on native feel and HIG compliance. Designed to guide AI agents writing or reviewing Expo iOS code in TypeScript. Complements the expo-ui component-API reference, the cross-platform expo-design-system skill (shared tokens, component APIs, and web/iOS parity), and the native-Swift ios-hig skill.

---

## Table of Contents

1. [Native Navigation Architecture](references/_sections.md#1-native-navigation-architecture) — **CRITICAL**
   - 1.1 [Adopt native tabs for top-level sections](references/nav-native-tabs.md) — CRITICAL (enables the system tab bar with SF Symbols and Liquid Glass)
   - 1.2 [Enable large titles on top-level screens](references/nav-large-titles.md) — HIGH (enables large-title collapse and the scroll-edge appearance)
   - 1.3 [Keep the system back button and swipe-back gesture](references/nav-system-back.md) — HIGH (preserves the interactive swipe-back edge gesture)
   - 1.4 [Place search in the navigation bar](references/nav-search-in-header.md) — MEDIUM-HIGH (enables the native search field that hides on scroll)
   - 1.5 [Present secondary tasks as sheets with detents](references/nav-sheet-detents.md) — HIGH (enables partial-height sheets with grabber and swipe-to-dismiss)
   - 1.6 [Push for hierarchy and present for self-contained tasks](references/nav-push-vs-present.md) — HIGH (prevents broken back stacks and mismatched transitions)
   - 1.7 [Use Expo Router's native Stack for screen hierarchy](references/nav-native-stack.md) — CRITICAL (preserves native push/pop, swipe-back, and Liquid Glass headers)
2. [Native Component Fidelity](references/_sections.md#2-native-component-fidelity) — **CRITICAL**
   - 2.1 [Avoid Material Design component kits on iOS](references/native-avoid-material-ui.md) — CRITICAL (eliminates Android Material chrome on iOS)
   - 2.2 [Use an action sheet to choose among actions](references/native-action-sheet.md) — HIGH (enables the system action sheet with destructive styling)
   - 2.3 [Use SF Symbols for iconography](references/native-sf-symbols.md) — CRITICAL (enables 6,900+ system symbols with weight and scale matching)
   - 2.4 [Use the native alert for confirmations](references/native-system-alert.md) — HIGH (preserves native alert appearance, haptics, and accessibility)
   - 2.5 [Use the native date and time picker](references/native-datetime-picker.md) — MEDIUM-HIGH (enables the native wheel and calendar pickers)
   - 2.6 [Use the platform Switch for boolean settings](references/native-switch-toggle.md) — MEDIUM-HIGH (preserves correct toggle size, animation, and accessibility)
3. [Layout & Adaptivity](references/_sections.md#3-layout-&-adaptivity) — **HIGH**
   - 3.1 [Constrain reading width on iPad and large screens](references/layout-readable-width-ipad.md) — MEDIUM (prevents over-stretched lines on iPad)
   - 3.2 [Drive colors from the active color scheme](references/layout-dark-mode-semantic.md) — HIGH (enables automatic light and dark adaptation)
   - 3.3 [Extend scrollable content under translucent bars](references/layout-edge-to-edge.md) — HIGH (enables the scroll-edge translucency of system bars)
   - 3.4 [Inset list content past the tab bar and home indicator](references/layout-content-inset-under-bars.md) — MEDIUM-HIGH (prevents the last row hidden behind the tab bar)
   - 3.5 [Keep inputs visible above the keyboard](references/layout-keyboard-avoidance.md) — HIGH (prevents inputs hidden behind the keyboard)
   - 3.6 [Respect safe-area insets with the safe-area context](references/layout-safe-area-insets.md) — HIGH (prevents content clipped by the notch and home indicator)
4. [Touch, Gestures & Haptics](references/_sections.md#4-touch,-gestures-&-haptics) — **HIGH**
   - 4.1 [Drive interactive gestures with Gesture Handler](references/touch-gesture-handler-thread.md) — HIGH (maintains 60fps gestures off the JS thread)
   - 4.2 [Give every control immediate press feedback](references/touch-pressable-feedback.md) — HIGH (prevents the double-tap from an unconfirmed press)
   - 4.3 [Offer swipe actions on list rows](references/touch-swipe-actions.md) — MEDIUM-HIGH (eliminates an extra menu step for delete and archive)
   - 4.4 [Pair haptics with meaningful outcomes](references/touch-haptics-on-outcome.md) — MEDIUM (prevents overuse that dulls the Taptic signal)
   - 4.5 [Size touch targets to at least 44pt](references/touch-hit-target.md) — HIGH (enables reliable taps with a 44pt minimum target)
   - 4.6 [Use RefreshControl for pull-to-refresh](references/touch-pull-to-refresh.md) — MEDIUM-HIGH (enables the native pull-to-refresh spinner)
5. [Visual System & Liquid Glass](references/_sections.md#5-visual-system-&-liquid-glass) — **HIGH**
   - 5.1 [Apply Liquid Glass through a version-gated native view](references/visual-liquid-glass-gated.md) — HIGH (prevents crashes on pre-iOS-26 while enabling glass)
   - 5.2 [Derive spacing from a single base unit](references/visual-spacing-rhythm.md) — MEDIUM (enables a consistent grid from one base unit)
   - 5.3 [Map text styles to the iOS type scale](references/visual-type-scale.md) — MEDIUM-HIGH (enables a hierarchy mapped to iOS text styles)
   - 5.4 [Reserve the accent tint for interactive elements](references/visual-tint-discipline.md) — MEDIUM (preserves a single, meaningful accent color)
   - 5.5 [Use semantic system colors instead of hardcoded hex](references/visual-semantic-colors.md) — HIGH (enables colors that track appearance and contrast)
   - 5.6 [Use the system font for interface text](references/visual-system-font.md) — MEDIUM-HIGH (enables San Francisco with optical sizing and tracking)
6. [Motion & Feedback](references/_sections.md#6-motion-&-feedback) — **MEDIUM-HIGH**
   - 6.1 [Apply optimistic updates for user actions](references/motion-optimistic-updates.md) — MEDIUM (eliminates round-trip latency on user actions)
   - 6.2 [Design empty states that guide the next action](references/motion-empty-states.md) — MEDIUM (prevents dead-end blank screens)
   - 6.3 [Render long lists with a virtualized list](references/motion-virtualized-lists.md) — MEDIUM-HIGH (maintains 60fps scrolling over 10K+ rows)
   - 6.4 [Run animations on the UI thread](references/motion-ui-thread-animation.md) — MEDIUM-HIGH (maintains 60fps by animating off the JS thread)
   - 6.5 [Show content-shaped placeholders while loading](references/motion-loading-states.md) — MEDIUM (reduces perceived wait with content-shaped placeholders)
7. [Accessibility](references/_sections.md#7-accessibility) — **MEDIUM-HIGH**
   - 7.1 [Expose control state to assistive technology](references/acc-state-and-hint.md) — MEDIUM (enables VoiceOver to announce state and outcome)
   - 7.2 [Group related elements for a logical focus order](references/acc-grouping-focus.md) — MEDIUM (enables a logical, predictable focus order)
   - 7.3 [Honor the Reduce Motion setting](references/acc-reduce-motion.md) — MEDIUM (prevents vestibular discomfort from animation)
   - 7.4 [Label interactive and icon-only controls for VoiceOver](references/acc-roles-labels.md) — MEDIUM-HIGH (enables VoiceOver to announce purpose and role)
   - 7.5 [Let text scale with Dynamic Type](references/acc-dynamic-type.md) — MEDIUM-HIGH (enables text scaling up to 310% for low vision)
8. [System Integration & Polish](references/_sections.md#8-system-integration-&-polish) — **MEDIUM**
   - 8.1 [Configure a real app icon and launch screen](references/system-app-icon-launch.md) — LOW-MEDIUM (prevents shipping the placeholder icon and splash)
   - 8.2 [Configure each text field for its content](references/system-keyboard-type.md) — MEDIUM (enables the correct keyboard and autofill per field)
   - 8.3 [Match the status bar style to the content behind it](references/system-status-bar.md) — MEDIUM (prevents an invisible status bar over content)
   - 8.4 [Request permissions just in time with a rationale](references/system-permissions-jit.md) — MEDIUM (enables higher opt-in with just-in-time prompts)
   - 8.5 [Share through the system share sheet](references/system-share-sheet.md) — MEDIUM (enables the system share sheet and its extensions)

---

## References

1. [https://developer.apple.com/design/human-interface-guidelines/](https://developer.apple.com/design/human-interface-guidelines/)
2. [https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)
3. [https://docs.expo.dev/router/advanced/stack/](https://docs.expo.dev/router/advanced/stack/)
4. [https://docs.expo.dev/router/advanced/native-tabs/](https://docs.expo.dev/router/advanced/native-tabs/)
5. [https://docs.expo.dev/develop/user-interface/color-themes/](https://docs.expo.dev/develop/user-interface/color-themes/)
6. [https://docs.expo.dev/develop/user-interface/safe-areas/](https://docs.expo.dev/develop/user-interface/safe-areas/)
7. [https://docs.expo.dev/versions/latest/sdk/glass-effect/](https://docs.expo.dev/versions/latest/sdk/glass-effect/)
8. [https://docs.expo.dev/versions/latest/sdk/symbols/](https://docs.expo.dev/versions/latest/sdk/symbols/)
9. [https://docs.expo.dev/versions/latest/sdk/haptics/](https://docs.expo.dev/versions/latest/sdk/haptics/)
10. [https://docs.expo.dev/versions/latest/sdk/status-bar/](https://docs.expo.dev/versions/latest/sdk/status-bar/)
11. [https://docs.expo.dev/develop/user-interface/splash-screen-and-app-icon/](https://docs.expo.dev/develop/user-interface/splash-screen-and-app-icon/)
12. [https://expo.dev/blog/how-to-create-apple-maps-style-liquid-glass-sheets](https://expo.dev/blog/how-to-create-apple-maps-style-liquid-glass-sheets)
13. [https://reactnative.dev/docs/accessibility](https://reactnative.dev/docs/accessibility)
14. [https://reactnative.dev/docs/platformcolor](https://reactnative.dev/docs/platformcolor)
15. [https://reactnative.dev/docs/pressable](https://reactnative.dev/docs/pressable)
16. [https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
17. [https://docs.swmansion.com/react-native-gesture-handler/docs/](https://docs.swmansion.com/react-native-gesture-handler/docs/)
18. [https://shopify.github.io/flash-list/docs/](https://shopify.github.io/flash-list/docs/)
19. [https://github.com/react-native-datetimepicker/datetimepicker](https://github.com/react-native-datetimepicker/datetimepicker)
20. [https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |