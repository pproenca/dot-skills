---
name: uniwind
description: Uniwind best practices for React Native styling with Tailwind CSS. This skill should be used when writing, reviewing, or refactoring React Native code using Uniwind. Triggers on tasks involving Uniwind, className styling, Tailwind in React Native, NativeWind migration, or theming.
---

# Uniwind Best Practices

Comprehensive performance optimization and best practices guide for Uniwind - the fastest Tailwind CSS bindings for React Native. Contains 45+ rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Setting up Uniwind in a new React Native project
- Configuring Metro plugin and CSS entry points
- Building theme systems with CSS variables
- Integrating third-party components with className support
- Creating responsive layouts for mobile and tablet
- Optimizing styling performance
- Migrating from NativeWind to Uniwind

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Build-Time Configuration | CRITICAL | `build-` |
| 2 | Theme Architecture | CRITICAL | `theme-` |
| 3 | Component Integration | HIGH | `comp-` |
| 4 | Responsive Design | HIGH | `resp-` |
| 5 | Performance Optimization | MEDIUM-HIGH | `perf-` |
| 6 | Platform Patterns | MEDIUM | `plat-` |
| 7 | State & Interaction | MEDIUM | `state-` |
| 8 | Migration & Compatibility | LOW-MEDIUM | `compat-` |

## Quick Reference

### 1. Build-Time Configuration (CRITICAL)

- [`build-metro-config`](references/build-metro-config.md) - Configure Metro Plugin with Required Options
- [`build-css-entry`](references/build-css-entry.md) - Place CSS Entry File in App Root Directory
- [`build-typescript-types`](references/build-typescript-types.md) - Configure TypeScript Definition File Location
- [`build-restart-metro`](references/build-restart-metro.md) - Restart Metro After Configuration Changes
- [`build-debug-mode`](references/build-debug-mode.md) - Enable Debug Mode During Development
- [`build-rem-polyfill`](references/build-rem-polyfill.md) - Configure rem Base Value for Design System Consistency

### 2. Theme Architecture (CRITICAL)

- [`theme-css-variables`](references/theme-css-variables.md) - Define Theme Variables with @theme Directive
- [`theme-variant-blocks`](references/theme-variant-blocks.md) - Use @variant Blocks for Theme Definitions
- [`theme-consistent-variables`](references/theme-consistent-variables.md) - Define Identical Variables Across All Themes
- [`theme-custom-registration`](references/theme-custom-registration.md) - Register Custom Themes in Metro Config
- [`theme-oklch-colors`](references/theme-oklch-colors.md) - Use OKLCH Color Space for Perceptual Uniformity
- [`theme-light-dark-function`](references/theme-light-dark-function.md) - Use light-dark() Function for Adaptive Colors
- [`theme-no-provider`](references/theme-no-provider.md) - Remove ThemeProvider Wrapper from App

### 3. Component Integration (HIGH)

- [`comp-with-uniwind`](references/comp-with-uniwind.md) - Use withUniwind for Third-Party Components
- [`comp-module-level`](references/comp-module-level.md) - Define Wrapped Components at Module Level
- [`comp-prop-mapping`](references/comp-prop-mapping.md) - Use Custom Prop Mappings for Non-Style Props
- [`comp-accent-colors`](references/comp-accent-colors.md) - Use accent-* Classes for Color Prop Extraction
- [`comp-reanimated`](references/comp-reanimated.md) - Reanimated Components Work Without withUniwind
- [`comp-custom-css`](references/comp-custom-css.md) - Use Custom CSS Classes for Complex Reusable Styles

### 4. Responsive Design (HIGH)

- [`resp-mobile-first`](references/resp-mobile-first.md) - Design Mobile-First with Progressive Enhancement
- [`resp-limit-breakpoints`](references/resp-limit-breakpoints.md) - Limit Breakpoints to 3-5 for Maintainability
- [`resp-visibility-toggle`](references/resp-visibility-toggle.md) - Use hidden/flex for Responsive Visibility
- [`resp-custom-breakpoints`](references/resp-custom-breakpoints.md) - Define Custom Breakpoints with Semantic Names
- [`resp-responsive-spacing`](references/resp-responsive-spacing.md) - Scale Spacing and Typography Responsively

### 5. Performance Optimization (MEDIUM-HIGH)

- [`perf-static-classnames`](references/perf-static-classnames.md) - Use Complete Static Class Names for Build-Time Resolution
- [`perf-use-resolve-sparingly`](references/perf-use-resolve-sparingly.md) - Use useResolveClassNames Sparingly
- [`perf-memoize-variants`](references/perf-memoize-variants.md) - Memoize Variant Style Objects
- [`perf-tailwind-merge`](references/perf-tailwind-merge.md) - Use tailwind-merge for Class Deduplication
- [`perf-avoid-inline-styles`](references/perf-avoid-inline-styles.md) - Prefer className Over Inline style Prop
- [`perf-combine-styles`](references/perf-combine-styles.md) - Combine className and style Prop Correctly

### 6. Platform Patterns (MEDIUM)

- [`plat-ios-android-selectors`](references/plat-ios-android-selectors.md) - Use Platform Selectors for iOS/Android Differences
- [`plat-safe-area-context`](references/plat-safe-area-context.md) - Use react-native-safe-area-context for Safe Areas
- [`plat-yoga-layout`](references/plat-yoga-layout.md) - Understand Yoga Layout Engine Differences
- [`plat-web-selector`](references/plat-web-selector.md) - Use web: Selector for Cross-Platform Apps
- [`plat-font-families`](references/plat-font-families.md) - Configure Font Families Without Fallbacks

### 7. State & Interaction (MEDIUM)

- [`state-pressable-states`](references/state-pressable-states.md) - Use Pressable with active:/focus:/disabled: States
- [`state-data-selectors`](references/state-data-selectors.md) - Use Data Selectors for Component State Styling
- [`state-no-hover`](references/state-no-hover.md) - Avoid hover: on Native - Use active: Instead
- [`state-group-variants`](references/state-group-variants.md) - Use Group Variants for Parent-Child Styling (WIP)
- [`state-dark-mode`](references/state-dark-mode.md) - Use dark: Variant for Dark Mode Styles

### 8. Migration & Compatibility (LOW-MEDIUM)

- [`compat-nativewind-migration`](references/compat-nativewind-migration.md) - Follow NativeWind Migration Checklist
- [`compat-tailwind-4-syntax`](references/compat-tailwind-4-syntax.md) - Use Tailwind 4 CSS-First Configuration
- [`compat-rem-default`](references/compat-rem-default.md) - Account for Different rem Default Values
- [`compat-cssinterop-replacement`](references/compat-cssinterop-replacement.md) - Replace cssInterop with withUniwind
- [`compat-safe-area-changes`](references/compat-safe-area-changes.md) - Replace *-safe Classes with Safe Area Context

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
