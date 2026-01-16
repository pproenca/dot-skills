---
name: expo-react-native-best-practices
description: Expo React Native performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring Expo React Native code to ensure optimal performance patterns. Triggers on tasks involving React Native components, navigation, lists, images, animations, bundle optimization, or mobile performance improvements.
---

# Community Expo React Native Best Practices

Comprehensive performance optimization guide for Expo React Native applications. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Expo React Native components
- Optimizing app startup and Time to Interactive
- Implementing lists, images, or animations
- Reducing bundle size and memory usage
- Reviewing code for mobile performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Launch Time Optimization | CRITICAL | `launch-` |
| 2 | Bundle Size Optimization | CRITICAL | `bundle-` |
| 3 | List Virtualization | HIGH | `list-` |
| 4 | Image Optimization | HIGH | `image-` |
| 5 | Navigation Performance | MEDIUM-HIGH | `nav-` |
| 6 | Re-render Prevention | MEDIUM | `rerender-` |
| 7 | Animation Performance | MEDIUM | `anim-` |
| 8 | Memory Management | LOW-MEDIUM | `mem-` |

## Quick Reference

### 1. Launch Time Optimization (CRITICAL)

- `launch-splash-screen-control` - Control splash screen visibility during asset loading
- `launch-preload-critical-assets` - Preload fonts and images during splash
- `launch-hermes-engine` - Use Hermes engine for faster startup
- `launch-defer-non-critical` - Defer non-critical initialization
- `launch-new-architecture` - Enable New Architecture for synchronous native communication
- `launch-minimize-root-imports` - Minimize imports in root App component

### 2. Bundle Size Optimization (CRITICAL)

- `bundle-avoid-barrel-files` - Avoid barrel file imports
- `bundle-analyze-size` - Analyze bundle size before release
- `bundle-remove-unused-dependencies` - Remove unused dependencies
- `bundle-split-by-architecture` - Generate architecture-specific APKs
- `bundle-enable-proguard` - Enable ProGuard for Android release builds
- `bundle-optimize-fonts` - Subset custom fonts to used characters
- `bundle-use-lightweight-alternatives` - Use lightweight library alternatives

### 3. List Virtualization (HIGH)

- `list-use-flashlist` - Use FlashList instead of FlatList
- `list-provide-estimated-size` - Provide accurate estimatedItemSize
- `list-avoid-inline-functions` - Avoid inline functions in renderItem
- `list-provide-getitemlayout` - Provide getItemLayout for fixed-height items
- `list-avoid-key-prop` - Avoid key prop inside FlashList items
- `list-batch-rendering` - Configure list batch rendering
- `list-memoize-item-components` - Memoize list item components

### 4. Image Optimization (HIGH)

- `image-use-expo-image` - Use expo-image instead of React Native Image
- `image-resize-to-display-size` - Resize images to display size
- `image-use-webp-format` - Use WebP format for smaller file sizes
- `image-use-placeholders` - Use BlurHash or ThumbHash placeholders
- `image-preload-critical` - Preload critical above-the-fold images
- `image-lazy-load-offscreen` - Lazy load off-screen images

### 5. Navigation Performance (MEDIUM-HIGH)

- `nav-use-native-stack` - Use native stack navigator
- `nav-unmount-inactive-screens` - Unmount inactive tab screens
- `nav-prefetch-screen-data` - Prefetch data before navigation
- `nav-optimize-screen-options` - Optimize screen options
- `nav-avoid-deep-nesting` - Avoid deeply nested navigators

### 6. Re-render Prevention (MEDIUM)

- `rerender-use-memo-components` - Memoize expensive components with React.memo
- `rerender-use-callback` - Stabilize callbacks with useCallback
- `rerender-use-memo-values` - Memoize expensive computations with useMemo
- `rerender-avoid-context-overuse` - Avoid overusing Context for frequent updates
- `rerender-split-component-state` - Split components to isolate updating state
- `rerender-use-react-compiler` - Enable React Compiler for automatic memoization
- `rerender-avoid-anonymous-components` - Avoid anonymous components in JSX

### 7. Animation Performance (MEDIUM)

- `anim-use-reanimated` - Use Reanimated for UI thread animations
- `anim-use-native-driver` - Enable useNativeDriver for Animated API
- `anim-avoid-layout-animation` - Prefer transform over layout animations
- `anim-gesture-handler-integration` - Use Gesture Handler with Reanimated
- `anim-interaction-manager` - Defer heavy work during animations

### 8. Memory Management (LOW-MEDIUM)

- `mem-cleanup-useeffect` - Clean up subscriptions and timers
- `mem-abort-fetch-requests` - Abort fetch requests on unmount
- `mem-avoid-closure-leaks` - Avoid closure-based memory leaks
- `mem-release-heavy-resources` - Release heavy resources when not needed
- `mem-profile-with-tools` - Profile memory usage with development tools

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/launch-splash-screen-control.md
rules/list-use-flashlist.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
