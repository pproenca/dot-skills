---
title: Use Segment Config Options Appropriately
impact: MEDIUM
impactDescription: controls caching behavior, enables ISR with revalidate periods of seconds to hours
tags: render, config, revalidate, isr
---

## Use Segment Config Options Appropriately

Segment configuration exports (`dynamic`, `revalidate`, `fetchCache`) provide fine-grained control over rendering and caching behavior. Use them intentionally to balance freshness with performance.

**Incorrect (mixing conflicting configurations):**

```typescript
// app/dashboard/page.tsx
export const dynamic = 'force-dynamic'
export const revalidate = 3600  // Conflicting: revalidate ignored with force-dynamic

export default async function Dashboard() {
  const stats = await fetchDashboardStats()
  return <DashboardView stats={stats} />
}
```

**Correct (coherent ISR configuration):**

```typescript
// app/dashboard/page.tsx
export const revalidate = 60  // Regenerate at most every 60 seconds

export default async function Dashboard() {
  const stats = await fetchDashboardStats()
  return <DashboardView stats={stats} />
}
```

**Common segment config patterns:**

```typescript
// Static page, never revalidate (default)
export const dynamic = 'force-static'

// ISR: revalidate every hour
export const revalidate = 3600

// Always fresh, no caching
export const dynamic = 'force-dynamic'

// Error if dynamic APIs used (catch accidental dynamic rendering)
export const dynamic = 'error'
```

**When to use each option:**

| Config | Use Case |
|--------|----------|
| `revalidate = N` | Content updates periodically (blog, products) |
| `force-static` | Ensure static even with dynamic-looking code |
| `dynamic = 'error'` | Catch accidental dynamic API usage in CI |

Reference: [Route Segment Config](https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config)
