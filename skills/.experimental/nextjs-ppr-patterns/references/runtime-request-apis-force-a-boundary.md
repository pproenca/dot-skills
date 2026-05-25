---
title: Know that request APIs force a dynamic boundary and are async
tags: runtime, cookies, headers, suspense
---

## Know that request APIs force a dynamic boundary and are async

The model reads `cookies()` / `headers()` / `searchParams` / `params` at the top of a page, often synchronously. In Next.js 16 these are **async** (must be `await`ed) *and* reading one marks that component request-time dynamic — so it must sit inside `<Suspense>` (or have its value passed into a `'use cache'` child). Reading a request API at the page root therefore makes the whole route dynamic and discards the static shell. Push the read down into a small Suspense-wrapped leaf so the rest of the page stays static.

```tsx
import { cookies } from 'next/headers'
import { Suspense } from 'react'

export default function AccountPage() {
  return (
    <>
      <AccountHeader /> {/* static — stays in the shell */}
      <Suspense fallback={<GreetingSkeleton />}>
        <Greeting /> {/* reading cookies keeps this dynamic and inside the boundary */}
      </Suspense>
    </>
  )
}

async function Greeting() {
  const theme = (await cookies()).get('theme')?.value ?? 'light'
  return <p>Theme: {theme}</p>
}
```

Reference: [Caching — working with runtime APIs](https://nextjs.org/docs/app/getting-started/caching#working-with-runtime-apis)
