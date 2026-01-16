---
title: Use next/link for Client-Side Navigation
impact: MEDIUM
impactDescription: instant navigation with automatic prefetching
tags: route, navigation, prefetching, link, performance
---

## Use next/link for Client-Side Navigation

The Link component enables client-side navigation without full page reloads. It automatically prefetches linked pages in the viewport, making subsequent navigation feel instant. Using anchor tags forces a full page reload, losing client state and re-downloading assets.

**Incorrect (anchor tag causes full page reload):**

```tsx
export function NavigationMenu() {
  return (
    <nav>
      <a href="/dashboard">Dashboard</a>  {/* Full reload, loses state */}
      <a href="/settings">Settings</a>
      <a href="/analytics">Analytics</a>
    </nav>
  )
}
// Each click reloads entire page, re-executes JavaScript, resets scroll
```

**Correct (Link enables instant navigation):**

```tsx
import Link from 'next/link'

export function NavigationMenu() {
  return (
    <nav>
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/settings">Settings</Link>
      <Link href="/analytics">Analytics</Link>
    </nav>
  )
}
// Client-side navigation preserves state, prefetched pages load instantly
```

**With prefetch control for less critical links:**

```tsx
import Link from 'next/link'

export function NavigationMenu() {
  return (
    <nav>
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/settings" prefetch={false}>Settings</Link>  {/* Less visited */}
      <Link href="/admin" prefetch={false}>Admin</Link>  {/* Rarely used */}
    </nav>
  )
}
// Disable prefetch for infrequently visited pages to save bandwidth
```

**When to use anchor tags:**
- External links to other domains
- Download links with the download attribute
- Links that intentionally need a full reload

Reference: [Link Component](https://nextjs.org/docs/app/api-reference/components/link)
