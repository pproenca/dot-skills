---
title: Use Framework-Specific Adapters
impact: LOW
impactDescription: enables nuqs in non-Next.js React applications
tags: advanced, adapters, remix, react-router, frameworks
---

## Use Framework-Specific Adapters

nuqs works with multiple React frameworks through adapters. Use the correct adapter for your framework to ensure proper URL synchronization.

**React Router v6:**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/react-router/v6'
import { BrowserRouter } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <NuqsAdapter>
        <Routes />
      </NuqsAdapter>
    </BrowserRouter>
  )
}
```

**React Router v7:**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/react-router/v7'
import { BrowserRouter } from 'react-router'

function App() {
  return (
    <BrowserRouter>
      <NuqsAdapter>
        <Routes />
      </NuqsAdapter>
    </BrowserRouter>
  )
}
```

**Remix:**

```tsx
// app/root.tsx
import { NuqsAdapter } from 'nuqs/adapters/remix'
import { Outlet } from '@remix-run/react'

export default function Root() {
  return (
    <html>
      <body>
        <NuqsAdapter>
          <Outlet />
        </NuqsAdapter>
      </body>
    </html>
  )
}
```

**Plain React (custom history):**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/react'

function App() {
  return (
    <NuqsAdapter>
      <MyApp />
    </NuqsAdapter>
  )
}
// Uses window.history directly
```

**Testing adapter:**

```tsx
// test/setup.tsx
import { NuqsTestingAdapter } from 'nuqs/adapters/testing'

function renderWithNuqs(ui, { searchParams = {} } = {}) {
  return render(
    <NuqsTestingAdapter searchParams={searchParams}>
      {ui}
    </NuqsTestingAdapter>
  )
}
```

**Available adapters:**

| Framework | Import Path |
|-----------|-------------|
| Next.js App Router | `nuqs/adapters/next/app` |
| Next.js Pages Router | `nuqs/adapters/next/pages` |
| React Router v6 | `nuqs/adapters/react-router/v6` |
| React Router v7 | `nuqs/adapters/react-router/v7` |
| Remix | `nuqs/adapters/remix` |
| Plain React | `nuqs/adapters/react` |
| Testing | `nuqs/adapters/testing` |

Reference: [nuqs Adapters](https://nuqs.dev/docs/adapters)
