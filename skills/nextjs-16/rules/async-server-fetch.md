---
title: Fetch Data in Server Components
impact: CRITICAL
impactDescription: Eliminates client-side fetch waterfalls, reduces JS bundle by 10-50KB per data-fetching component
tags: async, server-components, data-fetching, waterfalls
---

## Fetch Data in Server Components

Server Components can fetch data directly during render without sending JavaScript to the client. This eliminates the waterfall pattern where the page loads, then JS executes, then fetches fire. Every fetch moved from client to server removes round-trip latency.

**Incorrect (client-side fetch waterfall):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function PostList() {
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Waterfall: HTML → JS → fetch → render
    // Adds 200-500ms on mobile networks
    fetch('/api/posts')
      .then(r => r.json())
      .then(data => {
        setPosts(data)
        setLoading(false)
      })
  }, [])

  if (loading) return <div>Loading...</div>
  return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>
}
```

**Correct (server-side fetch):**

```typescript
// No 'use client' - this is a Server Component
export default async function PostList() {
  // Fetch happens during server render
  // HTML includes data, zero client JS for this component
  const posts = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 }
  }).then(r => r.json())

  return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>
}
```

**When NOT to use this pattern:**
- Data requires client-side authentication tokens stored in browser
- Real-time data that needs WebSocket subscriptions
- Data that changes based on client-side user interactions

Reference: [Next.js Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)
