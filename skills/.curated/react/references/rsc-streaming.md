---
title: Split slow async work behind its own Suspense boundary so fast content streams first
impact: MEDIUM-HIGH
impactDescription: progressive HTML delivery — fast subtrees appear immediately, slow ones stream when ready
tags: rsc, streaming, suspense-granularity, progressive-render
---

## Split slow async work behind its own Suspense boundary so fast content streams first

**Pattern intent:** the page's loading experience should match the natural timing of its parts. Static or fast subtrees should not be held hostage by a single slow async leaf.

### Shapes to recognize

- A single `<Suspense fallback={<FullPageSpinner/>}>` wrapping the entire route — nothing renders until the slowest child resolves.
- Several `await fetch(...)` calls in series at the top of a Server Component — the page can't begin streaming until all complete (also overlaps with `data-parallel-fetching`).
- Workaround: a parent that fetches everything and conditionally renders skeleton-shaped JSX — manual streaming logic, brittler than `<Suspense>`.
- Workaround: a "loading.tsx" route file as the *only* loading state — fine for the navigation, but does nothing for slow leaves *within* a page.
- An entire dashboard rendering a single spinner because one tile takes 2s — every other tile is ready in 50ms.

The canonical resolution: wrap each independently-paced async subtree in its own `<Suspense>` with a shape-matched fallback. The framework streams each as it resolves.

**Incorrect (single Suspense blocks all content):**

```typescript
export default function Page() {
  return (
    <Suspense fallback={<FullPageSpinner />}>
      <FastHeader />      {/* Ready in 50ms */}
      <SlowAnalytics />   {/* Takes 2000ms */}
      <FastFooter />      {/* Ready in 50ms */}
    </Suspense>
  )
}
// Nothing appears until SlowAnalytics completes
```

**Correct (granular Suspense for streaming):**

```typescript
export default function Page() {
  return (
    <>
      {/* No Suspense - renders immediately */}
      <StaticNav />

      <Suspense fallback={<HeaderSkeleton />}>
        <FastHeader />
      </Suspense>

      <main>
        <Suspense fallback={<ContentSkeleton />}>
          <MainContent />
        </Suspense>

        <Suspense fallback={<AnalyticsSkeleton />}>
          <SlowAnalytics />
        </Suspense>
      </main>

      {/* Static footer - no Suspense needed */}
      <StaticFooter />
    </>
  )
}
// StaticNav and StaticFooter appear instantly
// Header streams in at 50ms
// MainContent streams when ready
// Analytics streams at 2000ms
```

**Streaming order:**
1. Static HTML (no async) - immediate
2. Fast async components - as they resolve
3. Slow async components - when ready
