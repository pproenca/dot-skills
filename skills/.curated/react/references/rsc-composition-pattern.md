---
title: Server content reaches inside a Client Component via `children` or named slots, not by being imported
impact: HIGH
impactDescription: maintains server rendering for static subtrees that sit inside a client-interactive wrapper
tags: rsc, composition, children-slot, server-inside-client
---

## Server content reaches inside a Client Component via `children` or named slots, not by being imported

**Pattern intent:** a Client Component (modal, accordion, sidebar, tab strip) that wraps static content should accept that content as `children`/slot props rendered from a Server Component parent — not import the static content directly. Direct imports across the boundary force the imported tree onto the client.

### Shapes to recognize

- A `'use client'` modal imports `<ProductDescription>` directly — `ProductDescription` is now bundled to the client even though it was meant to stay on the server.
- An accordion / tab strip / drawer that conditionally renders an imported Server-Component-shaped child — the child renders client-side instead.
- A layout shell that accepts no `children` and instead imports every section by name — every section becomes client-rendered.
- Workaround: the author duplicates the static content into two components (one for SSR, one for client) — maintenance burden, drift risk.
- Workaround: dynamic `import()` inside the Client Component to "defer" the import — works for code-splitting, doesn't help with the SSR/RSC distinction.

The canonical resolution: the Client Component accepts `children: ReactNode` (or named slots like `header`/`sidebar`/`main`); a Server Component parent provides the slot content. Static content stays server-rendered; interactivity stays in the wrapper.

**Incorrect (importing Server Component in Client):**

```typescript
// components/Accordion.tsx
'use client'

import { ServerContent } from './ServerContent'  // ❌ Forces client rendering

export function Accordion() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && <ServerContent />}  {/* Now client-rendered */}
    </div>
  )
}
```

**Correct (composition with children):**

```typescript
// components/Accordion.tsx
'use client'

import { ReactNode, useState } from 'react'

export function Accordion({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children}
    </div>
  )
}

// page.tsx (Server Component)
export default async function Page() {
  const data = await fetchData()

  return (
    <Accordion>
      <ServerContent data={data} />  {/* Stays server-rendered */}
    </Accordion>
  )
}
```

**Alternative (named slots):**

```typescript
// components/Layout.tsx
'use client'

export function Layout({
  header,
  sidebar,
  main
}: {
  header: ReactNode
  sidebar: ReactNode
  main: ReactNode
}) {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  // Client logic for layout

  return (
    <div>
      {header}
      {sidebarOpen && sidebar}
      {main}
    </div>
  )
}
// All slots can be Server Components
```
