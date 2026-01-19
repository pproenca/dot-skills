# Expo React Native

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Expo React Native applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (launch time, bundle size) to incremental (memory management). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Launch Time Optimization](references/_sections.md#1-launch-time-optimization) — **CRITICAL**
   - 1.1 [Control Splash Screen Visibility During Asset Loading](references/launch-splash-screen-control.md) — CRITICAL (prevents white flash and improves perceived startup time)
   - 1.2 [Defer Non-Critical Initialization Until After First Render](references/launch-defer-non-critical.md) — CRITICAL (reduces Time to Interactive by 200-500ms)
   - 1.3 [Enable New Architecture for Synchronous Native Communication](references/launch-new-architecture.md) — CRITICAL (significant startup improvement, eliminates bridge serialization overhead)
   - 1.4 [Minimize Imports in Root App Component](references/launch-minimize-root-imports.md) — HIGH (reduces initial bundle parse time by 100-300ms)
   - 1.5 [Preload Critical Assets During Splash Screen](references/launch-preload-critical-assets.md) — CRITICAL (eliminates asset loading delays after app renders)
   - 1.6 [Use Hermes Engine for Faster Startup](references/launch-hermes-engine.md) — CRITICAL (30-50% faster startup time, reduced memory usage)
2. [Bundle Size Optimization](references/_sections.md#2-bundle-size-optimization) — **CRITICAL**
   - 2.1 [Analyze Bundle Size Before Release](references/bundle-analyze-size.md) — CRITICAL (identifies 30-70% of bundle bloat from unused dependencies)
   - 2.2 [Avoid Barrel File Imports](references/bundle-avoid-barrel-files.md) — CRITICAL (200-800ms bundle parse reduction, smaller memory footprint)
   - 2.3 [Enable ProGuard for Android Release Builds](references/bundle-enable-proguard.md) — HIGH (10-30% smaller APK, removes unused Java/Kotlin code)
   - 2.4 [Generate Architecture-Specific APKs](references/bundle-split-by-architecture.md) — HIGH (30-50% smaller APK download size)
   - 2.5 [Remove Unused Dependencies](references/bundle-remove-unused-dependencies.md) — CRITICAL (100-500KB reduction per removed library)
   - 2.6 [Subset Custom Fonts to Used Characters](references/bundle-optimize-fonts.md) — MEDIUM-HIGH (50-90% font file size reduction)
   - 2.7 [Use Lightweight Library Alternatives](references/bundle-use-lightweight-alternatives.md) — HIGH (50-200KB savings per replaced library)
3. [List Virtualization](references/_sections.md#3-list-virtualization) — **HIGH**
   - 3.1 [Avoid Inline Functions in List renderItem](references/list-avoid-inline-functions.md) — HIGH (prevents component recreation on every render)
   - 3.2 [Avoid key Prop Inside FlashList Items](references/list-avoid-key-prop.md) — HIGH (preserves cell recycling, prevents performance degradation)
   - 3.3 [Configure List Batch Rendering for Scroll Performance](references/list-batch-rendering.md) — MEDIUM-HIGH (reduces blank areas during fast scrolling)
   - 3.4 [Memoize List Item Components](references/list-memoize-item-components.md) — HIGH (prevents re-render of all items when list data changes)
   - 3.5 [Provide Accurate estimatedItemSize for FlashList](references/list-provide-estimated-size.md) — HIGH (eliminates layout recalculation, smoother initial render)
   - 3.6 [Provide getItemLayout for Fixed-Height FlatList Items](references/list-provide-getitemlayout.md) — HIGH (eliminates async layout measurement, instant scroll-to-index)
   - 3.7 [Use FlashList Instead of FlatList for Large Lists](references/list-use-flashlist.md) — HIGH (54% FPS improvement, 82% CPU reduction via cell recycling)
4. [Image Optimization](references/_sections.md#4-image-optimization) — **HIGH**
   - 4.1 [Lazy Load Off-Screen Images](references/image-lazy-load-offscreen.md) — MEDIUM-HIGH (reduces initial memory footprint and network requests)
   - 4.2 [Preload Critical Above-the-Fold Images](references/image-preload-critical.md) — MEDIUM-HIGH (eliminates loading delay for first visible images)
   - 4.3 [Resize Images to Display Size](references/image-resize-to-display-size.md) — HIGH (50-90% memory reduction for oversized images)
   - 4.4 [Use BlurHash or ThumbHash Placeholders](references/image-use-placeholders.md) — MEDIUM-HIGH (eliminates layout shift, improves perceived loading speed)
   - 4.5 [Use expo-image Instead of React Native Image](references/image-use-expo-image.md) — HIGH (built-in caching, memory optimization, faster loading)
   - 4.6 [Use WebP Format for Smaller File Sizes](references/image-use-webp-format.md) — HIGH (25-35% smaller than JPEG, 26% smaller than PNG)
5. [Navigation Performance](references/_sections.md#5-navigation-performance) — **MEDIUM-HIGH**
   - 5.1 [Avoid Deeply Nested Navigators](references/nav-avoid-deep-nesting.md) — MEDIUM (reduces navigation complexity and memory overhead)
   - 5.2 [Optimize Screen Options to Reduce Navigation Overhead](references/nav-optimize-screen-options.md) — MEDIUM (reduces header recalculation and re-renders)
   - 5.3 [Prefetch Data Before Navigation](references/nav-prefetch-screen-data.md) — MEDIUM-HIGH (eliminates loading state on destination screen)
   - 5.4 [Unmount Inactive Tab Screens to Save Memory](references/nav-unmount-inactive-screens.md) — MEDIUM-HIGH (reduces memory footprint by releasing inactive screen resources)
   - 5.5 [Use Native Stack Navigator for Performance](references/nav-use-native-stack.md) — MEDIUM-HIGH (2× smoother transitions, 30% lower memory per screen)
6. [Re-render Prevention](references/_sections.md#6-re-render-prevention) — **MEDIUM**
   - 6.1 [Avoid Anonymous Components in JSX](references/rerender-avoid-anonymous-components.md) — MEDIUM (prevents component unmount/remount on every parent render)
   - 6.2 [Avoid Overusing Context for Frequently Changing State](references/rerender-avoid-context-overuse.md) — MEDIUM (prevents global re-renders from state updates)
   - 6.3 [Enable React Compiler for Automatic Memoization](references/rerender-use-react-compiler.md) — MEDIUM (automatic useMemo/useCallback insertion, reduced manual optimization)
   - 6.4 [Memoize Expensive Components with React.memo](references/rerender-use-memo-components.md) — MEDIUM (prevents cascading re-renders from parent updates)
   - 6.5 [Memoize Expensive Computations with useMemo](references/rerender-use-memo-values.md) — MEDIUM (prevents redundant calculations on every render)
   - 6.6 [Split Components to Isolate Frequently Updating State](references/rerender-split-component-state.md) — MEDIUM (reduces re-render scope from N components to 1-3)
   - 6.7 [Stabilize Callbacks with useCallback](references/rerender-use-callback.md) — MEDIUM (prevents child re-renders from callback recreation)
7. [Animation Performance](references/_sections.md#7-animation-performance) — **MEDIUM**
   - 7.1 [Defer Heavy Work During Animations with InteractionManager](references/anim-interaction-manager.md) — MEDIUM (maintains 60fps by deferring 100-500ms of JS work)
   - 7.2 [Enable useNativeDriver for Animated API](references/anim-use-native-driver.md) — MEDIUM (offloads animation to native thread, prevents JS thread blocking)
   - 7.3 [Prefer Transform Animations Over Layout Animations](references/anim-avoid-layout-animation.md) — MEDIUM (avoids layout recalculation on every frame)
   - 7.4 [Use Gesture Handler with Reanimated for Gesture-Driven Animations](references/anim-gesture-handler-integration.md) — MEDIUM (2-5× smoother gesture response via native thread execution)
   - 7.5 [Use Reanimated for UI Thread Animations](references/anim-use-reanimated.md) — MEDIUM (consistent 60fps vs 30-45fps with JS thread animations)
8. [Memory Management](references/_sections.md#8-memory-management) — **LOW-MEDIUM**
   - 8.1 [Abort Fetch Requests on Component Unmount](references/mem-abort-fetch-requests.md) — LOW-MEDIUM (prevents state updates on unmounted components)
   - 8.2 [Avoid Closure-Based Memory Leaks in Callbacks](references/mem-avoid-closure-leaks.md) — LOW-MEDIUM (prevents retained references to unmounted component state)
   - 8.3 [Clean Up Subscriptions and Timers in useEffect](references/mem-cleanup-useeffect.md) — LOW-MEDIUM (prevents memory leaks from orphaned listeners and timers)
   - 8.4 [Profile Memory Usage with Development Tools](references/mem-profile-with-tools.md) — LOW-MEDIUM (prevents 10-100MB memory leaks from reaching production)
   - 8.5 [Release Heavy Resources When Not Needed](references/mem-release-heavy-resources.md) — LOW-MEDIUM (50-200MB memory freed when releasing camera/video/maps)

---

## References

1. [https://reactnative.dev/docs/performance](https://reactnative.dev/docs/performance)
2. [https://docs.expo.dev](https://docs.expo.dev)
3. [https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps](https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps)
4. [https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization](https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization)
5. [https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
6. [https://shopify.github.io/flash-list/](https://shopify.github.io/flash-list/)
7. [https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here](https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |