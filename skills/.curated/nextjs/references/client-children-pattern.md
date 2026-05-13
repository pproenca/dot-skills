---
title: Server content reaches inside a Client Component via `children` or named slots — not by being imported
impact: LOW-MEDIUM
impactDescription: keeps static subtrees server-rendered when wrapped by a client-interactive parent; only the parent's interactivity ships to the client
tags: client, children-slot, composition, server-inside-client
---

## Server content reaches inside a Client Component via `children` or named slots — not by being imported

**Pattern intent:** a Client Component (modal, accordion, sidebar, tab strip) that wraps static content should accept that content as `children`/slot props rendered from a Server Component parent — not import the static content directly. Direct imports across the boundary force the imported tree onto the client.

### Shapes to recognize

- A `'use client'` modal imports `<ProductDescription>` directly — `ProductDescription` is now bundled to the client even though it was meant to stay on the server.
- An accordion / tab strip / drawer that conditionally renders an imported Server-Component-shaped child — the child renders client-side instead.
- A layout shell that accepts no `children` and instead imports every section by name — every section becomes client-rendered.
- Workaround: the author duplicates the static content into two components (one for SSR, one for client) — maintenance burden, drift risk.
- Workaround: dynamic `import()` inside the Client Component to "defer" the import — works for code-splitting, doesn't help with the SSR/RSC distinction.

The canonical resolution: the Client Component accepts `children: ReactNode` (or named slots like `header`/`sidebar`/`main`); a Server Component parent provides the slot content. Static content stays server-rendered; interactivity stays in the wrapper.

**Incorrect (converting children to Client Components):**

```typescript
// components/Modal.tsx
'use client'

import { ProductDetails } from './ProductDetails'  // Forces this to be client

export function Modal({ productId }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button onClick={() => setIsOpen(true)}>View Details</button>
      {isOpen && (
        <div className="modal">
          <ProductDetails productId={productId} />  {/* Now client-rendered */}
        </div>
      )}
    </>
  )
}
```

**Correct (children pattern keeps server content):**

```typescript
// components/Modal.tsx
'use client'

import { ReactNode, useState } from 'react'

export function Modal({ children, trigger }: { children: ReactNode; trigger: string }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button onClick={() => setIsOpen(true)}>{trigger}</button>
      {isOpen && (
        <div className="modal">
          <button onClick={() => setIsOpen(false)}>Close</button>
          {children}  {/* Server Component passed as children */}
        </div>
      )}
    </>
  )
}

// app/product/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <Modal trigger="View Details">
      <ProductDetails product={product} />  {/* Stays server-rendered */}
    </Modal>
  )
}
```

**Benefits:**
- `ProductDetails` remains a Server Component
- Data fetching happens on server
- Only Modal interactivity ships to client
