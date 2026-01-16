---
title: Attach Event Handlers Only in Client Components
impact: HIGH
impactDescription: Event handlers require JavaScript runtime; keeping them in Client Components ensures they work and prevents hydration mismatches
tags: client, events, onClick, interactivity
---

## Attach Event Handlers Only in Client Components

Event handlers like `onClick`, `onChange`, and `onSubmit` require JavaScript on the client. Attempting to use them in Server Components silently fails or causes hydration errors. Extract interactive elements into Client Components.

**Incorrect (handlers in Server Component):**

```typescript
// No 'use client' - this is a Server Component
export default async function ProductCard({ product }) {
  const handleAddToCart = () => {
    // ❌ This function never runs - no JS shipped
    console.log('Add to cart')
  }

  return (
    <div>
      <h2>{product.name}</h2>
      {/* ❌ onClick ignored in Server Component */}
      <button onClick={handleAddToCart}>Add to Cart</button>
    </div>
  )
}
```

**Correct (handlers in Client Component):**

```typescript
// Server Component handles data and layout
export default async function ProductCard({ product }) {
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      {/* Delegate interactivity to Client Component */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}
```

```typescript
// components/AddToCartButton.tsx
'use client'

import { useCart } from '@/hooks/useCart'

export default function AddToCartButton({ productId }: { productId: string }) {
  const { addItem, isPending } = useCart()

  return (
    <button
      onClick={() => addItem(productId)}
      disabled={isPending}
    >
      {isPending ? 'Adding...' : 'Add to Cart'}
    </button>
  )
}
```

**Pattern with Server Actions (hybrid):**

```typescript
// Server Component with Server Action form
import { addToCart } from '@/actions/cart'

export default async function ProductCard({ product }) {
  return (
    <div>
      <h2>{product.name}</h2>
      {/* Form action works without client JS (progressive enhancement) */}
      <form action={addToCart}>
        <input type="hidden" name="productId" value={product.id} />
        <button type="submit">Add to Cart</button>
      </form>
    </div>
  )
}
```

```typescript
// actions/cart.ts
'use server'

export async function addToCart(formData: FormData) {
  const productId = formData.get('productId')
  await db.cart.add({ productId, userId: getCurrentUser().id })
  revalidatePath('/cart')
}
```

**Interactive events requiring 'use client':**
- `onClick`, `onDoubleClick`
- `onChange`, `onInput`, `onBlur`, `onFocus`
- `onSubmit` (unless using form action)
- `onKeyDown`, `onKeyUp`
- `onMouseEnter`, `onMouseLeave`
- `onScroll`, `onResize`

**When NOT to use Client Components:**
- Form submissions (use Server Actions with `action`)
- Links (use `<Link>` component)
- Simple navigation

Reference: [Next.js Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components)
