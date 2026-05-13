---
title: Loading skeletons match the dimensions of the content they replace — never collapse the layout while loading
impact: MEDIUM
impactDescription: prevents Cumulative Layout Shift; CLS score goes from "needs improvement" to "good" simply by making skeletons match
tags: stream, skeleton-dimensions, cls, no-layout-shift
---

## Loading skeletons match the dimensions of the content they replace — never collapse the layout while loading

**Pattern intent:** a skeleton's job is to *occupy the same space* the real content will fill. If it doesn't, the page jumps when the real content arrives — that's CLS, hurts Core Web Vitals, and feels unprofessional.

### Shapes to recognize

- A `loading.tsx` that's `<div>Loading...</div>` — collapses to text height; real content pushes everything down.
- A skeleton that uses `h-8` but the real content is `h-64` — content swap causes a 200+ pixel jump.
- A skeleton with one placeholder where the real content has a list of items — the list expansion causes scroll jumps.
- An image skeleton without `aspect-ratio` while the real `<Image>` has fixed dimensions — first paint without skeleton, then layout jumps.
- A skeleton built before the real component, then the real component diverged — visual regression that nobody caught.
- A workaround using opacity tricks to "hide" the layout shift — the shift still happens; CLS metric is still bad.

The canonical resolution: use the same CSS layout classes for the skeleton container as the real content. Use `aspect-ratio` for media. Generate skeletons from the real component's structure (a `<XSkeleton/>` paired with `<X/>`) and lint that they stay synced.

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
