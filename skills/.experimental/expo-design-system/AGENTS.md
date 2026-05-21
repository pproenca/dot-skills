# Expo React Native design system

**Version 0.1.0**  
Airbnb DLS / React Native Community  
May 2026

> **Note:** This document is for agents and LLMs maintaining, generating, or reviewing Expo React Native design system code. Humans may find it useful, but the guidance is optimized for AI-assisted automation and consistency.

---

## Abstract

Airbnb-DLS-aligned design system engineering for Expo / React Native apps built on Unistyles v3, Reanimated, Skia, and FlashList. Contains 54 rules across 9 categories, prioritized by impact from critical (token architecture, theming, component API contracts) to incremental (governance). Each rule pairs an incorrect and correct TSX example with quantified impact to guide design system code generation and review for a clinic management mobile app with calendar, treatment-note, and body-chart drawing surfaces.

---

## Table of Contents

1. [Token Architecture](references/_sections.md#1-token-architecture) — **CRITICAL**
   - 1.1 [Avoid Abstracting Tokens Beyond Three Layers](references/token-avoid-over-abstraction.md) — MEDIUM (reduces indirection that slows onboarding and review)
   - 1.2 [Avoid Raw Color and Size Literals in Components](references/token-no-raw-values-in-components.md) — CRITICAL (eliminates ungoverned values that drift across screens)
   - 1.3 [Define Every Token in the Unistyles Theme](references/token-define-in-unistyles-theme.md) — CRITICAL (eliminates duplicated token sources across the app)
   - 1.4 [Layer Tokens as Raw, Semantic, and Component Scales](references/token-three-layer-scale.md) — CRITICAL (prevents palette-wide rebrands from touching component code)
   - 1.5 [Name Tokens by Role, Not by Value](references/token-semantic-naming.md) — CRITICAL (prevents rename churn when brand values change)
   - 1.6 [Tokenize Elevation as Surface and Shadow Pairs](references/token-elevation-pairs.md) — HIGH (prevents inconsistent depth across light and dark themes)
2. [Theming & Adaptivity](references/_sections.md#2-theming-&-adaptivity) — **CRITICAL**
   - 2.1 [Drive Tablet Layouts With Breakpoints, Not Dimensions Checks](references/theme-breakpoints-responsive.md) — HIGH (eliminates manual Dimensions branching that breaks on rotation)
   - 2.2 [Follow the System Color Scheme by Default](references/theme-adaptive-system.md) — HIGH (eliminates manual light and dark branching in views)
   - 2.3 [Read Theme Values From the StyleSheet Argument](references/theme-stylesheet-theme-arg.md) — CRITICAL (prevents per-render theme subscriptions and inline style objects)
   - 2.4 [Register Themes and Breakpoints in One Typed Module](references/theme-config-single-module.md) — HIGH (prevents divergent theme definitions and untyped token access)
   - 2.5 [Switch Themes Through the Unistyles Runtime](references/theme-runtime-not-rerender.md) — CRITICAL (prevents a full JavaScript re-render on every theme change)
3. [Component API Contracts](references/_sections.md#3-component-api-contracts) — **CRITICAL**
   - 3.1 [Accept Slot Props for Flexible Composition](references/api-slots-for-composition.md) — HIGH (eliminates a new boolean prop for every content permutation)
   - 3.2 [Avoid Exposing a Raw style Prop on Components](references/api-no-style-escape-hatch.md) — CRITICAL (prevents one-off overrides that bypass design tokens)
   - 3.3 [Bake Accessibility Into the Component Contract](references/api-accessibility-in-contract.md) — HIGH (prevents inaccessible variants from shipping to clinicians)
   - 3.4 [Combine Variant Dimensions With Compound Variants](references/api-compound-variants.md) — CRITICAL (reduces an N by M variant matrix to one component definition)
   - 3.5 [Express Visual Options as Variant Props](references/api-variants-over-style-prop.md) — CRITICAL (prevents unbounded style drift on shared components)
   - 3.6 [Forward Refs From Every Leaf Component](references/api-forward-ref.md) — HIGH (preserves focus and measurement access for callers)
   - 3.7 [Offer asChild Polymorphism Instead of Wrapper Nesting](references/api-aschild-polymorphism.md) — MEDIUM (eliminates redundant wrapper nodes and duplicate press targets)
   - 3.8 [Support Both Controlled and Uncontrolled State](references/api-controlled-uncontrolled.md) — HIGH (prevents duplicate state wiring at every call site)
4. [Styling Engine — Unistyles](references/_sections.md#4-styling-engine-—-unistyles) — **HIGH**
   - 4.1 [Avoid Merging Styles With Inline Arrays in Lists](references/style-no-inline-array-merge.md) — HIGH (prevents per-row array and object allocation in long lists)
   - 4.2 [Define Styles With StyleSheet.create, Not Inline Objects](references/style-stylesheet-create.md) — HIGH (prevents a new style object on every render)
   - 4.3 [Drive Press and Disabled States From Variants](references/style-press-states-from-variants.md) — MEDIUM (eliminates duplicated Pressable style callbacks across buttons)
   - 4.4 [Implement Component Variants With the Variants API](references/style-variants-api.md) — HIGH (reduces conditional style branching to declarative variants)
   - 4.5 [Use Dynamic Functions for Per-Instance Style Values](references/style-dynamic-functions.md) — HIGH (avoids inline style objects for prop-driven values)
   - 4.6 [Wrap Third-Party Components With withUnistyles](references/style-withunistyles-third-party.md) — MEDIUM (preserves token theming for external components on theme change)
5. [Typography & Iconography](references/_sections.md#5-typography-&-iconography) — **HIGH**
   - 5.1 [Centralize Icons in a Typed Icon Registry](references/type-icon-registry.md) — MEDIUM (prevents inconsistent icon glyphs, sizes, and colors)
   - 5.2 [Define a Typography Scale as Named Tokens](references/type-scale-tokens.md) — HIGH (prevents arbitrary fontSize values across screens)
   - 5.3 [Load Custom Fonts With expo-font Before First Paint](references/type-font-loading-expo-font.md) — MEDIUM (prevents a font flash on first render)
   - 5.4 [Respect OS Font Scaling in the Type Scale](references/type-respect-font-scaling.md) — HIGH (prevents clipped text at large accessibility font sizes)
   - 5.5 [Route All Text Through One Typed Text Component](references/type-text-component-wrapper.md) — HIGH (eliminates raw Text styling at call sites)
6. [Spacing, Layout & Safe Areas](references/_sections.md#6-spacing,-layout-&-safe-areas) — **HIGH**
   - 6.1 [Apply Safe-Area Insets at Screen Boundaries](references/space-safe-area-insets.md) — HIGH (prevents content under notches and the home indicator)
   - 6.2 [Lay Out Stacks With Gap, Not Per-Child Margins](references/space-gap-over-margins.md) — MEDIUM (eliminates stray trailing space from the last child in a stack)
   - 6.3 [Size Interactive Targets to at Least 44 Points](references/space-touch-targets.md) — HIGH (prevents mis-taps on undersized controls)
   - 6.4 [Tokenize Corner Radius by Component Role](references/space-radius-tokens.md) — MEDIUM (prevents inconsistent rounding across surfaces)
   - 6.5 [Use a Spacing Scale Instead of Ad-Hoc Numbers](references/space-spacing-scale.md) — HIGH (eliminates ad-hoc padding values across screens)
7. [Native-Feel & Performance](references/_sections.md#7-native-feel-&-performance) — **HIGH**
   - 7.1 [Add Haptic Feedback to Confirmations and Toggles](references/perf-haptics-key-actions.md) — LOW-MEDIUM (maintains a native-feel response on consequential actions)
   - 7.2 [Animate on the UI Thread With Reanimated Worklets](references/perf-reanimated-ui-thread.md) — HIGH (maintains 60-120fps during gestures and transitions)
   - 7.3 [Defer Off-Screen Work Until After Transitions](references/perf-defer-offscreen-work.md) — MEDIUM (prevents dropped frames during navigation transitions)
   - 7.4 [Handle Gestures With Gesture Handler, Not PanResponder](references/perf-gesture-handler.md) — HIGH (prevents touch handling from blocking the JavaScript thread)
   - 7.5 [Load Remote Images With expo-image and Caching](references/perf-expo-image.md) — MEDIUM (prevents redundant network fetches and decode jank)
   - 7.6 [Memoize List Item Components and Callbacks](references/perf-memoize-list-items.md) — HIGH (prevents re-rendering every visible row on parent updates)
   - 7.7 [Render Long Lists With FlashList, Not ScrollView](references/perf-flashlist-for-lists.md) — HIGH (prevents mounting every off-screen row at once)
8. [Complex Domain Components](references/_sections.md#8-complex-domain-components) — **MEDIUM-HIGH**
   - 8.1 [Capture Drawing Strokes With Gestures and Shared Values](references/domain-bodychart-gesture-paths.md) — MEDIUM (avoids a React state update per touch point)
   - 8.2 [Compose Domain Components From Design System Primitives](references/domain-compose-from-primitives.md) — MEDIUM (prevents domain screens from re-implementing tokens)
   - 8.3 [Draw Body-Chart Annotations on a Skia Canvas](references/domain-bodychart-skia-canvas.md) — MEDIUM-HIGH (maintains 60fps freehand drawing off the JavaScript thread)
   - 8.4 [Persist Treatment-Note Edits Offline-First With Debounce](references/domain-note-editor-autosave.md) — MEDIUM-HIGH (prevents data loss when the app is suspended mid-note)
   - 8.5 [Render Optimistic UI for Appointment and Note Writes](references/domain-optimistic-writes.md) — MEDIUM (maintains responsiveness while a write syncs to the server)
   - 8.6 [Virtualize the Appointment Calendar by Day](references/domain-calendar-virtualization.md) — MEDIUM-HIGH (prevents rendering a full month of time slots at once)
9. [Governance & Consistency](references/_sections.md#9-governance-&-consistency) — **MEDIUM**
   - 9.1 [Catalog Every Component Variant in Storybook](references/govern-storybook-catalog.md) — MEDIUM (prevents undocumented variants from drifting unnoticed)
   - 9.2 [Enforce One Naming Convention for Tokens and Components](references/govern-naming-conventions.md) — MEDIUM (reduces ambiguity and guesswork when looking up tokens)
   - 9.3 [Isolate the Design System as Its Own Package](references/govern-design-system-package.md) — MEDIUM (prevents feature code from importing private internals)
   - 9.4 [Lint Against Raw Colors and Inline Styles](references/govern-lint-no-raw-values.md) — MEDIUM (prevents ungoverned values from merging into the codebase)
   - 9.5 [Migrate Ad-Hoc Styles to Tokens Incrementally](references/govern-incremental-migration.md) — MEDIUM (prevents a big-bang refactor that stalls feature work)
   - 9.6 [Prevent Feature Modules From Defining Local Tokens](references/govern-prevent-local-tokens.md) — MEDIUM (eliminates shadow token systems inside features)

---

## References

1. [https://www.unistyl.es/v3/start/introduction](https://www.unistyl.es/v3/start/introduction)
2. [https://www.unistyl.es/v3/guides/theming/](https://www.unistyl.es/v3/guides/theming/)
3. [https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
4. [https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
5. [https://docs.swmansion.com/react-native-gesture-handler/](https://docs.swmansion.com/react-native-gesture-handler/)
6. [https://shopify.github.io/react-native-skia/](https://shopify.github.io/react-native-skia/)
7. [https://shopify.github.io/flash-list/](https://shopify.github.io/flash-list/)
8. [https://docs.expo.dev/router/introduction/](https://docs.expo.dev/router/introduction/)
9. [https://docs.expo.dev/versions/latest/sdk/image/](https://docs.expo.dev/versions/latest/sdk/image/)
10. [https://reactnative.dev/docs/accessibility](https://reactnative.dev/docs/accessibility)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |