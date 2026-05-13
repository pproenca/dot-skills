---
title: Audit `'use client'` placement across the route tree — demote files (or whole subtrees) that don't need the client
impact: HIGH
impactDescription: shrinks client bundle dramatically (often double-digit KB), allows server rendering of large subtrees, removes hydration cost from sections that have no interactivity
tags: cross, use-client, boundary-placement, route-tree, bundle-size
---

## Audit `'use client'` placement across the route tree — demote files (or whole subtrees) that don't need the client

**This is a cross-cutting rule.** It surfaces when you map *every* `'use client'` directive against the route tree and look for placements that drag in more JS than they need to.

### Shapes to recognize

- A `layout.tsx` marked `'use client'` because one descendant button needs interactivity — the *entire route group* is now client-rendered. Lift the directive down to the interactive leaf.
- A `'use client'` file whose only "hook" is `useId` for an ARIA attribute on otherwise-static markup — `useId` is SSR-safe; the directive is unnecessary.
- A `'use client'` page that imports `<Header>`, `<Footer>`, `<Sidebar>`, all of which are static — those components are now bundled to the client; should be passed as `children` from a Server Component parent.
- A `'use client'` file using `useState` to hold a value initialized once and never updated by an event — you wanted a constant; the directive is vestigial.
- Two sibling routes, one Server Component and one Client Component, sharing a heavy component — the heavy component is bundled into the client side anyway because of the Client sibling. Either split the shared component or refactor both routes.
- A custom hook (`use-*.ts`) that's imported by both a Server Component (via re-export) and a Client Component — likely a server/client confusion; the hook should be split into a server function and a client hook.

### Detection procedure

1. List every file with `'use client'` in the inventory.
2. Map the route tree visually: `app/` → which `layout.tsx`s have `'use client'`? Which `page.tsx`s do?
3. For each `'use client'` placement, classify by why it's there:
   - **Real interactivity:** event handlers tied to state changes, refs to DOM measurement, browser-only APIs.
   - **Hooks that require client:** `useEffect`, `useLayoutEffect`, `useReducer` with side-effects, `useSyncExternalStore`, anything from `react-dom`.
   - **Nothing requires client** — directive is vestigial.
   - **Propagation up:** the directive is on a layout/page but the interactivity is in a leaf; lift the directive down.
4. For each non-real placement, propose: drop the directive, or split into a static parent + a small client island.

### Multi-file example

**Incorrect (a layout marked client because of one button, dragging four imported components onto the client):**

```typescript
// app/dashboard/layout.tsx
'use client'

import { Sidebar } from '@/components/Sidebar'        // static, no interactivity
import { Header } from '@/components/Header'          // static
import { Footer } from '@/components/Footer'          // static
import { ThemeToggle } from '@/components/ThemeToggle' // the only interactive bit

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <Header />
      <Sidebar />
      <main>{children}</main>
      <ThemeToggle />  // the reason 'use client' is here
      <Footer />
    </div>
  )
}
// Result: Header, Sidebar, Footer, and every descendant of children are now in
// the client bundle and pay hydration cost — for nothing.
```

**Correct (Server Component layout, client island only where it's needed):**

```typescript
// app/dashboard/layout.tsx (Server Component — directive removed)
import { Sidebar } from '@/components/Sidebar'
import { Header } from '@/components/Header'
import { Footer } from '@/components/Footer'
import { ThemeToggle } from '@/components/ThemeToggle' // imports a thin client island

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <Header />
      <Sidebar />
      <main>{children}</main>
      <ThemeToggle />
      <Footer />
    </div>
  )
}

// components/ThemeToggle.tsx (Client Component — the small interactive leaf)
'use client'

import { useState } from 'react'

export function ThemeToggle() {
  const [dark, setDark] = useState(false)
  return <button onClick={() => setDark(!dark)}>{dark ? '☀️' : '🌙'}</button>
}
```

**Cross-file observation (what the audit reports):**

> 6 of the 14 `'use client'` files have no client-only requirement at their current placement. 3 are layouts that should be Server Components with client islands inside; 2 use only `useId`; 1 holds a `useState` that's never updated.
> Demoting drops ~62 KB from the dashboard route's First Load JS and removes hydration cost for ~22% of the route tree.

### When NOT to demote

- The file uses `useEffect`, `useLayoutEffect`, `useSyncExternalStore`, or a DOM ref — those are real client requirements.
- The file uses `useState` and *does* update it from an event handler or callback — even if the JSX looks static at a glance.
- The file is imported by a Client Component context provider that needs to wrap the children — splitting will break the context.
- Removing `'use client'` from a layout removes a context provider that descendants depend on.

### Risk before demoting

- Demotion changes import semantics: a Server Component cannot import a Client Component freely (and vice-versa). Verify the import graph still types after demoting.
- The split case (Server parent + Client island) is the safer refactor when in doubt — it preserves interactivity exactly while moving the static mass off the client.
- Always re-test the affected route(s) with Network → "Disable JS" to confirm the server-rendered version still works.

Reference: [Server and Client Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components), [Use Client directive](https://nextjs.org/docs/app/api-reference/directives/use-client)
