---
title: Leverage Automatic Request Deduplication
impact: MEDIUM
impactDescription: Same fetch URL called multiple times results in single network request; eliminates redundant API calls across component tree
tags: cache, deduplication, fetch, memoization
---

## Leverage Automatic Request Deduplication

Next.js automatically deduplicates `fetch` requests with identical URLs and options during a single render pass. Multiple components can fetch the same data independently without causing redundant network requests.

**Incorrect (manual deduplication):**

```typescript
// ❌ Over-engineered: passing data through props to avoid "duplicate" fetches
export default async function Layout({ children }) {
  const user = await getUser()
  const settings = await getSettings()

  return (
    <div>
      <Header user={user} settings={settings} />
      <Sidebar user={user} />
      <main>{children}</main>
      <Footer settings={settings} />
    </div>
  )
}
```

**Correct (let Next.js deduplicate):**

```typescript
// ✓ Each component fetches what it needs
// Next.js deduplicates identical requests automatically
export default function Layout({ children }) {
  return (
    <div>
      <Header />
      <Sidebar />
      <main>{children}</main>
      <Footer />
    </div>
  )
}

async function Header() {
  const user = await getUser()    // Request #1
  const settings = await getSettings()
  return <header>{user.name}</header>
}

async function Sidebar() {
  const user = await getUser()    // Deduped to request #1
  return <nav>{user.role}</nav>
}

async function Footer() {
  const settings = await getSettings()  // Deduped
  return <footer>{settings.copyright}</footer>
}
```

**How deduplication works:**

```typescript
// lib/data.ts
export async function getUser() {
  // Same URL + options = same cache key
  const res = await fetch('https://api.example.com/user', {
    next: { revalidate: 3600 }
  })
  return res.json()
}

// Component A calls getUser() → network request
// Component B calls getUser() → returns cached result (same render)
// Component C calls getUser() → returns cached result (same render)
// Total network requests: 1
```

**Deduplication boundaries:**
- Works within a single server render pass
- Works across components in same request
- Does NOT work across different page navigations
- Does NOT work for POST requests (only GET)

**When deduplication doesn't apply:**

```typescript
// Different URLs = different requests
await fetch('/api/user/123')
await fetch('/api/user/456')  // Not deduped - different URL

// Different options = different requests
await fetch('/api/user', { next: { revalidate: 60 } })
await fetch('/api/user', { next: { revalidate: 3600 } })  // Not deduped

// POST requests are never deduped
await fetch('/api/user', { method: 'POST' })
await fetch('/api/user', { method: 'POST' })  // Both execute
```

**When NOT to rely on deduplication:**
- Requests have different cache configurations
- POST/PUT/DELETE requests (mutations)
- Cross-request data sharing (use proper caching)

Reference: [Next.js Request Memoization](https://nextjs.org/docs/app/building-your-application/caching#request-memoization)
