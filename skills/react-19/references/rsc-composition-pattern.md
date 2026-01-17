---
title: Use Composition to Mix Server and Client Components
impact: HIGH
impactDescription: maintains server rendering for static content
tags: rsc, composition, children, pattern
---

## Use Composition to Mix Server and Client Components

Pass Server Components as children or props to Client Components. This keeps server content server-rendered while adding client interactivity.

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
