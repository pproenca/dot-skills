---
title: Default to Server Components
impact: HIGH
impactDescription: 25-60% smaller bundles, faster TTI
tags: server, rsc, bundle-size, architecture
---

## Default to Server Components

In React 19, components are Server Components by default. Only add 'use client' when you need interactivity. Starting with Client Components and converting later is backwards and wastes bundle size.

**Incorrect (unnecessary client component):**

```tsx
'use client'  // Unnecessary - no interactivity

import { formatDate } from '@/lib/utils'

export function ArticleCard({ article }: { article: Article }) {
  return (
    <article>
      <h2>{article.title}</h2>
      <time>{formatDate(article.publishedAt)}</time>
      <p>{article.excerpt}</p>
    </article>
  )
}
// Entire component + formatDate shipped to client
```

**Correct (server component by default):**

```tsx
// No directive needed - Server Component by default
import { formatDate } from '@/lib/utils'

export function ArticleCard({ article }: { article: Article }) {
  return (
    <article>
      <h2>{article.title}</h2>
      <time>{formatDate(article.publishedAt)}</time>
      <p>{article.excerpt}</p>
    </article>
  )
}
// Renders on server, only HTML sent to client
```

**When to add 'use client':**
- Using hooks (useState, useEffect, useContext)
- Using browser APIs (window, document, localStorage)
- Adding event handlers (onClick, onChange)
- Using client-only libraries

Reference: [Server Components](https://react.dev/reference/rsc/server-components)
