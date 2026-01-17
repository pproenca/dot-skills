---
title: Enable Streaming with Nested Suspense
impact: MEDIUM-HIGH
impactDescription: progressive loading, faster TTFB
tags: rsc, streaming, suspense, progressive
---

## Enable Streaming with Nested Suspense

Use multiple Suspense boundaries to stream HTML progressively. Fast components appear immediately while slow ones load.

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
