---
title: Diagnose Common nuqs Errors
impact: LOW-MEDIUM
impactDescription: faster debugging of frequent issues
tags: debug, errors, troubleshooting, common-issues, hydration
---

## Diagnose Common nuqs Errors

Reference for diagnosing frequent nuqs issues and their solutions.

**Error: "Cannot read property 'push' of undefined"**

Cause: Missing NuqsAdapter or incompatible Next.js version.

```tsx
// Fix: Add NuqsAdapter to layout
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default function RootLayout({ children }) {
  return <NuqsAdapter>{children}</NuqsAdapter>
}
```

**Error: "Hooks can only be called inside Client Components"**

Cause: Using `useQueryState` in a Server Component.

```tsx
// Fix: Add 'use client' directive
'use client'

import { useQueryState } from 'nuqs'
```

**Warning: "A component is changing an uncontrolled input"**

Cause: Input value is `null` initially.

```tsx
// Fix: Provide fallback value
const [query, setQuery] = useQueryState('q')
<input value={query ?? ''} onChange={e => setQuery(e.target.value)} />
```

**Hydration mismatch errors**

Cause: Server and client render different values.

```tsx
// Fix: Ensure same default on server and client
// Use shared parsers with withDefault
import { searchParams } from '@/lib/searchParams'
const [page] = useQueryState('page', searchParams.page)
```

**URL not updating**

Possible causes:
1. Missing NuqsAdapter
2. Next.js version too old
3. `shallow: true` with server-side expectations

```tsx
// Fix: Check adapter and version, use shallow: false if needed
const [query, setQuery] = useQueryState('q', parseAsString.withOptions({
  shallow: false
}))
```

**State undefined in Server Component**

Cause: Forgot to call `parse()` before `get()`.

```tsx
// Fix: Always parse at page level
const { q } = await searchParamsCache.parse(searchParams)
// Then get() works in nested components
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)
