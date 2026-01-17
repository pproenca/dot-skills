---
title: Use Framework-Specific Adapters
impact: LOW
impactDescription: prevents URL sync failures in non-Next.js apps
tags: advanced, adapters, remix, react-router, frameworks
---

## Use Framework-Specific Adapters

nuqs works with multiple React frameworks through adapters. Use the correct adapter for your framework to ensure proper URL synchronization.

**Incorrect (wrong adapter for React Router):**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app' // Wrong!
import { BrowserRouter } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <NuqsAdapter> {/* This won't work with React Router */}
        <Routes />
      </NuqsAdapter>
    </BrowserRouter>
  )
}
```

**Correct (React Router v6 adapter):**

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
