---
title: Match Skeleton Dimensions to Actual Content
impact: MEDIUM
impactDescription: prevents layout shift, better CLS score
tags: stream, skeleton, layout-shift, cls
---

## Match Skeleton Dimensions to Actual Content

Loading skeletons should match the dimensions of actual content to prevent layout shift (CLS). Use fixed heights or aspect ratios.

**Incorrect (skeleton causes layout shift):**

```typescript
// loading.tsx
export default function Loading() {
  return <div className="h-8 w-full bg-gray-200 animate-pulse" />
}

// page.tsx
export default async function Page() {
  const data = await fetchData()
  return (
    <div className="h-64">  {/* Height doesn't match skeleton */}
      <Content data={data} />
    </div>
  )
}
// Page jumps from 32px to 256px when content loads
```

**Correct (skeleton matches content dimensions):**

```typescript
// loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      {/* Header skeleton - matches actual header height */}
      <div className="h-12 w-64 bg-gray-200 animate-pulse rounded" />

      {/* Card grid skeleton - matches actual card dimensions */}
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="h-48 bg-gray-200 animate-pulse rounded" />
        ))}
      </div>
    </div>
  )
}

// page.tsx
export default async function Page() {
  const data = await fetchData()
  return (
    <div className="space-y-4">
      <h1 className="h-12 text-3xl">{data.title}</h1>
      <div className="grid grid-cols-3 gap-4">
        {data.cards.map(card => (
          <Card key={card.id} className="h-48" {...card} />
        ))}
      </div>
    </div>
  )
}
// No layout shift - skeleton and content have same dimensions
```

**Tips:**
- Use the same CSS classes for skeleton and content containers
- Set explicit heights on dynamic content
- Use `aspect-ratio` for images and videos
