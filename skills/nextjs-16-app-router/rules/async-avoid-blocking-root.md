---
title: Avoid Awaiting Slow Data in Root Layouts
impact: CRITICAL
impactDescription: eliminates 500-3000ms blocking delay on every navigation
tags: async, layout, blocking, navigation, performance
---

## Avoid Awaiting Slow Data in Root Layouts

Root layouts render on every page navigation. Awaiting slow data fetches in layouts blocks the entire application shell until data resolves. Move slow fetches to page components or wrap them in Suspense boundaries.

**Incorrect (slow fetch blocks all navigation):**

```typescript
// app/layout.tsx
export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const analytics = await getAnalyticsConfig()  // 800ms blocks every page
  const featureFlags = await getFeatureFlags()  // 400ms compounds the delay

  return (
    <html>
      <body>
        <AnalyticsProvider config={analytics}>
          <FeatureFlagProvider flags={featureFlags}>
            <Navigation />
            {children}
          </FeatureFlagProvider>
        </AnalyticsProvider>
      </body>
    </html>
  )
}
// Every navigation waits 1200ms before anything renders
```

**Correct (layout renders instantly, data streams):**

```typescript
// app/layout.tsx
import { Suspense } from 'react'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <Suspense fallback={<NavSkeleton />}>
          <NavigationWithData />  {/* Fetches its own data, streams in */}
        </Suspense>
        {children}
      </body>
    </html>
  )
}

// app/components/NavigationWithData.tsx
async function NavigationWithData() {
  const [analytics, featureFlags] = await Promise.all([
    getAnalyticsConfig(),
    getFeatureFlags(),
  ])

  return (
    <AnalyticsProvider config={analytics}>
      <FeatureFlagProvider flags={featureFlags}>
        <Navigation />
      </FeatureFlagProvider>
    </AnalyticsProvider>
  )
}
// Shell renders instantly, navigation streams in
```

**Alternative (use cached data):**

```typescript
// app/layout.tsx
import { unstable_cache } from 'next/cache'

const getCachedConfig = unstable_cache(
  async () => getAnalyticsConfig(),
  ['analytics-config'],
  { revalidate: 3600 }  // Cache for 1 hour
)

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const analytics = await getCachedConfig()  // Fast cache hit after first load

  return (
    <html>
      <body>
        <AnalyticsProvider config={analytics}>
          <Navigation />
          {children}
        </AnalyticsProvider>
      </body>
    </html>
  )
}
```

**When blocking is acceptable:**
- Authentication checks that must complete before rendering
- Critical configuration that affects the entire page structure
- Data that is already cached and resolves in <50ms

Reference: [Layouts and Templates](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)
