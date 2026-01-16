---
name: nextjs-16
description: Next.js 16 App Router performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring Next.js code to ensure optimal performance patterns. Triggers on tasks involving React Server Components, Client Components, data fetching, caching, routing, authentication, middleware, image optimization, and bundle size reduction.
---

# Next.js 16 Best Practices

Comprehensive performance optimization guide for Next.js 16 applications using the App Router. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Next.js App Router code
- Deciding between Server and Client Components
- Implementing data fetching and caching strategies
- Optimizing bundle size and code splitting
- Setting up authentication and middleware
- Improving Core Web Vitals (LCP, CLS, INP)
- Reviewing Next.js code for performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Network Waterfalls & Data Fetching | CRITICAL | `async-` |
| 2 | Bundle Size & Code Splitting | CRITICAL | `bundle-` |
| 3 | Server vs Client Component Boundaries | HIGH | `server-` |
| 4 | Client-Side Data & State | HIGH | `client-` |
| 5 | Rendering Strategy Selection | MEDIUM-HIGH | `render-` |
| 6 | Caching & Revalidation | MEDIUM | `cache-` |
| 7 | Routing & Navigation | MEDIUM | `route-` |
| 8 | Advanced Patterns & Security | LOW-MEDIUM | `advanced-` |

## Quick Reference

### 1. Network Waterfalls & Data Fetching (CRITICAL)

- `async-server-fetch` - Fetch data in Server Components
- `async-parallel-fetches` - Parallelize independent data fetches
- `async-suspense-streaming` - Use Suspense for streaming dynamic content
- `async-avoid-client-waterfalls` - Avoid cascading useEffect fetches
- `async-use-cache-directive` - Use 'use cache' for expensive computations
- `async-loading-tsx` - Add loading.tsx for instant navigation feedback
- `async-avoid-blocking-root` - Avoid blocking root layout with async operations

### 2. Bundle Size & Code Splitting (CRITICAL)

- `bundle-avoid-barrel-files` - Avoid barrel file imports
- `bundle-minimize-client-components` - Minimize Client Component scope
- `bundle-dynamic-imports` - Use dynamic imports for heavy components
- `bundle-tree-shake-imports` - Tree-shake library imports
- `bundle-analyze-regularly` - Analyze bundle size regularly
- `bundle-turbopack` - Enable Turbopack for faster development

### 3. Server vs Client Component Boundaries (HIGH)

- `server-default-server-components` - Keep components server-side by default
- `server-only-sensitive-code` - Use 'server-only' for sensitive code
- `server-pass-serializable-props` - Pass only serializable props to Client Components
- `server-async-components` - Use async/await in Server Components
- `server-avoid-props-drilling` - Avoid props drilling with composition
- `server-layouts-for-shared-data` - Use layouts for shared data and UI

### 4. Client-Side Data & State (HIGH)

- `client-minimize-state` - Minimize client-side state
- `client-use-transitions` - Use useTransition for non-blocking updates
- `client-avoid-layout-effects` - Avoid useLayoutEffect in server-rendered apps
- `client-stable-references` - Maintain stable references with useCallback/useMemo
- `client-event-handlers` - Attach event handlers only in Client Components
- `client-url-state` - Use URL state for shareable UI state

### 5. Rendering Strategy Selection (MEDIUM-HIGH)

- `render-prefer-static` - Prefer static rendering by default
- `render-generate-static-params` - Use generateStaticParams for dynamic routes
- `render-partial-prerendering` - Use Partial Prerendering for mixed content
- `render-avoid-unnecessary-dynamic` - Avoid accidentally triggering dynamic rendering

### 6. Caching & Revalidation (MEDIUM)

- `cache-fetch-revalidate` - Set appropriate cache revalidation times
- `cache-on-demand-revalidation` - Use tag-based on-demand revalidation
- `cache-request-deduplication` - Leverage automatic request deduplication
- `cache-avoid-cache-stampede` - Prevent cache stampedes with ISR
- `cache-unstable-cache` - Use unstable_cache for non-fetch data sources

### 7. Routing & Navigation (MEDIUM)

- `route-use-link-component` - Use Link component for client-side navigation
- `route-organize-with-groups` - Organize routes with route groups
- `route-parallel-routes` - Use parallel routes for complex layouts
- `route-not-found` - Use notFound() for missing resources

### 8. Advanced Patterns & Security (LOW-MEDIUM)

- `advanced-middleware-auth` - Use middleware for route protection
- `advanced-server-actions` - Use Server Actions for mutations
- `advanced-image-optimization` - Use next/image for automatic optimization
- `advanced-font-optimization` - Use next/font for zero-CLS fonts
- `advanced-error-boundaries` - Implement granular error boundaries
- `advanced-metadata-seo` - Generate dynamic metadata for SEO
- `advanced-api-routes` - Use Route Handlers for API endpoints

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/{prefix}-{slug}.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`

## Sources

- [Next.js Official Documentation](https://nextjs.org/docs)
- [Vercel React Best Practices](https://vercel.com/blog/introducing-react-best-practices)
- [Next.js Barrel Files Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
