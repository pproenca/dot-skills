---
title: Stream server data into a client component with an unawaited Promise and use
tags: compose, use-hook, client-component, streaming
---

## Stream server data into a client component with an unawaited Promise and use

When a dynamic hole needs client interactivity (sorting, filtering, charts), the model either `await`s the data in the Server Component — blocking the shell until it resolves — or fetches it client-side in `useEffect`, creating a request waterfall with no server streaming. Instead, start the fetch in the Server Component **without awaiting**, pass the Promise to a `'use client'` component, and unwrap it with React's `use()` under a `<Suspense>` boundary. The data streams from the server while the client component stays interactive.

```tsx
// app/reports/page.tsx — Server Component
import { Suspense } from 'react'
import { SalesChart } from './sales-chart'

export default function ReportsPage() {
  const salesPromise = getSales() // do NOT await — kicks off the fetch immediately
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <SalesChart salesPromise={salesPromise} />
    </Suspense>
  )
}
```

```tsx
// app/reports/sales-chart.tsx — Client Component
'use client'
import { use, useState } from 'react'

export function SalesChart({ salesPromise }: { salesPromise: Promise<Sale[]> }) {
  const sales = use(salesPromise) // suspends until the streamed data arrives
  const [range, setRange] = useState<'30d' | '90d'>('30d')
  return <Chart data={sales} range={range} onRangeChange={setRange} />
}
```

Reference: [Fetching Data — streaming with the use API](https://nextjs.org/docs/app/getting-started/fetching-data#streaming-data-with-the-use-api)
