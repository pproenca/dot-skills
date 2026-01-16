---
title: Implement Granular Error Boundaries
impact: LOW-MEDIUM
impactDescription: Isolates failures to specific route segments; single component error doesn't crash entire page
tags: advanced, error-handling, error-boundaries, resilience
---

## Implement Granular Error Boundaries

Place `error.tsx` files at multiple route levels to contain failures. A failing component in one section won't crash the entire page - only its error boundary shows the fallback.

**Incorrect (single global error handler):**

```
app/
  error.tsx       # Only global error handler
  dashboard/
    page.tsx      # If this fails, user loses entire page
    analytics/
      page.tsx    # If this fails, user loses entire page
```

**Correct (granular error boundaries):**

```
app/
  error.tsx               # Global fallback
  dashboard/
    error.tsx             # Dashboard-specific errors
    page.tsx
    analytics/
      error.tsx           # Analytics errors isolated
      page.tsx
    settings/
      error.tsx           # Settings errors isolated
      page.tsx
```

```typescript
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
    <div className="p-4 bg-red-50 border border-red-200 rounded">
      <h2 className="text-red-800">Analytics unavailable</h2>
      <p className="text-red-600">
        We couldn't load your analytics data.
      </p>
      <button
        onClick={reset}
        className="mt-2 px-4 py-2 bg-red-600 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
// Only analytics section shows error; rest of dashboard works
```

**Global error boundary (catches root layout errors):**

```typescript
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
        <h2>Something went wrong!</h2>
        <button onClick={reset}>Try again</button>
      </body>
    </html>
  )
}
// Must include <html> and <body> since this replaces root layout
```

**Error boundary with logging:**

```typescript
'use client'

import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error tracking service
    logErrorToService(error)
  }, [error])

  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

**Pattern: Graceful degradation:**

```typescript
// Instead of showing error, show degraded state
'use client'

export default function RecommendationsError({ reset }) {
  return (
    <div className="opacity-50">
      <h3>Recommendations</h3>
      <p>Personalized recommendations unavailable.</p>
      <a href="/popular">View popular items instead</a>
    </div>
  )
}
```

**When NOT to use granular boundaries:**
- Simple pages with no independent sections
- Errors that should propagate to parent
- When error in one section should affect others

Reference: [Next.js Error Handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling)
