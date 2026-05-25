---
title: Know that Suspense alone does not make work dynamic
tags: shell, suspense, prerender, static-shell
---

## Know that Suspense alone does not make work dynamic

The model assumes wrapping a component in `<Suspense>` makes it dynamic (and that removing the boundary makes it static). It doesn't. Dynamism comes from *reading runtime or uncached data*, not from the boundary. A component that only does synchronous or cached work completes during prerender and lands in the static shell **even when wrapped** — the fallback never shows. So Suspense is necessary to *contain* dynamic content but does not *create* it: don't add a boundary hoping to defer synchronous work, and don't expect one to "make a page dynamic."

```tsx
import { Suspense } from 'react'

// Purely synchronous → resolves at build time and lands in the static shell,
// Suspense or not. The fallback will never render.
function FormattedTotal({ cents }: { cents: number }) {
  const amount = (cents / 100).toLocaleString('en-GB', {
    style: 'currency',
    currency: 'GBP',
  })
  return <p>{amount}</p>
}

function OrderSummary() {
  // Wrapping synchronous work in Suspense changes nothing — the fallback never shows.
  return (
    <Suspense fallback={<Spinner />}>
      <FormattedTotal cents={4999} />
    </Suspense>
  )
}
```

Reference: [Caching — streaming uncached data](https://nextjs.org/docs/app/getting-started/caching#streaming-uncached-data)
