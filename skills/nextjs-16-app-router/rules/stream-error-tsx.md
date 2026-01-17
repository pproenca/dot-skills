---
title: Use error.tsx for Route-Level Error Boundaries
impact: MEDIUM
impactDescription: graceful error recovery, prevents full page crashes
tags: stream, error, error-boundary, recovery
---

## Use error.tsx for Route-Level Error Boundaries

Create `error.tsx` files to catch errors in route segments. Users can retry without navigating away or losing state.

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
