# @expo/ui (SwiftUI for iOS)

**Version 0.1.0**  
Expo  
May 2026

> **Note:**  
> This document targets @expo/ui (SwiftUI for iOS) codebases. It is mainly for agents  
> and LLMs to follow when maintaining, generating, or refactoring code that imports from  
> `@expo/ui/swift-ui` and `@expo/ui/swift-ui/modifiers`. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Library reference for @expo/ui SwiftUI components — covers Host boundaries, modifier composition, iOS 26 Liquid Glass and Human Interface Guidelines composition rules, layout/input/navigation/display catalogues, and ObservableState patterns. Rules are derived from the expo-ui source (v56.0.8) and Apple's iOS 26 HIG, prioritised by cascade impact for agents building Expo apps that bridge to native SwiftUI views.

---

## Table of Contents

1. [Setup & Host Boundaries](references/_sections.md#1-setup-&-host-boundaries) — **CRITICAL**
   - 1.1 [Pass an Explicit colorScheme to Host When Overriding System Appearance](references/host-color-scheme-explicit.md) — CRITICAL (prevents SwiftUI tree from reading stale Appearance and forcing the wrong theme)
   - 1.2 [Use ignoreSafeArea Only for Full-Bleed Surfaces](references/host-ignore-safe-area.md) — CRITICAL (prevents controls from sliding under the home indicator or notch)
   - 1.3 [Use matchContents to Size Host to Its SwiftUI Content](references/host-match-contents.md) — CRITICAL (prevents zero-height hosts and layout glitches when SwiftUI content is intrinsically sized)
   - 1.4 [Use useViewportSizeMeasurement for Form and Fill-Available Content](references/host-viewport-size-for-form.md) — CRITICAL (enables Form and List to expand to the available viewport instead of collapsing)
   - 1.5 [Wrap All SwiftUI Trees in a Host Component](references/host-wrap-all-swiftui-roots.md) — CRITICAL (prevents native view registration failures and missing layout for every SwiftUI descendant)
2. [iOS 26 HIG Composition Rules](references/_sections.md#2-ios-26-hig-composition-rules) — **CRITICAL**
   - 2.1 [Avoid Nesting glassEffect Inside Already-Glass Surfaces](references/hig-no-glass-on-glass.md) — CRITICAL (prevents broken material rendering — stacked glass produces opaque or visually muddy artefacts)
   - 2.2 [Avoid Presenting a Sheet from Inside Another Sheet](references/hig-no-stacked-modals.md) — CRITICAL (prevents users from facing multiple dismissal layers and disorientation)
   - 2.3 [Include a Partial Detent to Enable the Liquid Glass Sheet Appearance](references/hig-sheet-detents-partial.md) — CRITICAL (enables the floating Liquid Glass sheet — `.large`-only sheets fall back to edge-anchored opaque chrome on iOS 26)
   - 2.4 [Reserve tint Modifier for Brand Surfaces — Keep Semantic System Colors](references/hig-tint-only-for-brand.md) — CRITICAL (preserves the system's destructive-red and accessibility colour contracts)
   - 2.5 [Use ConfirmationDialog or BottomSheet on iPhone Instead of Popover](references/hig-popover-iphone-fallback.md) — CRITICAL (prevents Popover from rendering as an unanchored sheet on compact widths — breaking HIG popover guidance)
   - 2.6 [Use ConfirmationDialog with role='destructive' for Destructive Confirmations](references/hig-confirmation-dialog-destructive.md) — CRITICAL (enables system-red destructive styling and proper VoiceOver semantics — prevents accidental data loss)
   - 2.7 [Wrap Multiple Glass Siblings in a GlassEffectContainer](references/hig-glass-effect-container.md) — CRITICAL (enables Liquid Glass siblings to morph and blend as one shape, prevents per-element pipeline cost)
3. [Modifiers System](references/_sections.md#3-modifiers-system) — **CRITICAL**
   - 3.1 [Apply Presentation Modifiers to Sheet Content, Not the Trigger](references/mod-presentation-on-sheet-content.md) — CRITICAL (prevents the modifier from attaching to the wrong view — modifiers on the trigger do nothing)
   - 3.2 [Apply Visual Modifications via the modifiers Prop, Not React Native style](references/mod-prop-not-style.md) — CRITICAL (prevents silent no-ops — RN style is ignored by every native SwiftUI view in @expo/ui)
   - 3.3 [Import Modifiers from the @expo/ui/swift-ui/modifiers Subpath](references/mod-import-from-modifiers-subpath.md) — HIGH (prevents bundling the modifier graph through the main entry — direct subpath import keeps tree-shaking accurate)
   - 3.4 [Order Modifiers from Inside-Out — Each Wraps the Previous](references/mod-composition-order.md) — CRITICAL (prevents visually wrong layering — padding-then-background paints inside the padding, background-then-padding paints the padding)
   - 3.5 [Use frame for Explicit Sizing — fixedSize to Opt Out of Flex](references/mod-frame-vs-fixedsize.md) — HIGH (prevents the wrong sizing strategy — frame proposes a size, fixedSize tells SwiftUI to use the view's intrinsic size)
   - 3.6 [Use padding for Inner Space — frame for Outer Constraints](references/mod-padding-vs-frame.md) — HIGH (prevents double-counting space — padding adds inside the view's bounds, frame fixes total bounds)
   - 3.7 [Use the disabled Modifier — Don't Conditionally Render](references/mod-disabled-prop.md) — HIGH (preserves accessibility focus order and prevents layout shift when toggling availability)
   - 3.8 [Wrap State-Driven Prop Changes in withAnimation for Smooth Transitions](references/mod-animation-wraps-trigger.md) — HIGH (enables SwiftUI's implicit transitions for value changes — without it, transitions snap instantly)
4. [Layout Components](references/_sections.md#4-layout-components) — **HIGH**
   - 4.1 [Pick Stack Direction by Content Flow — HStack for Rows, VStack for Columns](references/layout-hstack-vs-vstack.md) — HIGH (prevents content from wrapping or overflowing the wrong axis)
   - 4.2 [Set axes Explicitly on ScrollView for Horizontal or 2D Scrolling](references/layout-scrollview-axes.md) — MEDIUM-HIGH (prevents accidental vertical-only scroll when horizontal or both axes are needed)
   - 4.3 [Use Form for Settings-Style Screens — Not VStack Inside ScrollView](references/layout-form-for-settings.md) — HIGH (enables inset-grouped chrome, automatic separators, and HIG-correct settings styling)
   - 4.4 [Use Grid for Column-Aligned Content — Stacks Don't Align Across Rows](references/layout-grid-vs-stack.md) — MEDIUM-HIGH (enables cells in successive rows to line up — VStack of HStacks lets each row size its columns independently)
   - 4.5 [Use LazyVStack or LazyHStack for Long Lists Inside ScrollView](references/layout-lazy-stack-for-long-lists.md) — HIGH (defers off-screen row layout — eager VStack frames every child at mount, 10-100× initial-layout cost on 500-row lists)
   - 4.6 [Use Section.header and Section.footer Slots for Grouped Context](references/layout-section-with-header-footer.md) — MEDIUM-HIGH (enables rich contextual headers and explanatory footers without breaking out of the Form/List chrome)
5. [Input & Controls](references/_sections.md#5-input-&-controls) — **HIGH**
   - 5.1 [Constrain Selectable Dates with the range Prop](references/input-date-picker-range.md) — HIGH (prevents invalid date submission — the picker rejects out-of-range taps natively)
   - 5.2 [Provide min and max on Stepper to Bound the Increment Range](references/input-stepper-bounded.md) — MEDIUM-HIGH (prevents out-of-range values — the + and - buttons disable at the boundaries)
   - 5.3 [Set Picker Appearance via pickerStyle Modifier, Not a Prop](references/input-picker-style-via-modifier.md) — HIGH (enables the four Picker appearances (wheel, segmented, menu, inline) — Picker takes no style prop)
   - 5.4 [Use Button role='destructive' for Delete-Style Actions](references/input-button-role-for-destructive.md) — HIGH (enables system-red styling, VoiceOver announcement, and HIG-correct semantic — prevents accidental confirms)
   - 5.5 [Use SecureField for Password Inputs — Not TextField](references/input-securefield-for-passwords.md) — HIGH (enables password autofill, biometric autofill, and prevents screenshot capture of the text)
   - 5.6 [Use systemImage for Button Icons — SF Symbols Scale and Adapt Automatically](references/input-button-systemimage.md) — HIGH (enables Dynamic Type scaling, dark mode adaptation, and symbol effect support — prevents pixelation on Retina displays)
   - 5.7 [Use Toggle for Async State, SyncToggle for Instant Native Updates](references/input-toggle-on-async.md) — HIGH (prevents toggle-flicker — Toggle round-trips state through React, SyncToggle commits to the native state directly)
   - 5.8 [Use useNativeState for TextField text — Not React useState](references/input-textfield-observable-state.md) — HIGH (enables zero-latency native text updates and worklet-thread writes — React state round-trips through the JS bridge)
6. [Navigation & Overlays](references/_sections.md#6-navigation-&-overlays) — **HIGH**
   - 6.1 [Choose ContextMenu OR SwipeActions per Row — Not Both](references/nav-context-menu-vs-swipe.md) — HIGH (prevents discoverability ambiguity — long-press and edge-swipe gestures compete for the same affordance space)
   - 6.2 [Set onPrimaryAction on Menu to Disambiguate Tap from Long-Press](references/nav-menu-primary-action.md) — MEDIUM-HIGH (enables instant tap for the primary action — without it, every tap opens the menu chooser)
   - 6.3 [Set TabView Appearance via tabViewStyle Modifier](references/nav-tabview-style-modifier.md) — HIGH (enables the three TabView appearances (automatic bottom-bar, swipeable pager, sidebar-adaptable) — no style prop exists)
   - 6.4 [Use Alert Only for App-Blocking Critical Information](references/nav-alert-for-critical-only.md) — HIGH (prevents alert fatigue — reserves the highest-modality affordance for critical events)
   - 6.5 [Use DisclosureGroup for Collapsible Detail Inside Forms](references/nav-disclosure-group-collapsible.md) — MEDIUM-HIGH (enables HIG-correct expand/collapse chevron — Section's isExpanded only works inside sidebar lists)
   - 6.6 [Use Link for URL Navigation — Button for In-App Actions](references/nav-link-not-button-for-urls.md) — MEDIUM-HIGH (enables system URL handling including SafariViewController fallbacks and universal-link routing)
   - 6.7 [Use ShareLink for System Share — Not a Custom Sheet](references/nav-share-link-system.md) — HIGH (enables the full iOS share sheet (AirDrop, system apps, extensions) — custom sheets only show what you wire up)
   - 6.8 [Wrap BottomSheet Content in Group to Attach Presentation Modifiers](references/nav-bottom-sheet-via-group.md) — HIGH (enables detents, drag indicator, and background interaction modifiers — bare content can't attach them)
7. [Display & Feedback](references/_sections.md#7-display-&-feedback) — **MEDIUM-HIGH**
   - 7.1 [Build Chart Data from ChartDataPoint Arrays, Not Raw Numbers](references/display-chart-data-points.md) — MEDIUM-HIGH (enables per-point colour, native axis labels, and chart-type switching without restructuring data)
   - 7.2 [Enable markdownEnabled for Inline Bold, Italic, Links](references/display-text-markdown.md) — MEDIUM-HIGH (enables inline markdown formatting — avoids fragile multi-Text concatenation that breaks Dynamic Type wrapping)
   - 7.3 [Pass value=undefined to ProgressView for Indeterminate Spinner](references/display-progress-indeterminate.md) — MEDIUM-HIGH (enables the system indeterminate spinner — passing 0 shows a frozen-at-zero progress bar)
   - 7.4 [Prefer systemName SF Symbols Over Raster uiImage for Icons](references/display-image-system-name.md) — MEDIUM-HIGH (enables variable color, dynamic-type scaling, and symbol effects — uiImage is a synchronous main-thread file read)
   - 7.5 [Provide currentValueLabel on Gauge for Accessibility and Context](references/display-gauge-current-value-label.md) — MEDIUM-HIGH (enables VoiceOver to read the current value and preserves the numeric context for sighted users)
   - 7.6 [Use Label.systemImage for SF Symbols, Label.icon for Custom Glyphs](references/display-label-icon-vs-title.md) — MEDIUM (enables correct icon layering — systemImage gets symbol effects, icon slot takes a full SwiftUI subview)
8. [State & Cross-Cutting Patterns](references/_sections.md#8-state-&-cross-cutting-patterns) — **MEDIUM**
   - 8.1 [Choose selection (Controlled) or defaultSelection (Uncontrolled) — Not Both](references/state-controlled-via-selection-prop.md) — MEDIUM (prevents prop conflicts — components ignore defaultSelection when selection is also provided)
   - 8.2 [Guard iOS 26-Only Features With a Platform Version Check](references/state-platform-check-pre-26.md) — MEDIUM (prevents runtime crashes on iOS 17/18/19 — features like glassEffect, tabBarMinimizeBehavior are 26-only)
   - 8.3 [Update ObservableState from Worklets — Not From the JS Thread](references/state-worklet-writes.md) — MEDIUM (prevents the development-mode warning and ensures atomic same-frame updates on the native side)
   - 8.4 [Use TextFieldRef for Imperative Focus and Selection](references/state-textfield-ref-imperative.md) — MEDIUM (enables focus management, text replacement, and selection control — declarative props can't model these)
   - 8.5 [Use useNativeState for Every Bridged Input Value](references/state-use-native-state-for-fields.md) — MEDIUM (enables zero-bridge text updates and worklet-friendly writes — eliminates per-keystroke JS renders)

---

## References

1. [https://github.com/expo/expo/tree/main/packages/expo-ui](https://github.com/expo/expo/tree/main/packages/expo-ui)
2. [https://docs.expo.dev/versions/latest/sdk/ui/](https://docs.expo.dev/versions/latest/sdk/ui/)
3. [https://developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)
4. [https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
5. [https://developer.apple.com/documentation/swiftui/glasseffectcontainer](https://developer.apple.com/documentation/swiftui/glasseffectcontainer)
6. [https://developer.apple.com/design/human-interface-guidelines/modality](https://developer.apple.com/design/human-interface-guidelines/modality)
7. [https://developer.apple.com/design/human-interface-guidelines/materials](https://developer.apple.com/design/human-interface-guidelines/materials)
8. [https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:)](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:))

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |