---
title: Place Suspense boundaries around independently-paced subtrees — not one boundary per page or one per file
impact: MEDIUM
impactDescription: faster perceived performance; each independently-loadable section streams as soon as its data is ready, not when the slowest sibling completes
tags: stream, suspense-placement, granular-boundary, independent-subtree
---

## Place Suspense boundaries around independently-paced subtrees — not one boundary per page or one per file

**Pattern intent:** a Suspense boundary defines a unit of "this content will appear together when its data is ready." Place it where the *boundaries of independently-loadable content* are — not at the page level (too coarse) or around every JSX element (too fine).

### Shapes to recognize

- A page-level `<Suspense fallback={<FullPageSpinner/>}>` wrapping the entire `<Dashboard/>` — one slow tile blocks all tiles.
- A `<Suspense>` around every element of the page including static text — adds noise without benefit.
- A `<Suspense>` placed *inside* an async component where the parent has already awaited — the boundary's fallback never shows because the async work happened upstream.
- Two siblings with different load times sharing one `<Suspense>` — the fast one waits for the slow one.
- A boundary's fallback that's wildly different in dimensions from the real content — causes layout shift (CLS) when the real content swaps in.

The canonical resolution: wrap each independently-paced async leaf in `<Suspense fallback={<MatchingSkeleton/>}>`. Static content stays outside Suspense. The fallback should match the rendered content's dimensions.

**Incorrect (single Suspense for entire page):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<FullPageLoader />}>
      <Dashboard />
    </Suspense>
  )
}
// User sees full-page spinner until everything loads
```

**Correct (granular Suspense boundaries):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Fast content renders immediately */}
      <Header />

      {/* Each section loads independently */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsWidget />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  )
}
// Header shows instantly, widgets stream in as they load
```

**Guidelines for Suspense boundaries:**
- Wrap each independent data-fetching component
- Group related components in single boundary
- Keep fallbacks similar in size to actual content (prevent layout shift)
- Prioritize above-the-fold content
