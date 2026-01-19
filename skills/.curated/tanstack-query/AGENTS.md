# TanStack Query v5

**Version 1.0.0**  
community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for TanStack Query v5 applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (query key structure, caching configuration) to incremental (render optimization). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Query Key Structure](references/_sections.md#1-query-key-structure) — **CRITICAL**
   - 1.1 [Always Use Array Query Keys](references/tquery-always-arrays.md) — HIGH (consistent structure, prevents string/array mismatch bugs)
   - 1.2 [Colocate Query Keys with Features](references/tquery-colocate-keys.md) — MEDIUM (improves maintainability, enables feature isolation)
   - 1.3 [Structure Keys from Generic to Specific](references/tquery-hierarchical-keys.md) — CRITICAL (enables granular cache invalidation at any level)
   - 1.4 [Use Query Key Factories](references/tquery-key-factories.md) — CRITICAL (eliminates key duplication, enables type-safe invalidation)
   - 1.5 [Use queryOptions for Type-Safe Sharing](references/tquery-options-pattern.md) — HIGH (type-safe prefetching and cache access)
   - 1.6 [Use Serializable Objects in Query Keys](references/tquery-serializable-objects.md) — HIGH (deterministic hashing, prevents cache misses)
2. [Caching Configuration](references/_sections.md#2-caching-configuration) — **CRITICAL**
   - 2.1 [Configure Global Defaults Appropriately](references/cache-global-defaults.md) — CRITICAL (prevents per-query repetition, establishes sensible baselines)
   - 2.2 [Control Automatic Refetch Triggers](references/cache-refetch-triggers.md) — MEDIUM (prevents unexpected refetches, saves bandwidth)
   - 2.3 [Invalidate with Precision](references/cache-invalidation-precision.md) — HIGH (prevents over-invalidation cascade, improves performance)
   - 2.4 [Understand staleTime vs gcTime](references/cache-staletime-gctime.md) — CRITICAL (prevents unnecessary refetches and memory issues)
   - 2.5 [Use enabled for Conditional Queries](references/cache-enabled-option.md) — HIGH (prevents invalid requests, enables dependent queries)
   - 2.6 [Use placeholderData vs initialData Correctly](references/cache-placeholder-vs-initial.md) — HIGH (prevents stale data bugs and incorrect cache behavior)
3. [Mutation Patterns](references/_sections.md#3-mutation-patterns) — **HIGH**
   - 3.1 [Avoid Parallel Mutations on Same Data](references/mutation-avoid-parallel.md) — MEDIUM (prevents race conditions and cache corruption)
   - 3.2 [Cancel Queries Before Optimistic Updates](references/mutation-cancel-queries.md) — HIGH (prevents race conditions, preserves optimistic state)
   - 3.3 [Implement Optimistic Updates with Rollback](references/mutation-optimistic-updates.md) — HIGH (instant UI feedback, proper error recovery)
   - 3.4 [Invalidate in onSettled, Not onSuccess](references/mutation-invalidate-onsettled.md) — HIGH (ensures cache sync after errors too)
   - 3.5 [Use setQueryData for Immediate Cache Updates](references/mutation-setquerydata.md) — MEDIUM (instant UI updates without refetch roundtrip)
4. [Prefetching & Waterfalls](references/_sections.md#4-prefetching-&-waterfalls) — **HIGH**
   - 4.1 [Avoid Request Waterfalls](references/prefetch-avoid-waterfalls.md) — CRITICAL (2-10× latency reduction)
   - 4.2 [Flatten API to Reduce Waterfalls](references/prefetch-flatten-api.md) — CRITICAL (eliminates dependent query chains entirely)
   - 4.3 [Prefetch Dependent Data in queryFn](references/prefetch-in-queryfn.md) — HIGH (parallelizes dependent data fetching)
   - 4.4 [Prefetch in Server Components](references/prefetch-server-components.md) — HIGH (eliminates client-side waterfall, immediate data)
   - 4.5 [Prefetch on Hover for Perceived Speed](references/prefetch-on-hover.md) — HIGH (200-400ms head start before navigation)
5. [Infinite Queries](references/_sections.md#5-infinite-queries) — **MEDIUM**
   - 5.1 [Flatten Pages for Rendering](references/infinite-flatten-pages.md) — MEDIUM (simplifies component logic, enables virtualization)
   - 5.2 [Handle Infinite Query Loading States Correctly](references/infinite-loading-states.md) — MEDIUM (prevents UI glitches, shows appropriate feedback)
   - 5.3 [Limit Infinite Query Pages with maxPages](references/infinite-max-pages.md) — HIGH (90% memory reduction in long sessions)
   - 5.4 [Understand Infinite Query Refetch Behavior](references/infinite-refetch-behavior.md) — MEDIUM (prevents unexpected sequential refetches)
6. [Suspense Integration](references/_sections.md#6-suspense-integration) — **MEDIUM**
   - 6.1 [Always Pair Suspense with Error Boundaries](references/suspense-error-boundaries.md) — HIGH (prevents unhandled exceptions from crashing app)
   - 6.2 [Combine Suspense Queries with useSuspenseQueries](references/suspense-parallel-queries.md) — MEDIUM (prevents waterfall in suspense components)
   - 6.3 [Place Suspense Boundaries Strategically](references/suspense-boundaries-placement.md) — MEDIUM (controls loading granularity, prevents layout shift)
   - 6.4 [Use Suspense Hooks for Simpler Loading States](references/suspense-use-suspense-hooks.md) — MEDIUM (eliminates loading checks, cleaner component code)
7. [Error & Retry Handling](references/_sections.md#7-error-&-retry-handling) — **MEDIUM**
   - 7.1 [Configure Retry with Exponential Backoff](references/error-retry-config.md) — MEDIUM (balances recovery vs user wait time)
   - 7.2 [Display Errors Appropriately](references/error-display-patterns.md) — MEDIUM (improves UX, prevents silent failures)
   - 7.3 [Use Conditional Retry Based on Error Type](references/error-conditional-retry.md) — HIGH (prevents retrying unrecoverable errors)
   - 7.4 [Use Global Error Handler for Common Errors](references/error-global-handler.md) — MEDIUM (centralizes error handling, consistent UX)
   - 7.5 [Use throwOnError with Error Boundaries](references/error-throw-on-error.md) — MEDIUM (bubbles errors to boundaries, enables catch-all handling)
8. [Render Optimization](references/_sections.md#8-render-optimization) — **LOW-MEDIUM**
   - 8.1 [Avoid Destructuring All Properties](references/render-tracked-props.md) — LOW (prevents subscribing to unused state changes)
   - 8.2 [Memoize Select Functions](references/render-select-memoize.md) — MEDIUM (prevents repeated computation on every render)
   - 8.3 [Understand Structural Sharing](references/render-structural-sharing.md) — LOW (automatic reference stability for unchanged data)
   - 8.4 [Use notifyOnChangeProps to Limit Re-renders](references/render-notify-props.md) — LOW-MEDIUM (prevents re-renders for unused state changes)
   - 8.5 [Use Select to Derive Data and Reduce Re-renders](references/render-select-derived.md) — MEDIUM (component only re-renders when derived value changes)

---

## References

1. [https://tanstack.com/query/v5/docs](https://tanstack.com/query/v5/docs)
2. [https://tkdodo.eu/blog](https://tkdodo.eu/blog)
3. [https://github.com/lukemorales/query-key-factory](https://github.com/lukemorales/query-key-factory)
4. [https://github.com/TanStack/query/discussions](https://github.com/TanStack/query/discussions)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |