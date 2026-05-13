---
title: Every route should have an `error.tsx` next to it — a failed fetch must not kill the framework chrome
impact: MEDIUM
impactDescription: contains async failures to their route segment; user can `reset()` to retry without navigating away; preserves layout/header state across retries
tags: stream, error-tsx, route-level-error, reset-retry
---

## Every route should have an `error.tsx` next to it — a failed fetch must not kill the framework chrome

**Pattern intent:** a route that fetches data can fail. Without `error.tsx`, the failure bubbles up to the closest `global-error.tsx` (or Next's default), losing all surrounding chrome and navigation context.

### Shapes to recognize

- A route with `await fetch(...)` and no `error.tsx` — any upstream failure renders the framework's default error page.
- A page-wide `try/catch` that catches and returns fallback JSX — works but loses the `reset` retry semantic.
- An `error.tsx` that's a server component (missing `'use client'`) — won't work; error components must be client components.
- An `error.tsx` that logs the error to `console.error` but never reports it to a real monitoring service — silent in production.
- An `error.tsx` that resets state but doesn't include the `reset` button as a recovery affordance — user has to navigate away to retry.
- An `error.tsx` placed in the wrong segment level — it doesn't catch errors in *its own* `layout.tsx` (place it in the parent for that).

The canonical resolution: `'use client'` `error.tsx` next to each route segment with retry/recovery UI; `global-error.tsx` at the root for root-layout failures; client `useEffect` to log to monitoring.

**Incorrect (unhandled errors crash the page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchData()  // If this throws, entire app crashes
  return <Dashboard data={data} />
}
```

**Correct (error.tsx catches and recovers):**

```typescript
// app/dashboard/error.tsx
'use client'  // Error components must be Client Components

import { useEffect } from 'react'

export default function DashboardError({
  error,
  reset
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error(error)
  }, [error])

  return (
    <div className="p-4 bg-red-50 rounded">
      <h2>Something went wrong loading the dashboard</h2>
      <button
        onClick={() => reset()}
        className="mt-2 px-4 py-2 bg-red-600 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

**Error boundary hierarchy:**

```text
app/
├── error.tsx           # Catches errors in all routes
├── global-error.tsx    # Catches errors in root layout
└── dashboard/
    ├── error.tsx       # Catches errors in dashboard routes only
    └── page.tsx
```

**Note:** `error.tsx` doesn't catch errors in the same segment's `layout.tsx`. Place `error.tsx` in the parent segment to catch layout errors.
