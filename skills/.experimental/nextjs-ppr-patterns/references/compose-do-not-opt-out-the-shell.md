---
title: Do not opt the whole app out of the static shell to silence an error
tags: compose, static-shell, root-layout, anti-pattern
---

## Do not opt the whole app out of the static shell to silence an error

Hitting the "uncached data outside `<Suspense>`" build error, the model "fixes" it by wrapping `<body>` in `<Suspense fallback={null}>` in the root layout. That makes *every* request block on full render and discards the static shell for the entire app — the exact opposite of PPR. Wrap the actual offending leaf instead. Reserve the empty-boundary-above-`<body>` pattern for a route that genuinely must be fully dynamic, and isolate it with multiple root layouts. (The same care applies when `generateMetadata` / `generateViewport` read uncached data — handle it locally, not app-wide.)

**Incorrect (kills the shell app-wide to silence one error):**

```tsx
// app/layout.tsx
import { Suspense } from 'react'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <Suspense fallback={null}>
        <body>{children}</body> {/* whole app now defers to request time */}
      </Suspense>
    </html>
  )
}
```

**Correct (boundary around the component that actually reads dynamic data):**

```tsx
// app/layout.tsx stays static; fix it where the dynamic read happens
function HeaderCart() {
  return (
    <Suspense fallback={<CartSkeleton />}>
      <MiniCart /> {/* the component that actually calls cookies() */}
    </Suspense>
  )
}
```

Reference: [Caching — opting out of the static shell](https://nextjs.org/docs/app/getting-started/caching#opting-out-of-the-static-shell)
