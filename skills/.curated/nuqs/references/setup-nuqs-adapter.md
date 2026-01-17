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

**Available adapters:**
- `nuqs/adapters/next/app` - Next.js App Router
- `nuqs/adapters/next/pages` - Next.js Pages Router
- `nuqs/adapters/react` - Plain React (with react-router)
- `nuqs/adapters/remix` - Remix
- `nuqs/adapters/react-router/v6` - React Router v6
- `nuqs/adapters/react-router/v7` - React Router v7

Reference: [nuqs Adapters](https://nuqs.dev/docs/adapters)
