---
title: Every route should have a `loading.tsx` next to its `page.tsx` — never leave navigation showing a blank screen
impact: MEDIUM
impactDescription: instant navigation feedback during async page renders; automatic Suspense wrapping with the loading component as fallback
tags: stream, loading-tsx, route-level-skeleton, instant-feedback
---

## Every route should have a `loading.tsx` next to its `page.tsx` — never leave navigation showing a blank screen

**Pattern intent:** a route that fetches data during render shows nothing until that fetch lands — unless `loading.tsx` is present. Next.js auto-wraps the page in `<Suspense fallback={<Loading/>}>` so navigation feels instant.

### Shapes to recognize

- A route with `await fetch(...)` in `page.tsx` and no `loading.tsx` next to it — navigation to that route shows a blank screen for the full TTFB.
- A `loading.tsx` that's a thin generic spinner with no resemblance to the real content — causes CLS when content swaps in.
- A `loading.tsx` that itself does data fetching — defeats the "instant feedback" purpose. Loading components must be static.
- Multiple parallel routes (slots) with only the parent route having `loading.tsx` — slot-level loading needs slot-level `loading.tsx`.
- A workaround using a client-side `useState(loading)` in `layout.tsx` to fake loading — couples loading to client state instead of route navigation.

The canonical resolution: create `loading.tsx` adjacent to every `page.tsx` (and adjacent to slot `page.tsx` files for parallel routes). Make the skeleton match the page's real dimensions to prevent CLS. No data fetching in `loading.tsx`.

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
