---
title: Use next/dynamic for Heavy Components
impact: CRITICAL
impactDescription: Reduces initial JS bundle by 30-70%, improves Time to Interactive by 500ms-2s
tags: bundle, lazy-loading, code-splitting, next-dynamic
---

## Use next/dynamic for Heavy Components

Heavy components like charts, editors, and maps add significant weight to your initial bundle. Using `next/dynamic` defers loading until the component is needed, drastically reducing Time to Interactive and improving Core Web Vitals.

**Incorrect (loads entire chart library upfront):**

```typescript
import AnalyticsDashboard from '@/components/AnalyticsDashboard'
import RichTextEditor from '@/components/RichTextEditor'
// 200KB+ added to initial bundle even if user never views these

export default function AdminPage() {
  return (
    <div>
      <AnalyticsDashboard />
      <RichTextEditor />
    </div>
  )
}
```

**Correct (lazy loads heavy components):**

```typescript
import dynamic from 'next/dynamic'

const AnalyticsDashboard = dynamic(
  () => import('@/components/AnalyticsDashboard'),
  { loading: () => <DashboardSkeleton /> }
)
const RichTextEditor = dynamic(
  () => import('@/components/RichTextEditor'),
  { loading: () => <EditorSkeleton /> }
)

export default function AdminPage() {
  return (
    <div>
      <AnalyticsDashboard />
      <RichTextEditor />
    </div>
  )
}
```

**Alternative (disable SSR for browser-only components):**

```typescript
const MapView = dynamic(() => import('@/components/MapView'), {
  ssr: false, // Component uses window/document APIs
  loading: () => <MapPlaceholder />,
})
```

**When to use dynamic imports:**
- Chart libraries (recharts, chart.js, d3)
- Rich text editors (tiptap, slate, draft-js)
- Map components (mapbox, leaflet, google-maps)
- PDF viewers and heavy media players
- Components behind user interaction (modals, drawers)

Reference: [Lazy Loading in Next.js](https://nextjs.org/docs/app/guides/lazy-loading)
