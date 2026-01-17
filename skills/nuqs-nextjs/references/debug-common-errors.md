---
title: Diagnose Common nuqs Errors
impact: LOW-MEDIUM
impactDescription: reduces debugging time from hours to minutes
tags: debug, errors, troubleshooting, common-issues, hydration
---

## Diagnose Common nuqs Errors

Reference for diagnosing frequent nuqs issues and their solutions.

**Incorrect (missing adapter causes cryptic error):**

```tsx
// app/layout.tsx - Missing NuqsAdapter
export default function RootLayout({ children }) {
  return (
    <html>
      <body>{children}</body>
    </html>
  )
}
// Error: "Cannot read property 'push' of undefined"
```

**Correct (add NuqsAdapter):**

```tsx
// app/layout.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  )
}
```

**Other common errors and fixes:**

| Error | Cause | Fix |
|-------|-------|-----|
| "Hooks can only be called inside Client Components" | Missing 'use client' | Add `'use client'` directive |
| "Uncontrolled input" warning | Value is null | Use `value={query ?? ''}` |
| Hydration mismatch | Different defaults | Use shared parsers with withDefault |
| URL not updating | Missing adapter or old Next.js | Check adapter and version |
| State undefined in Server Component | Missing parse() | Call `parse()` before `get()` |

Reference: [nuqs Documentation](https://nuqs.dev/docs)
