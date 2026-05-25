---
title: Give each independent widget its own boundary to stream in parallel
tags: compose, suspense, parallel, waterfall
---

## Give each independent widget its own boundary to stream in parallel

For a dashboard of independent widgets, the model awaits them one after another in a single component — each `await` blocks the next, so the slowest fetch gates the whole page (a request waterfall). Give each independent widget its own `<Suspense>`: the shell ships instantly and each widget streams in as soon as *its* data resolves, independently. For fetches that must be combined in one component, start them together and `Promise.all` them rather than awaiting in sequence.

**Incorrect (sequential awaits — one slow widget blocks all):**

```tsx
export default async function Dashboard() {
  const revenue = await getRevenue() // blocks…
  const signups = await getSignups() // …then this…
  const tickets = await getOpenTickets() // …then this
  return (
    <>
      <Revenue data={revenue} />
      <Signups data={signups} />
      <Tickets data={tickets} />
    </>
  )
}
```

**Correct (independent holes stream in parallel):**

```tsx
import { Suspense } from 'react'

export default function Dashboard() {
  return (
    <>
      <Suspense fallback={<CardSkeleton />}><Revenue /></Suspense>
      <Suspense fallback={<CardSkeleton />}><Signups /></Suspense>
      <Suspense fallback={<CardSkeleton />}><Tickets /></Suspense>
    </>
  )
}
```

Reference: [Fetching Data — parallel data fetching](https://nextjs.org/docs/app/getting-started/fetching-data#parallel-data-fetching)
