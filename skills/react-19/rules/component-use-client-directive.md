---
title: Place use client at Component Boundaries
impact: MEDIUM
impactDescription: minimizes client bundle, maximizes server rendering
tags: component, directives, use-client, architecture
---

## Place use client at Component Boundaries

The 'use client' directive marks the boundary where server rendering stops. Place it as deep in the tree as possible to maximize server-rendered content.

**Incorrect (directive too high in tree):**

```tsx
// app/dashboard/page.tsx
'use client'  // Entire page is client-rendered

import { useState } from 'react'

export default function DashboardPage() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <Header />          {/* Could be server-rendered */}
      <Sidebar />         {/* Could be server-rendered */}
      <FilterInput value={filter} onChange={setFilter} />
      <DataTable filter={filter} />
    </div>
  )
}
```

**Correct (directive at interaction boundary):**

```tsx
// app/dashboard/page.tsx - Server Component
import { FilterableDataTable } from './FilterableDataTable'

export default function DashboardPage() {
  return (
    <div>
      <Header />     {/* Server-rendered */}
      <Sidebar />    {/* Server-rendered */}
      <FilterableDataTable />
    </div>
  )
}

// app/dashboard/FilterableDataTable.tsx
'use client'  // Only interactive part

import { useState } from 'react'

export function FilterableDataTable() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <FilterInput value={filter} onChange={setFilter} />
      <DataTable filter={filter} />
    </div>
  )
}
```

**Guidelines:**
- Server Components are the default - no directive needed
- Add 'use client' only where you need hooks or browser APIs
- Think "islands of interactivity" in a sea of server content

Reference: [use client](https://react.dev/reference/rsc/use-client)
