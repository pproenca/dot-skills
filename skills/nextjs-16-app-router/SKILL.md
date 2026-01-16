---
name: nextjs-16-app-router-best-practices
description: Next.js 16 App Router performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring Next.js App Router code to ensure optimal performance patterns. Triggers on tasks involving Server Components, data fetching, caching, streaming, dynamic imports, route architecture, or client-side hydration.
---

# Next.js Community Next.js 16 App Router Best Practices

Comprehensive performance optimization guide for Next.js 16 App Router applications, maintained by Next.js Community. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Next.js App Router pages and components
- Optimizing data fetching patterns with Server Components
- Configuring caching and revalidation strategies
- Reducing bundle size and improving Time to Interactive
- Reviewing code for performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Async Data Fetching | CRITICAL | `async-` |
| 2 | Bundle Optimization | CRITICAL | `bundle-` |
| 3 | Server Components | HIGH | `server-` |
| 4 | Caching Strategies | HIGH | `cache-` |
| 5 | Rendering Patterns | MEDIUM | `render-` |
| 6 | Route Architecture | MEDIUM | `route-` |
| 7 | Client Components | MEDIUM | `client-` |
| 8 | Advanced Patterns | LOW | `advanced-` |

## Quick Reference

### 1. Async Data Fetching (CRITICAL)

- `async-parallel-fetching` - Use Promise.all() for independent data fetches
- `async-suspense-streaming` - Strategic Suspense boundaries for progressive loading
- `async-avoid-blocking-root` - Don't await slow data in root layouts
- `async-defer-await` - Start fetches early, await when value needed
- `async-loading-states` - Use loading.tsx for instant feedback
- `async-avoid-client-waterfalls` - Prevent client-side fetch cascades

### 2. Bundle Optimization (CRITICAL)

- `bundle-dynamic-imports` - Use next/dynamic for heavy components
- `bundle-avoid-barrel-files` - Import directly from source, not index.ts
- `bundle-optimize-package-imports` - Configure optimizePackageImports
- `bundle-minimize-client-components` - Keep 'use client' as leaf nodes
- `bundle-tree-shake-imports` - Import only what you use from libraries

### 3. Server Components (HIGH)

- `server-default-server-components` - Only add 'use client' when needed
- `server-pass-serializable-props` - Pass serializable data to Client Components
- `server-async-components` - Use async/await directly in Server Components
- `server-layouts-shared-data` - Fetch shared data in layouts
- `server-avoid-props-drilling` - Fetch data where needed
- `server-only-sensitive` - Use server-only for sensitive code

### 4. Caching Strategies (HIGH)

- `cache-fetch-options` - Use fetch cache options correctly
- `cache-unstable-cache` - Use unstable_cache for non-fetch data
- `cache-revalidate-on-demand` - Use revalidatePath/revalidateTag
- `cache-request-memoization` - Use React cache() for deduplication
- `cache-avoid-over-caching` - Don't cache user-specific data

### 5. Rendering Patterns (MEDIUM)

- `render-prefer-static` - Default to static rendering
- `render-generate-static-params` - Pre-render dynamic routes
- `render-dynamic-segment-config` - Use segment config appropriately
- `render-avoid-force-dynamic` - Avoid force-dynamic unless necessary
- `render-streaming-dynamic` - Combine streaming with dynamic rendering

### 6. Route Architecture (MEDIUM)

- `route-use-link-component` - Use next/link for navigation
- `route-organize-with-groups` - Use route groups for organization
- `route-parallel-routes` - Use @slot for simultaneous rendering
- `route-layouts-persistence` - Use layouts for persistent UI
- `route-not-found-handling` - Use not-found.tsx properly

### 7. Client Components (MEDIUM)

- `client-leaf-components` - Push 'use client' to leaf components
- `client-stable-callbacks` - Use useCallback for stable handlers
- `client-url-state` - Use URL params for shareable state
- `client-use-transitions` - Use useTransition for non-blocking updates
- `client-avoid-layout-effects` - Prefer useEffect over useLayoutEffect

### 8. Advanced Patterns (LOW)

- `advanced-middleware-efficient` - Keep middleware fast
- `advanced-metadata-generation` - Use generateMetadata for SEO
- `advanced-image-optimization` - Use next/image optimally
- `advanced-font-optimization` - Use next/font with display swap
- `advanced-error-boundaries` - Use error.tsx for error handling
- `advanced-api-routes` - Use Route Handlers with caching
- `advanced-intercepting-routes` - Use intercepting routes for modals
- `advanced-server-actions` - Use Server Actions for mutations

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/async-parallel-fetching.md
rules/bundle-dynamic-imports.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
