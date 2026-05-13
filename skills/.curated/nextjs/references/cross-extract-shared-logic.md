---
title: Extract duplicated server-side fetchers/actions into a shared module
impact: HIGH
impactDescription: collapses 2+ near-identical server-side fetch or mutation shapes into one source of truth, eliminates drift between cached and uncached copies
tags: cross, duplication, shared-fetcher, server-action, refactor
---

## Extract duplicated server-side fetchers/actions into a shared module

**This is a cross-cutting rule.** It cannot be detected by reading a single file — you must read 2+ files and recognize the same fetcher or server-action shape repeating.

### Shapes to recognize

- Two or more Server Components running the same `await fetch('/api/...')` (or `await db.user.findUnique(...)`) with the same `next: { tags: [...] }` options — should be one cached fetcher.
- Two or more Server Actions doing the same mutation with subtly different `revalidateTag` / `revalidatePath` calls — should be one action plus a shared revalidation helper.
- Two `route.ts` handlers (`GET /api/users/[id]` and a `getUserHandler` used inside a Server Component) doing the same DB query — pick one to be canonical and call it from both.
- Two layouts/pages reading the same data with different caching strategies (one `'use cache'`, one plain `fetch`) — choose one and use it everywhere; the drift means stale-vs-fresh inconsistencies.
- A custom hook calling a route handler from the client, when a Server Action would deliver the same effect without the round-trip.

### Detection procedure

1. After completing Categories 1–8, list every `await fetch(`, `await db.`, `revalidateTag(` and `revalidatePath(` call in the inventory, grouped by what they hit.
2. For each group with 2+ members, ask: *would a single `getX = cache(async () => ...)` (or a single Server Action) eliminate the duplication?*
3. The threshold is **2 occurrences**, not 3 — by the time you have 3, the drift has already started.

### Multi-file example

**Incorrect (three Server Components, three near-identical fetches with caching drift):**

```typescript
// app/dashboard/page.tsx (Server Component)
export default async function Dashboard() {
  const session = await fetch('/api/session', { next: { tags: ['session'] } }).then(r => r.json())
  return <DashboardShell session={session} />
}

// app/billing/page.tsx (Server Component) — same fetch, no tag, different freshness
export default async function Billing() {
  const session = await fetch('/api/session', { cache: 'no-store' }).then(r => r.json())
  return <BillingPage session={session} />
}

// app/(profile)/layout.tsx (Server Component) — third copy, third caching policy
export default async function ProfileLayout({ children }: { children: React.ReactNode }) {
  const session = await fetch('/api/session').then(r => r.json())  // default cache
  return <>{session ? children : <SignIn />}</>
}
```

Three routes; three caching policies for the same data; tag-invalidating one doesn't reach the others.

**Correct (one cached fetcher, three callers with consistent semantics):**

```typescript
// lib/session.ts
import { cache } from 'react'
import { unstable_cache } from 'next/cache'

export const getSession = cache(async () => {
  return unstable_cache(
    async () => fetch('/api/session').then(r => r.json()),
    ['session'],
    { tags: ['session'], revalidate: 60 }
  )()
})

// app/dashboard/page.tsx
import { getSession } from '@/lib/session'
export default async function Dashboard() {
  const session = await getSession()
  return <DashboardShell session={session} />
}

// app/billing/page.tsx — identical caller
import { getSession } from '@/lib/session'
export default async function Billing() {
  const session = await getSession()
  return <BillingPage session={session} />
}

// app/(profile)/layout.tsx — same
import { getSession } from '@/lib/session'
export default async function ProfileLayout({ children }) {
  const session = await getSession()
  return <>{session ? children : <SignIn />}</>
}
```

One module owns the cache semantics. `revalidateTag('session')` invalidates everyone. `react.cache` dedupes within a request; `unstable_cache` persists across requests.

### When NOT to extract

- The two fetchers happen to hit the same endpoint but want different caching policies *on purpose* (a public page wants long cache, an admin page wants no-store). Document the divergence; don't collapse.
- One caller is at the edge (proxy.ts), one is in a Server Component — the abstraction boundary is different.
- The duplication is two occurrences of trivial code (one-line fetch). Wait for the third.

### Risk before extracting

- If any caller exports its result to a Client Component, the result must remain serializable through the RSC wire format.
- Tag changes are global — once you adopt a shared tag, every action that invalidates the data must use it.

Reference: [Data Fetching, Caching, and Revalidating](https://nextjs.org/docs/app/building-your-application/caching)
