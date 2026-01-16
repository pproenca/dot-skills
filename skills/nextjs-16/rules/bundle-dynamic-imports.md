---
title: Use Dynamic Imports for Heavy Components
impact: CRITICAL
impactDescription: Code-splits components into separate chunks; reduces initial JS by 50-200KB for pages with charts, editors, or maps
tags: bundle, dynamic-import, code-splitting, lazy-loading
---

## Use Dynamic Imports for Heavy Components

Use `next/dynamic` to split heavy components (charts, rich text editors, maps) into separate chunks loaded on demand. This keeps the initial bundle lean and loads expensive code only when needed.

**Incorrect (bundled with page):**

```typescript
import { Chart } from 'recharts'           // 80KB
import { Editor } from '@tiptap/react'      // 150KB
import { Map } from 'react-leaflet'         // 100KB

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      {/* All 330KB loaded immediately, even if user never scrolls down */}
      <Chart data={data} />
      <Editor />
      <Map />
    </div>
  )
}
```

**Correct (dynamically imported):**

```typescript
import dynamic from 'next/dynamic'

const Chart = dynamic(() => import('@/components/Chart'), {
  loading: () => <div className="h-64 bg-gray-100 animate-pulse" />,
})

const Editor = dynamic(() => import('@/components/Editor'), {
  loading: () => <div className="h-96 bg-gray-100 animate-pulse" />,
  ssr: false, // Editor uses browser APIs
})

const Map = dynamic(() => import('@/components/Map'), {
  loading: () => <div className="h-80 bg-gray-100 animate-pulse" />,
  ssr: false, // Leaflet requires window
})

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      {/* Components load in separate chunks when rendered */}
      <Chart data={data} />
      <Editor />
      <Map />
    </div>
  )
}
```

**Conditional loading pattern:**

```typescript
'use client'

import { useState } from 'react'
import dynamic from 'next/dynamic'

const HeavyModal = dynamic(() => import('@/components/HeavyModal'))

export default function Page() {
  const [showModal, setShowModal] = useState(false)

  return (
    <div>
      <button onClick={() => setShowModal(true)}>Open Settings</button>
      {/* HeavyModal only loads when showModal becomes true */}
      {showModal && <HeavyModal onClose={() => setShowModal(false)} />}
    </div>
  )
}
```

**Named export import:**

```typescript
const SpecificChart = dynamic(() =>
  import('@/components/charts').then(mod => mod.BarChart)
)
```

**When NOT to use this pattern:**
- Component is small (<10KB)
- Component is critical for above-the-fold content
- Component is always visible immediately on page load

Reference: [Next.js Lazy Loading](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)
