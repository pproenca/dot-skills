---
title: Wrap App with NuqsAdapter
impact: CRITICAL
impactDescription: prevents 100% of hook failures from missing provider
tags: setup, NuqsAdapter, provider, app-router, pages-router
---

## Wrap App with NuqsAdapter

nuqs requires the `NuqsAdapter` provider to function. Without it, `useQueryState` hooks won't sync with the URL and may throw errors.

**Incorrect (missing adapter):**

```tsx
// src/app/layout.tsx
export default function RootLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>{children}</body>
    </html>
  )
}
// useQueryState calls will fail silently or throw
```

**Correct (App Router):**

```tsx
// src/app/layout.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default function RootLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  )
}
```

**Correct (Pages Router):**

```tsx
// src/pages/_app.tsx
import type { AppProps } from 'next/app'
import { NuqsAdapter } from 'nuqs/adapters/next/pages'

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <NuqsAdapter>
      <Component {...pageProps} />
    </NuqsAdapter>
  )
}
```

**Available adapters (nuqs v2.8+):**
- `nuqs/adapters/next/app` — Next.js App Router
- `nuqs/adapters/next/pages` — Next.js Pages Router
- `nuqs/adapters/next` — Next.js unified (mixed routers)
- `nuqs/adapters/react` — Plain React (no router, e.g. Vite/CRA)
- `nuqs/adapters/remix` — Remix
- `nuqs/adapters/react-router/v5` — React Router v5 (added v2.8)
- `nuqs/adapters/react-router/v6` — React Router v6
- `nuqs/adapters/react-router/v7` — React Router v7
- `nuqs/adapters/tanstack-router` — TanStack Router (added v2.5)
- `nuqs/adapters/testing` — Tests (see `debug-testing`)

The unversioned `nuqs/adapters/react-router` (alias for v6) is deprecated and will be removed in v3 — always pin a version.

Reference: [nuqs Adapters](https://nuqs.dev/docs/adapters)
