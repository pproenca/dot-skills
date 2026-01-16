---
name: tanstack-query-best-practices
description: TanStack Query v5 performance optimization and best practices. This skill should be used when writing, reviewing, or refactoring code using TanStack Query (React Query). Triggers on tasks involving data fetching, caching, mutations, prefetching, infinite queries, or query optimization.
license: MIT
metadata:
  author: community
  version: "1.0.0"
---

# TanStack Query Best Practices

Comprehensive performance optimization guide for TanStack Query v5 applications. Contains 40 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new queries, mutations, or data fetching logic
- Implementing caching strategies (staleTime, gcTime)
- Reviewing code for performance issues or request waterfalls
- Refactoring existing TanStack Query code
- Implementing infinite queries, Suspense, or optimistic updates

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Key Structure | CRITICAL | `query-` |
| 2 | Caching Configuration | CRITICAL | `cache-` |
| 3 | Mutation Patterns | HIGH | `mutation-` |
| 4 | Prefetching & Waterfalls | HIGH | `prefetch-` |
| 5 | Infinite Queries | MEDIUM | `infinite-` |
| 6 | Suspense Integration | MEDIUM | `suspense-` |
| 7 | Error & Retry Handling | MEDIUM | `error-` |
| 8 | Render Optimization | LOW-MEDIUM | `render-` |

## Quick Reference

### 1. Query Key Structure (CRITICAL)

- `query-key-factories` - Use centralized query key factories
- `query-hierarchical-keys` - Structure keys from generic to specific
- `query-always-arrays` - Always use array query keys
- `query-serializable-objects` - Use serializable objects in keys
- `query-options-pattern` - Use queryOptions for type-safe sharing
- `query-colocate-keys` - Colocate query keys with features

### 2. Caching Configuration (CRITICAL)

- `cache-staletime-gctime` - Understand staleTime vs gcTime
- `cache-global-defaults` - Configure global defaults appropriately
- `cache-placeholder-vs-initial` - Use placeholderData vs initialData correctly
- `cache-invalidation-precision` - Invalidate with precision
- `cache-refetch-triggers` - Control automatic refetch triggers
- `cache-enabled-option` - Use enabled for conditional queries

### 3. Mutation Patterns (HIGH)

- `mutation-optimistic-updates` - Implement optimistic updates with rollback
- `mutation-invalidate-onsettled` - Invalidate in onSettled, not onSuccess
- `mutation-cancel-queries` - Cancel queries before optimistic updates
- `mutation-setquerydata` - Use setQueryData for immediate cache updates
- `mutation-avoid-parallel` - Avoid parallel mutations on same data

### 4. Prefetching & Waterfalls (HIGH)

- `prefetch-avoid-waterfalls` - Avoid request waterfalls
- `prefetch-on-hover` - Prefetch on hover for perceived speed
- `prefetch-in-queryfn` - Prefetch dependent data in queryFn
- `prefetch-server-components` - Prefetch in Server Components
- `prefetch-flatten-api` - Flatten API to reduce waterfalls

### 5. Infinite Queries (MEDIUM)

- `infinite-max-pages` - Limit infinite query pages with maxPages
- `infinite-flatten-pages` - Flatten pages for rendering
- `infinite-refetch-behavior` - Understand infinite query refetch behavior
- `infinite-loading-states` - Handle infinite query loading states correctly

### 6. Suspense Integration (MEDIUM)

- `suspense-use-suspense-hooks` - Use Suspense hooks for simpler loading states
- `suspense-error-boundaries` - Always pair Suspense with Error Boundaries
- `suspense-parallel-queries` - Combine Suspense queries with useSuspenseQueries
- `suspense-boundaries-placement` - Place Suspense boundaries strategically

### 7. Error & Retry Handling (MEDIUM)

- `error-retry-config` - Configure retry with exponential backoff
- `error-conditional-retry` - Use conditional retry based on error type
- `error-global-handler` - Use global error handler for common errors
- `error-display-patterns` - Display errors appropriately
- `error-throw-on-error` - Use throwOnError with Error Boundaries

### 8. Render Optimization (LOW-MEDIUM)

- `render-select-memoize` - Memoize select functions
- `render-select-derived` - Use select to derive data and reduce re-renders
- `render-notify-props` - Use notifyOnChangeProps to limit re-renders
- `render-structural-sharing` - Understand structural sharing
- `render-tracked-props` - Avoid destructuring all properties

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/query-key-factories.md
rules/cache-staletime-gctime.md
rules/_sections.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect code example with explanation
- Correct code example with explanation
- Additional context and references

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
