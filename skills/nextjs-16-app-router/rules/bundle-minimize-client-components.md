---
title: Keep 'use client' Boundaries as Leaf Nodes
impact: CRITICAL
impactDescription: Reduces client JS by 40-70%, prevents cascading bundle bloat from parent components
tags: bundle, use-client, server-components, component-boundaries
---

## Keep 'use client' Boundaries as Leaf Nodes

When you mark a component with `'use client'`, all its imports and children become part of the client bundle. Placing `'use client'` too high in the component tree pulls server-only code into the client, dramatically increasing bundle size.

**Incorrect (client boundary too high):**

```typescript
'use client'
// Everything below ships to the client: 150KB+ unnecessarily

import { useState } from 'react'
import UserProfile from './UserProfile'
import RecentOrders from './RecentOrders'
import ProductRecommendations from './ProductRecommendations'

export default function DashboardPage({ user }) {
  const [activeTab, setActiveTab] = useState('profile')

  return (
    <div>
      <TabSelector active={activeTab} onChange={setActiveTab} />
      {activeTab === 'profile' && <UserProfile user={user} />}
      {activeTab === 'orders' && <RecentOrders userId={user.id} />}
      {activeTab === 'recs' && <ProductRecommendations />}
    </div>
  )
}
```

**Correct (client boundary at leaf node):**

```typescript
// DashboardPage.tsx - Server Component (no directive)
import UserProfile from './UserProfile'
import RecentOrders from './RecentOrders'
import ProductRecommendations from './ProductRecommendations'
import DashboardTabs from './DashboardTabs'

export default function DashboardPage({ user }) {
  return (
    <DashboardTabs
      profileContent={<UserProfile user={user} />}
      ordersContent={<RecentOrders userId={user.id} />}
      recsContent={<ProductRecommendations />}
    />
  )
}
```

```typescript
// DashboardTabs.tsx - Only the interactive part is client
'use client'

import { useState } from 'react'

export default function DashboardTabs({ profileContent, ordersContent, recsContent }) {
  const [activeTab, setActiveTab] = useState('profile')

  return (
    <div>
      <TabSelector active={activeTab} onChange={setActiveTab} />
      {activeTab === 'profile' && profileContent}
      {activeTab === 'orders' && ordersContent}
      {activeTab === 'recs' && recsContent}
    </div>
  )
}
```

**Pattern: Extract interactivity into small client components:**
- Button click handlers -> `<InteractiveButton />`
- Form state -> `<FormWithValidation />`
- Tabs/accordions -> pass content as children or props
- Search with debounce -> `<SearchInput />`

Reference: [Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)
