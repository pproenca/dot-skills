---
title: Declare route-level caching intent via segment-config exports — `dynamic`, `revalidate`, `generateStaticParams`
impact: MEDIUM-HIGH
impactDescription: controls caching at route boundary; correct choice between `force-static` and `force-dynamic` swings TTFB from build-time-fast to render-time-slow
tags: cache, segment-config, force-static, dynamic-rendering
---

## Declare route-level caching intent via segment-config exports — `dynamic`, `revalidate`, `generateStaticParams`

**Pattern intent:** each route segment has a default rendering mode (dynamic if it reads cookies/headers/searchParams; static otherwise). For pages where the default is wrong — e.g., a marketing page that would be perfectly cacheable — declare intent explicitly via `export const dynamic = 'force-static'` / `'force-dynamic'` and `export const revalidate = N`.

### Shapes to recognize

- An "about us" / "pricing" / "marketing" page rendered dynamically because the author didn't realize it would be served per-request — should be `force-static`.
- A blog post route with `dynamic = 'force-dynamic'` despite content being static for hours — should be `force-static` + `revalidate`.
- A route with `generateStaticParams` returning a small list but no `dynamicParams = false` — dynamically renders unlisted slugs, which may be a feature or a perf bug.
- A user dashboard with `force-static` exported — fails at runtime because reading cookies/auth requires dynamic rendering.
- A page exporting both `dynamic = 'force-static'` and using `await cookies()`/`headers()` — Next.js will warn or error; the two can't coexist.
- Multiple sibling routes with inconsistent `revalidate` values for the same data shape — pick a number and apply uniformly.

The canonical resolution: pick `dynamic` and `revalidate` based on what the route actually reads. Static content gets `force-static`. Auth-dependent gets `force-dynamic` (or just stays default-dynamic). Mostly-static content with a refresh budget gets `revalidate`.

**Incorrect (dynamic when static would work):**

```typescript
// app/about/page.tsx
export default async function AboutPage() {
  const team = await fetch('https://api.example.com/team')
  return <TeamSection team={team} />
}
// Defaults to dynamic rendering on every request
```

**Correct (explicit static generation):**

```typescript
// app/about/page.tsx
export const dynamic = 'force-static'
export const revalidate = 86400  // Revalidate daily

export default async function AboutPage() {
  const team = await fetch('https://api.example.com/team')
  return <TeamSection team={team} />
}
// Generated at build time, revalidated daily
```

**Segment config options:**

```typescript
// Force dynamic rendering (never cache)
export const dynamic = 'force-dynamic'

// Force static generation (build-time only)
export const dynamic = 'force-static'

// Revalidate time in seconds
export const revalidate = 3600  // 1 hour

// Generate static params for dynamic routes
export async function generateStaticParams() {
  const products = await getProducts()
  return products.map((p) => ({ slug: p.slug }))
}
```

**Decision matrix:**
- Static content → `force-static`
- User-specific/auth → `force-dynamic`
- Semi-static → `revalidate: N`
