---
name: react-native-expo-best-practices
description: React Native with Expo performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring React Native/Expo code to ensure optimal performance patterns. Triggers on tasks involving FlatList, navigation, animations, data fetching, or mobile app performance.
---

# React Native Expo Best Practices

Comprehensive performance optimization guide for React Native applications built with Expo, designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new React Native/Expo components
- Optimizing FlatList or list rendering performance
- Implementing navigation and screen transitions
- Adding animations with Reanimated
- Setting up data fetching and caching
- Reviewing code for performance issues
- Debugging frame drops or memory issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | App Startup Optimization | CRITICAL | `launch-` |
| 2 | Bundle Size & Dependencies | CRITICAL | `bundle-` |
| 3 | List Virtualization | CRITICAL | `list-` |
| 4 | Navigation & Routing | HIGH | `nav-` |
| 5 | Data Fetching Patterns | HIGH | `data-` |
| 6 | Re-render Prevention | MEDIUM | `render-` |
| 7 | Animation Performance | MEDIUM | `anim-` |
| 8 | Memory & Resource Management | LOW-MEDIUM | `mem-` |

## Quick Reference

### 1. App Startup Optimization (CRITICAL)

- [`launch-hermes-bytecode`](references/launch-hermes-bytecode.md) - Enable Hermes with Bytecode Compilation
- [`launch-dev-mode-testing`](references/launch-dev-mode-testing.md) - Disable Development Mode for Performance Testing
- [`launch-splash-screen`](references/launch-splash-screen.md) - Configure Splash Screen to Hide After Content Ready
- [`launch-minimize-root-imports`](references/launch-minimize-root-imports.md) - Minimize Root-Level Imports
- [`launch-font-loading`](references/launch-font-loading.md) - Load Fonts Before Rendering Text
- [`launch-avoid-sync-storage`](references/launch-avoid-sync-storage.md) - Avoid Synchronous Storage Reads at Startup

### 2. Bundle Size & Dependencies (CRITICAL)

- [`bundle-direct-imports`](references/bundle-direct-imports.md) - Use Direct Module Imports Instead of Barrel Files
- [`bundle-analyze-dependencies`](references/bundle-analyze-dependencies.md) - Analyze Bundle Size Before Adding Dependencies
- [`bundle-dynamic-imports`](references/bundle-dynamic-imports.md) - Use Dynamic Imports for Large Features
- [`bundle-avoid-polyfills`](references/bundle-avoid-polyfills.md) - Avoid Unnecessary Polyfills
- [`bundle-image-assets`](references/bundle-image-assets.md) - Optimize Image Assets for Bundle Size

### 3. List Virtualization (CRITICAL)

- [`list-use-flashlist`](references/list-use-flashlist.md) - Use FlashList Instead of FlatList for Large Lists
- [`list-getitemlayout`](references/list-getitemlayout.md) - Implement getItemLayout for Fixed-Height Items
- [`list-stable-keys`](references/list-stable-keys.md) - Use Stable Keys Instead of Array Index
- [`list-memoize-renderitem`](references/list-memoize-renderitem.md) - Memoize renderItem and List Item Components
- [`list-window-size`](references/list-window-size.md) - Tune windowSize for Memory vs Performance
- [`list-avoid-inline-styles`](references/list-avoid-inline-styles.md) - Avoid Inline Styles in List Items
- [`list-remove-clipped-subviews`](references/list-remove-clipped-subviews.md) - Enable removeClippedSubviews for Long Lists

### 4. Navigation & Routing (HIGH)

- [`nav-async-routes`](references/nav-async-routes.md) - Enable Async Routes for Lazy Screen Loading
- [`nav-avoid-usenavigation-rerenders`](references/nav-avoid-usenavigation-rerenders.md) - Avoid useNavigation Re-render Issues
- [`nav-alphabetical-loading`](references/nav-alphabetical-loading.md) - Control Route Loading Order with Naming
- [`nav-preload-screens`](references/nav-preload-screens.md) - Preload Screens Before Navigation
- [`nav-deep-link-performance`](references/nav-deep-link-performance.md) - Optimize Deep Link Resolution

### 5. Data Fetching Patterns (HIGH)

- [`data-parallel-fetching`](references/data-parallel-fetching.md) - Fetch Independent Data in Parallel
- [`data-request-deduplication`](references/data-request-deduplication.md) - Deduplicate Concurrent Requests
- [`data-abort-requests`](references/data-abort-requests.md) - Abort Requests on Component Unmount
- [`data-optimistic-updates`](references/data-optimistic-updates.md) - Use Optimistic Updates for Instant Feedback
- [`data-pagination`](references/data-pagination.md) - Implement Efficient Pagination for Large Datasets
- [`data-cache-strategies`](references/data-cache-strategies.md) - Configure Appropriate Cache Strategies

### 6. Re-render Prevention (MEDIUM)

- [`render-memo-components`](references/render-memo-components.md) - Wrap Expensive Components with memo()
- [`render-usememo-expensive`](references/render-usememo-expensive.md) - Memoize Expensive Computations with useMemo
- [`render-usecallback-handlers`](references/render-usecallback-handlers.md) - Stabilize Event Handlers with useCallback
- [`render-context-splitting`](references/render-context-splitting.md) - Split Context to Prevent Unnecessary Re-renders
- [`render-avoid-anonymous-functions`](references/render-avoid-anonymous-functions.md) - Avoid Anonymous Functions in JSX
- [`render-react-compiler`](references/render-react-compiler.md) - Enable React Compiler for Automatic Memoization

### 7. Animation Performance (MEDIUM)

- [`anim-use-reanimated`](references/anim-use-reanimated.md) - Use Reanimated for 60 FPS Animations
- [`anim-worklets`](references/anim-worklets.md) - Use Worklets for UI Thread Computation
- [`anim-layout-animations`](references/anim-layout-animations.md) - Use Layout Animations for Mount/Unmount
- [`anim-avoid-js-thread`](references/anim-avoid-js-thread.md) - Avoid JS Thread During Animations
- [`anim-limit-concurrent`](references/anim-limit-concurrent.md) - Limit Concurrent Animations

### 8. Memory & Resource Management (LOW-MEDIUM)

- [`mem-useeffect-cleanup`](references/mem-useeffect-cleanup.md) - Clean Up Resources in useEffect
- [`mem-expo-image`](references/mem-expo-image.md) - Use expo-image for Efficient Image Caching
- [`mem-avoid-closures-leaks`](references/mem-avoid-closures-leaks.md) - Avoid Closure Memory Leaks
- [`mem-monitor-memory`](references/mem-monitor-memory.md) - Monitor Memory Usage in Development
- [`mem-lazy-components`](references/mem-lazy-components.md) - Lazy Load Heavy Components

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
