---
name: expo-react-native-performance
description: Expo React Native performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring Expo React Native code to ensure optimal performance patterns. Triggers on tasks involving React Native components, lists, animations, images, or performance improvements.
---

# Expo React Native Performance Best Practices

Comprehensive performance optimization guide for Expo React Native applications. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new React Native components or screens
- Implementing lists with FlatList or FlashList
- Adding animations or transitions
- Optimizing images and asset loading
- Reviewing code for performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | App Startup & Bundle Size | CRITICAL | `startup-` |
| 2 | List Virtualization | CRITICAL | `list-` |
| 3 | Re-render Optimization | HIGH | `rerender-` |
| 4 | Animation Performance | HIGH | `anim-` |
| 5 | Image & Asset Loading | MEDIUM-HIGH | `asset-` |
| 6 | Memory Management | MEDIUM | `mem-` |
| 7 | Async & Data Fetching | MEDIUM | `async-` |
| 8 | Platform Optimizations | LOW-MEDIUM | `platform-` |

## Quick Reference

### 1. App Startup & Bundle Size (CRITICAL)

- [`startup-enable-hermes`](references/startup-enable-hermes.md) - Enable Hermes JavaScript engine
- [`startup-remove-console-logs`](references/startup-remove-console-logs.md) - Remove console logs in production
- [`startup-splash-screen-control`](references/startup-splash-screen-control.md) - Control splash screen visibility
- [`startup-preload-assets`](references/startup-preload-assets.md) - Preload critical assets during splash
- [`startup-async-routes`](references/startup-async-routes.md) - Use async routes for code splitting
- [`startup-cherry-pick-imports`](references/startup-cherry-pick-imports.md) - Use direct imports instead of barrel files

### 2. List Virtualization (CRITICAL)

- [`list-use-flashlist`](references/list-use-flashlist.md) - Use FlashList instead of FlatList
- [`list-estimated-item-size`](references/list-estimated-item-size.md) - Provide accurate estimatedItemSize
- [`list-get-item-type`](references/list-get-item-type.md) - Use getItemType for mixed lists
- [`list-stable-render-item`](references/list-stable-render-item.md) - Stabilize renderItem with useCallback
- [`list-get-item-layout`](references/list-get-item-layout.md) - Provide getItemLayout for fixed heights
- [`list-memoize-items`](references/list-memoize-items.md) - Memoize list item components

### 3. Re-render Optimization (HIGH)

- [`rerender-use-memo-expensive`](references/rerender-use-memo-expensive.md) - Memoize expensive computations
- [`rerender-use-callback-handlers`](references/rerender-use-callback-handlers.md) - Stabilize callbacks with useCallback
- [`rerender-functional-setstate`](references/rerender-functional-setstate.md) - Use functional setState updates
- [`rerender-lazy-state-init`](references/rerender-lazy-state-init.md) - Use lazy state initialization
- [`rerender-split-context`](references/rerender-split-context.md) - Split context by update frequency
- [`rerender-derive-state`](references/rerender-derive-state.md) - Derive state instead of syncing

### 4. Animation Performance (HIGH)

- [`anim-use-native-driver`](references/anim-use-native-driver.md) - Enable native driver for animations
- [`anim-use-reanimated`](references/anim-use-reanimated.md) - Use Reanimated for complex animations
- [`anim-layout-animation`](references/anim-layout-animation.md) - Use LayoutAnimation for simple transitions
- [`anim-transform-not-dimensions`](references/anim-transform-not-dimensions.md) - Animate transform instead of dimensions
- [`anim-interaction-manager`](references/anim-interaction-manager.md) - Defer heavy work during animations

### 5. Image & Asset Loading (MEDIUM-HIGH)

- [`asset-use-expo-image`](references/asset-use-expo-image.md) - Use expo-image for image loading
- [`asset-prefetch-images`](references/asset-prefetch-images.md) - Prefetch images before display
- [`asset-optimize-image-size`](references/asset-optimize-image-size.md) - Request appropriately sized images
- [`asset-use-webp-format`](references/asset-use-webp-format.md) - Use WebP format for images
- [`asset-recycling-key`](references/asset-recycling-key.md) - Use recyclingKey in FlashList images

### 6. Memory Management (MEDIUM)

- [`mem-cleanup-subscriptions`](references/mem-cleanup-subscriptions.md) - Clean up subscriptions in useEffect
- [`mem-clear-timers`](references/mem-clear-timers.md) - Clear timers on unmount
- [`mem-abort-fetch`](references/mem-abort-fetch.md) - Abort fetch requests on unmount
- [`mem-avoid-inline-objects`](references/mem-avoid-inline-objects.md) - Avoid inline objects in props
- [`mem-limit-list-data`](references/mem-limit-list-data.md) - Limit list data in memory

### 7. Async & Data Fetching (MEDIUM)

- [`async-parallel-fetching`](references/async-parallel-fetching.md) - Fetch independent data in parallel
- [`async-defer-await`](references/async-defer-await.md) - Defer await until value needed
- [`async-batch-api-calls`](references/async-batch-api-calls.md) - Batch related API calls
- [`async-cache-responses`](references/async-cache-responses.md) - Cache API responses locally
- [`async-refetch-on-focus`](references/async-refetch-on-focus.md) - Refetch data on screen focus

### 8. Platform Optimizations (LOW-MEDIUM)

- [`platform-android-overdraw`](references/platform-android-overdraw.md) - Reduce Android overdraw
- [`platform-ios-text-rendering`](references/platform-ios-text-rendering.md) - Optimize iOS text rendering
- [`platform-android-proguard`](references/platform-android-proguard.md) - Enable ProGuard for Android release
- [`platform-conditional-render`](references/platform-conditional-render.md) - Platform-specific optimizations

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Full Compiled Document

For the complete guide with all rules expanded, see [AGENTS.md](AGENTS.md).

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
