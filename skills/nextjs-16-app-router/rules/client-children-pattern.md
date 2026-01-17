---
title: Pass Server Components as Children to Client Components
impact: LOW-MEDIUM
impactDescription: keeps static content on server, reduces bundle
tags: client, children, composition, server-components
---

## Pass Server Components as Children to Client Components

Client Components can render Server Components passed as children. This keeps static content server-rendered while adding interactivity.

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
