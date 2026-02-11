# React

**Version 0.1.0**  
React Optimise Best Practices  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Application-level performance optimization guide for React applications. Contains 43 rules across 8 categories covering React Compiler mastery, bundle optimization, rendering performance, data fetching, Core Web Vitals, state subscriptions, profiling, and memory management. Complements the react skill (API-level patterns) with holistic performance strategies.

---

## Table of Contents

1. [React Compiler Mastery](references/_sections.md#1-react-compiler-mastery) — **CRITICAL**
   - 1.1 [Detect and Fix Silent Compiler Bailouts](references/compiler-silent-bailouts.md) — CRITICAL (prevents losing automatic memoization on affected components)
   - 1.2 [Isolate Side Effects from Render for Compiler Correctness](references/compiler-side-effect-rules.md) — CRITICAL (prevents compiler from producing incorrect cached output)
   - 1.3 [Remove Manual Memoization After Compiler Adoption](references/compiler-remove-manual-memo.md) — CRITICAL (20-40% code reduction in component files)
   - 1.4 [Use Incremental Compiler Adoption with Directives](references/compiler-incremental-adoption.md) — CRITICAL (enables safe rollout without full codebase migration)
   - 1.5 [Use Ref Access Patterns That Enable Compilation](references/compiler-ref-access-patterns.md) — CRITICAL (maintains compiler optimization for ref-using components)
   - 1.6 [Write Compiler-Friendly Component Patterns](references/compiler-friendly-code.md) — CRITICAL (2-10× automatic render optimization)
2. [Bundle & Loading](references/_sections.md#2-bundle-&-loading) — **CRITICAL**
   - 2.1 [Configure Dependencies for Effective Tree Shaking](references/bundle-tree-shake-deps.md) — CRITICAL (50-90% dead code elimination in dependencies)
   - 2.2 [Eliminate Barrel Files to Enable Tree Shaking](references/bundle-barrel-elimination.md) — CRITICAL (200-800ms import cost eliminated)
   - 2.3 [Enforce Bundle Size Budgets with Analysis Tools](references/bundle-analyze-budgets.md) — CRITICAL (prevents gradual bundle size regression)
   - 2.4 [Prefetch Likely Next Routes on Interaction](references/bundle-prefetch-routes.md) — CRITICAL (200-1000ms faster perceived navigation)
   - 2.5 [Split Code at Route Boundaries with React.lazy](references/bundle-route-splitting.md) — CRITICAL (40-70% reduction in initial bundle size)
   - 2.6 [Use Dynamic Imports for Heavy Libraries](references/bundle-dynamic-imports.md) — CRITICAL (100-500KB removed from critical path)
3. [Rendering Optimization](references/_sections.md#3-rendering-optimization) — **HIGH**
   - 3.1 [Avoid Inline Object Creation in JSX Props](references/render-avoid-inline-objects.md) — HIGH (prevents unnecessary child re-renders, improves memo effectiveness)
   - 3.2 [Debounce Expensive Derived Computations](references/render-debounce-expensive.md) — HIGH (50-200ms saved per keystroke in search/filter UIs)
   - 3.3 [Use Children Pattern to Prevent Parent Re-Renders](references/render-children-pattern.md) — HIGH (eliminates re-renders of static subtrees during parent state changes)
   - 3.4 [Use CSS Containment to Isolate Layout Recalculation](references/render-css-containment.md) — HIGH (reduces layout recalculation scope by 60-90%)
   - 3.5 [Use Stable Keys for List Rendering Performance](references/render-key-stability.md) — HIGH (O(n) DOM mutations reduced to O(1) moves)
   - 3.6 [Virtualize Long Lists with TanStack Virtual](references/render-virtualize-lists.md) — HIGH (O(n) to O(1) DOM nodes, 10-100x improvement for large lists)
4. [Data Fetching Performance](references/_sections.md#4-data-fetching-performance) — **HIGH**
   - 4.1 [Abort Stale Requests on Navigation or Re-fetch](references/fetch-abort-stale.md) — HIGH (prevents stale data display, eliminates race conditions)
   - 4.2 [Deduplicate Identical In-Flight Requests](references/fetch-request-deduplication.md) — HIGH (reduces network requests by 50-80% in component-heavy pages)
   - 4.3 [Eliminate Sequential Data Fetch Waterfalls](references/fetch-eliminate-waterfalls.md) — HIGH (2-5x faster page loads by parallelizing requests)
   - 4.4 [Preload Data at Route Level Before Component Mounts](references/fetch-route-preloading.md) — HIGH (200-1000ms eliminated by starting fetch before render)
   - 4.5 [Use Stale-While-Revalidate for Cache Freshness](references/fetch-stale-while-revalidate.md) — HIGH (0ms perceived load time for returning visitors)
5. [Core Web Vitals](references/_sections.md#5-core-web-vitals) — **MEDIUM-HIGH**
   - 5.1 [Instrument Real User Monitoring with web-vitals](references/cwv-instrumentation.md) — HIGH (enables data-driven optimization targeting real bottlenecks)
   - 5.2 [Optimize Images with Responsive Sizing and Lazy Loading](references/cwv-image-optimization.md) — HIGH (40-70% image bandwidth reduction)
   - 5.3 [Optimize Interaction to Next Paint with Yielding](references/cwv-inp-optimization.md) — HIGH (reduces INP from 500ms+ to under 200ms)
   - 5.4 [Optimize Largest Contentful Paint with Priority Loading](references/cwv-lcp-optimization.md) — HIGH (200-1000ms LCP improvement)
   - 5.5 [Prevent Cumulative Layout Shift with Size Reservations](references/cwv-cls-prevention.md) — HIGH (CLS reduced from 0.25+ to under 0.1)
6. [State & Subscription Performance](references/_sections.md#6-state-&-subscription-performance) — **MEDIUM-HIGH**
   - 6.1 [Derive State Instead of Syncing for Zero Extra Renders](references/sub-derived-state-perf.md) — MEDIUM-HIGH (eliminates double-render cycle, 1 render instead of 2 per update)
   - 6.2 [Separate Server State from Client State Management](references/sub-server-client-separation.md) — MEDIUM-HIGH (eliminates manual cache invalidation, reduces state management code by 40%)
   - 6.3 [Split Contexts to Isolate High-Frequency Updates](references/sub-context-splitting.md) — MEDIUM-HIGH (5-50× fewer re-renders for low-frequency consumers)
   - 6.4 [Use Atomic State for Independent Reactive Values](references/sub-atomic-state.md) — MEDIUM-HIGH (3-10× fewer unnecessary re-renders in complex dashboards)
   - 6.5 [Use Selector-Based Subscriptions for Granular Updates](references/sub-selector-subscriptions.md) — MEDIUM-HIGH (reduces re-renders to only affected components)
7. [Profiling & Measurement](references/_sections.md#7-profiling-&-measurement) — **MEDIUM**
   - 7.1 [Benchmark with Production Builds Only](references/profile-production-builds.md) — MEDIUM (prevents false positives from dev-mode overhead)
   - 7.2 [Enforce Performance Budgets in CI](references/profile-performance-budgets.md) — MEDIUM (prevents regressions, catches 90% of perf issues before merge)
   - 7.3 [Profile Before Optimizing to Target Real Bottlenecks](references/profile-before-optimize.md) — MEDIUM (10× more effective optimization effort)
   - 7.4 [Read Flame Charts to Identify Hot Render Paths](references/profile-flame-charts.md) — MEDIUM (identifies exact function causing 80% of render time)
   - 7.5 [Use React Performance Tracks for Render Analysis](references/profile-react-devtools.md) — MEDIUM (pinpoints render bottlenecks in minutes instead of hours)
8. [Memory Management](references/_sections.md#8-memory-management) — **LOW-MEDIUM**
   - 8.1 [Avoid Closure-Based Memory Leaks in Event Handlers](references/mem-closure-leaks.md) — LOW-MEDIUM (prevents MB-scale memory retention in event-heavy UIs)
   - 8.2 [Cancel Async Operations on Unmount](references/mem-async-cancellation.md) — LOW-MEDIUM (prevents stale updates and memory retention)
   - 8.3 [Clean Up Effects to Prevent Subscription Memory Leaks](references/mem-effect-cleanup.md) — LOW-MEDIUM (prevents linear memory growth in long-lived SPAs)
   - 8.4 [Dispose Heavy Resources in Cleanup Functions](references/mem-heavy-resources.md) — LOW-MEDIUM (prevents 5-50MB per resource retention)
   - 8.5 [Use Heap Snapshots to Detect Component Retention](references/mem-heap-snapshots.md) — LOW-MEDIUM (identifies retained objects causing 10-100MB memory growth)

---

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/blog/2025/10/07/react-compiler-1](https://react.dev/blog/2025/10/07/react-compiler-1)
3. [https://web.dev/articles/vitals](https://web.dev/articles/vitals)
4. [https://tanstack.com/virtual](https://tanstack.com/virtual)
5. [https://developer.chrome.com/docs/devtools/performance](https://developer.chrome.com/docs/devtools/performance)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |