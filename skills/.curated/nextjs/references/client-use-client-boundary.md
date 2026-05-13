---
title: Push the `'use client'` directive down to the interactive leaf — not up at the route/layout
impact: LOW-MEDIUM
impactDescription: shrinks client bundle to only the interactive islands; everything above the boundary stays server-rendered with zero client JS
tags: client, boundary-placement, leaf-client, no-route-client
---

## Push the `'use client'` directive down to the interactive leaf — not up at the route/layout

**Pattern intent:** `'use client'` marks the boundary below which everything is shipped to the client. Placing it at the route or layout level drags the entire subtree onto the client, even pieces that don't need any interactivity.

### Shapes to recognize

- `'use client'` at the top of `page.tsx` / `layout.tsx`, with most of the body being static markup and only one or two interactive leaves.
- A `<ProductPage>` Client Component receiving `{ product, reviews, related, recommendations }` — most of those exist only to render static children that don't need the client.
- A wrapper component is `'use client'` only because *one* descendant uses `useState` — the wrapper itself never needs the client.
- A `'use client'` layout toggling a sidebar — could be a static layout with a small client island for the sidebar toggle button.
- Heavy server-only data (large arrays, formatted HTML, image URLs) crossing the boundary because the boundary is too high — every byte gets serialized into the RSC payload.

The canonical resolution: keep `page.tsx` / `layout.tsx` as a Server Component; extract just the interactive part into a small Client Component; pass only the IDs/strings/handlers it needs. See also [`cross-boundary-coherence.md`](cross-boundary-coherence.md) for cross-cutting analysis across the route tree.

---

### In disguise — `'use client'` on a `layout.tsx` because of one interactive element three levels deep

The grep-friendly anti-pattern is `'use client'` at the top of `page.tsx`. The disguise is the directive on a *layout* — usually because the team added a theme toggle, a notification bell, or an auth-conditional element to the layout's `<header>` and didn't realize the whole subtree under the layout is now a Client Component.

**Incorrect — in disguise (layout marked client for a single interactive header element):**

```typescript
// app/dashboard/layout.tsx
'use client'  // ❌ entire dashboard route group is now client-rendered

import { useState } from 'react'
import { Sidebar } from '@/components/Sidebar'           // static, doesn't need client
import { DashboardHeader } from '@/components/DashboardHeader'  // mostly static
import { Footer } from '@/components/Footer'             // static

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [notifOpen, setNotifOpen] = useState(false) // the only reason 'use client' is here

  return (
    <div>
      <DashboardHeader>
        <button onClick={() => setNotifOpen(!notifOpen)}>🔔</button>
        {notifOpen && <NotificationsDropdown />}
      </DashboardHeader>
      <Sidebar />
      <main>{children}</main>
      <Footer />
    </div>
  )
}
```

Cost: every page rendered inside `/dashboard/*` ships under a client-rendered layout. The header, sidebar, and footer are all bundled to the client. Hydration cost compounds across the route group.

**Correct — layout stays server, notification island is the only client part:**

```typescript
// app/dashboard/layout.tsx (Server Component — no directive)
import { Sidebar } from '@/components/Sidebar'
import { DashboardHeader } from '@/components/DashboardHeader'
import { Footer } from '@/components/Footer'
import { NotificationsButton } from './NotificationsButton'

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <DashboardHeader>
        <NotificationsButton />
      </DashboardHeader>
      <Sidebar />
      <main>{children}</main>
      <Footer />
    </div>
  )
}

// app/dashboard/NotificationsButton.tsx — only the leaf is client
'use client'
import { useState } from 'react'

export function NotificationsButton() {
  const [open, setOpen] = useState(false)
  return (
    <>
      <button onClick={() => setOpen(!open)}>🔔</button>
      {open && <NotificationsDropdown />}
    </>
  )
}
```

The layout, sidebar, header shell, and footer stay on the server. Only the bell button hydrates. For complex apps this can drop dozens of KB from the route group's First Load JS.

This is also a common Category 9 finding — see [`cross-boundary-coherence.md`](cross-boundary-coherence.md) for sweeping the whole route tree.

**Incorrect (entire page as Client Component):**

```typescript
'use client'

export default function ProductPage({ product }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>  {/* Static, doesn't need client */}
      <img src={product.image} />   {/* Static, doesn't need client */}
      <Reviews reviews={product.reviews} />  {/* Static, doesn't need client */}

      {/* Only this needs interactivity */}
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(product.id, quantity)}>Add to Cart</button>
    </div>
  )
}
// Entire page hydrates on client
```

**Correct (minimal Client Component):**

```typescript
// app/product/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <img src={product.image} />
      <Reviews reviews={product.reviews} />

      {/* Only interactive part is client */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}

// components/AddToCartButton.tsx
'use client'

import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(productId, quantity)}>Add to Cart</button>
    </div>
  )
}
// Only button hydrates, rest is static HTML
```
