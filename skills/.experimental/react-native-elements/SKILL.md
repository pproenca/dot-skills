---
name: react-native-elements
description: React Native Elements UI component library best practices for performance, theming, and proper component usage. Use when building React Native apps with RNE, configuring themes, optimizing lists with ListItem, or reviewing RNE component code.
---

# Community React Native Elements Best Practices

Comprehensive best practices guide for React Native Elements applications. Contains 45 rules across 8 categories, prioritized by impact to guide component usage, theming, and performance optimization.

## When to Apply

Reference these guidelines when:
- Setting up React Native Elements in a new project
- Configuring ThemeProvider and createTheme
- Building lists with ListItem components
- Implementing form inputs with Input and SearchBar
- Optimizing FlatList performance with RNE components
- Reviewing code using React Native Elements

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Import & Setup | CRITICAL | `setup-` |
| 2 | Theme Architecture | CRITICAL | `theme-` |
| 3 | Component Selection | HIGH | `comp-` |
| 4 | List Performance | HIGH | `list-` |
| 5 | Props & Configuration | MEDIUM-HIGH | `props-` |
| 6 | Styling Patterns | MEDIUM | `style-` |
| 7 | Callbacks & Events | MEDIUM | `event-` |
| 8 | Advanced Patterns | LOW | `adv-` |

## Quick Reference

### 1. Import & Setup (CRITICAL)

- [`setup-themeprovider`](references/setup-themeprovider.md) - Wrap app with ThemeProvider for consistent theming
- [`setup-imports`](references/setup-imports.md) - Use @rneui/themed vs @rneui/base correctly
- [`setup-createtheme`](references/setup-createtheme.md) - Type-safe theme configuration with createTheme
- [`setup-tree-shaking`](references/setup-tree-shaking.md) - Enable proper tree-shaking for bundle size
- [`setup-safe-area`](references/setup-safe-area.md) - Configure SafeAreaProvider for notched devices

### 2. Theme Architecture (CRITICAL)

- [`theme-usetheme-hook`](references/theme-usetheme-hook.md) - Access theme reactively with useTheme
- [`theme-dark-mode`](references/theme-dark-mode.md) - Configure light/dark mode with createTheme
- [`theme-component-defaults`](references/theme-component-defaults.md) - Set component defaults in theme
- [`theme-updatetheme`](references/theme-updatetheme.md) - Runtime theme updates without remount
- [`theme-color-scheme`](references/theme-color-scheme.md) - Sync with system color scheme
- [`theme-custom-colors`](references/theme-custom-colors.md) - Extend theme with custom colors safely

### 3. Component Selection (HIGH)

- [`comp-listitem-over-view`](references/comp-listitem-over-view.md) - Use ListItem for list rows
- [`comp-input-over-textinput`](references/comp-input-over-textinput.md) - Use Input for form fields
- [`comp-searchbar-platform`](references/comp-searchbar-platform.md) - Platform-specific SearchBar variants
- [`comp-button-type`](references/comp-button-type.md) - Use Button type prop for variants
- [`comp-icon-source`](references/comp-icon-source.md) - Choose Icon type wisely for bundle size
- [`comp-avatar-vs-image`](references/comp-avatar-vs-image.md) - Use Avatar for profile images

### 4. List Performance (HIGH)

- [`list-memo-items`](references/list-memo-items.md) - Memoize ListItem in FlatList
- [`list-keyextractor`](references/list-keyextractor.md) - Always provide keyExtractor
- [`list-getitemlayout`](references/list-getitemlayout.md) - Use getItemLayout for fixed heights
- [`list-renderitem-callback`](references/list-renderitem-callback.md) - Extract renderItem with useCallback
- [`list-windowsize`](references/list-windowsize.md) - Configure windowSize for memory balance
- [`list-virtualized`](references/list-virtualized.md) - Use FlatList over ScrollView
- [`list-removeClipped`](references/list-removeClipped.md) - Configure removeClippedSubviews carefully

### 5. Props & Configuration (MEDIUM-HIGH)

- [`props-loading-state`](references/props-loading-state.md) - Use loading prop for async operations
- [`props-disabled-styling`](references/props-disabled-styling.md) - Configure disabledStyle for feedback
- [`props-input-validation`](references/props-input-validation.md) - Use errorMessage for validation
- [`props-icon-configuration`](references/props-icon-configuration.md) - Configure Icon props correctly
- [`props-searchbar-loading`](references/props-searchbar-loading.md) - Show loading state in SearchBar
- [`props-button-color`](references/props-button-color.md) - Use color prop for semantic colors

### 6. Styling Patterns (MEDIUM)

- [`style-stylesheet`](references/style-stylesheet.md) - Use StyleSheet.create over inline objects
- [`style-containerStyle`](references/style-containerStyle.md) - Use containerStyle for wrappers
- [`style-usememo-dynamic`](references/style-usememo-dynamic.md) - Memoize dynamic styles
- [`style-theme-colors`](references/style-theme-colors.md) - Use theme colors over hardcoded values
- [`style-component-props`](references/style-component-props.md) - Prefer component-specific style props

### 7. Callbacks & Events (MEDIUM)

- [`event-usecallback`](references/event-usecallback.md) - Wrap handlers in useCallback
- [`event-debounce-search`](references/event-debounce-search.md) - Debounce SearchBar onChangeText
- [`event-listitem-onpress`](references/event-listitem-onpress.md) - Pass item data correctly
- [`event-avoid-anonymous`](references/event-avoid-anonymous.md) - Avoid anonymous functions in renders
- [`event-input-handlers`](references/event-input-handlers.md) - Configure Input handlers efficiently

### 8. Advanced Patterns (LOW)

- [`adv-custom-component`](references/adv-custom-component.md) - Wrap RNE components correctly
- [`adv-platform-specific`](references/adv-platform-specific.md) - Handle platform-specific props
- [`adv-makeStyles`](references/adv-makeStyles.md) - Use makeStyles for theme-aware styles
- [`adv-overlay-modal`](references/adv-overlay-modal.md) - Choose Overlay vs Modal correctly
- [`adv-image-component`](references/adv-image-component.md) - Configure Avatar ImageComponent for caching

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
