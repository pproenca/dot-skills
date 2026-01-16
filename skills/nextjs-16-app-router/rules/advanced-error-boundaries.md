---
title: Use error.tsx for Graceful Error Handling
impact: LOW
impactDescription: Prevents full page crashes and maintains partial UI during errors
tags: advanced, error-handling, error-boundary, resilience
---

## Use error.tsx for Graceful Error Handling

Unhandled errors in Server Components crash the entire page, showing users a blank screen or generic error. Using `error.tsx` creates error boundaries that catch errors at the route segment level, allowing the rest of the page to remain functional and providing users with recovery options.

**Incorrect (no error boundary causes full page crash):**

```tsx
// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  const data = await fetchAnalyticsData()
  // If this throws, entire page crashes - user sees nothing

  return (
    <div>
      <h1>Analytics Dashboard</h1>
      <AnalyticsChart data={data} />
    </div>
  )
}
```

**Correct (error.tsx catches and handles errors gracefully):**

```tsx
// app/dashboard/analytics/error.tsx
'use client'

export default function AnalyticsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="error-container">
      <h2>Failed to load analytics</h2>
      <p>There was a problem loading your analytics data.</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

```tsx
// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  const data = await fetchAnalyticsData()
  // If this throws, error.tsx catches it - dashboard layout stays visible

  return (
    <div>
      <h1>Analytics Dashboard</h1>
      <AnalyticsChart data={data} />
    </div>
  )
}
```

**Alternative (global-error.tsx for root layout errors):**

```tsx
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h1>Something went wrong</h1>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  )
}
```

**Error boundary placement:**
- Place `error.tsx` at route segments where failures are isolated
- Use `global-error.tsx` for root layout errors (must include `<html>` and `<body>`)
- Nest error boundaries for granular error recovery

Reference: [Error Handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling)
