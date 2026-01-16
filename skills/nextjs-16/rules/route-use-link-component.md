---
title: Use Link Component for Client-Side Navigation
impact: MEDIUM
impactDescription: Automatic prefetching and client-side transitions; navigation feels instant (50-200ms) vs full page load (500ms+)
tags: route, Link, prefetch, navigation
---

## Use Link Component for Client-Side Navigation

The `<Link>` component enables client-side navigation with automatic prefetching. Pages load instantly because the JavaScript and data are fetched before the user clicks. Regular `<a>` tags cause full page reloads.

**Incorrect (regular anchor tags):**

```typescript
// ❌ Full page reload on every navigation
export default function Navigation() {
  return (
    <nav>
      <a href="/">Home</a>
      <a href="/about">About</a>
      <a href="/blog">Blog</a>
    </nav>
  )
}
// Each click: full page reload, re-download assets, re-execute JS
```

**Correct (Link component):**

```typescript
import Link from 'next/link'

export default function Navigation() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/about">About</Link>
      <Link href="/blog">Blog</Link>
    </nav>
  )
}
// Each click: instant navigation, only new content loads
```

**Prefetching behavior:**

```typescript
import Link from 'next/link'

// Default: prefetch when link enters viewport
<Link href="/dashboard">Dashboard</Link>

// Disable prefetch for rarely-visited pages
<Link href="/admin" prefetch={false}>Admin</Link>

// Explicit prefetch={true} for high-priority routes
<Link href="/checkout" prefetch={true}>Checkout</Link>
```

**Dynamic routes with Link:**

```typescript
import Link from 'next/link'

export default function ProductList({ products }) {
  return (
    <ul>
      {products.map(product => (
        <li key={product.id}>
          <Link href={`/products/${product.slug}`}>
            {product.name}
          </Link>
        </li>
      ))}
    </ul>
  )
}
```

**Programmatic navigation (when Link isn't suitable):**

```typescript
'use client'

import { useRouter } from 'next/navigation'

export default function SearchForm() {
  const router = useRouter()

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const query = new FormData(e.currentTarget).get('q')
    router.push(`/search?q=${query}`)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="q" placeholder="Search..." />
      <button type="submit">Search</button>
    </form>
  )
}
```

**When to use regular <a> tags:**
- External links (`href="https://example.com"`)
- Download links (`href="/file.pdf" download`)
- Anchor links on same page (`href="#section"`)

Reference: [Next.js Link Component](https://nextjs.org/docs/app/api-reference/components/link)
