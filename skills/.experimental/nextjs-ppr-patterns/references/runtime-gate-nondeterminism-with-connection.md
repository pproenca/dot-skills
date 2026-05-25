---
title: Gate randomness and time behind connection or cache the value
tags: runtime, connection, non-determinism, suspense
---

## Gate randomness and time behind connection or cache the value

The model freely calls `Math.random()`, `Date.now()`, or `crypto.randomUUID()` inside a component. Under Cache Components these can't run during prerender — their value would be frozen into the static HTML — so they error. Choose intent: defer to request time by awaiting `connection()` before the call (and wrap the component in `<Suspense>`), or `'use cache'` the value so every visitor deliberately sees the same one until revalidation.

```tsx
import { connection } from 'next/server'
import { Suspense } from 'react'

async function RequestId() {
  await connection() // opt into request time; nothing before this runs during prerender
  return <p>Request ID: {crypto.randomUUID()}</p>
}

export default function Page() {
  return (
    <Suspense fallback={<p>Loading…</p>}>
      <RequestId />
    </Suspense>
  )
}
```

Reference: [Caching — non-deterministic operations](https://nextjs.org/docs/app/getting-started/caching#working-with-non-deterministic-operations)
