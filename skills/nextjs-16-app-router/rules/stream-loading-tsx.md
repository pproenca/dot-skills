---
title: Use loading.tsx for Route-Level Loading States
impact: MEDIUM
impactDescription: automatic loading UI, instant navigation feedback
tags: stream, loading, skeleton, navigation
---

## Use loading.tsx for Route-Level Loading States

Create `loading.tsx` files to show instant loading UI during route transitions. Next.js automatically wraps the page in Suspense with this component as fallback.

**Incorrect (no loading state):**

```text
app/dashboard/
└── page.tsx
# Navigation to /dashboard shows blank screen until data loads
```

**Correct (loading.tsx for instant feedback):**

```text
app/dashboard/
├── loading.tsx
└── page.tsx
```

```typescript
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="grid grid-cols-3 gap-4">
        <div className="h-32 bg-gray-200 rounded" />
        <div className="h-32 bg-gray-200 rounded" />
        <div className="h-32 bg-gray-200 rounded" />
      </div>
    </div>
  )
}

// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchDashboardData()
  return <Dashboard data={data} />
}
```

**Best practices:**
- Match skeleton structure to actual content
- Use CSS animations for polish
- Keep skeletons lightweight (no data fetching)
- Nest loading.tsx for granular control

```text
app/dashboard/
├── loading.tsx          # Dashboard skeleton
├── page.tsx
└── analytics/
    ├── loading.tsx      # Analytics-specific skeleton
    └── page.tsx
```
