---
title: Configure Route Segment Caching with Exports
impact: MEDIUM-HIGH
impactDescription: controls caching at route level
tags: cache, segment-config, dynamic, revalidate
---

## Configure Route Segment Caching with Exports

Use route segment config exports to control caching behavior at the route level. These settings apply to the entire route segment.

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
