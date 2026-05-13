---
title: Only data that the RSC wire format can encode crosses the server→client boundary
impact: HIGH
impactDescription: prevents runtime errors at the boundary, ensures correct hydration; non-serializable values must be replaced with serializable equivalents or moved
tags: rsc, serializable-props, rsc-wire-format, server-actions
---

## Only data that the RSC wire format can encode crosses the server→client boundary

**Pattern intent:** the props passed from a Server Component to a Client Component travel through the RSC wire format. Plain functions, class instances, and DOM nodes cannot ride that wire. Behavior that needs to cross either rides as data (and the behavior is reconstructed on the client) or rides as a Server Action.

### Shapes to recognize

- Passing a plain inline `function handleClick() {...}` defined in a Server Component as a prop to a Client Component — runtime error.
- Passing `new SomeClass(...)` (formatter, validator, computed object) — class instances aren't serializable.
- Passing `console.log` / built-in functions / a bound method — none of those are serializable.
- Passing a closure over server-only secrets ("just `tokens` from the request") into a Client Component "so the child can use them" — even if it serialized, it would leak secrets.
- Passing a Date as `date.toISOString()` "to be safe" — the RSC wire format supports `Date` natively; the string conversion adds an unnecessary parse step on the client.
- Passing `JSON.parse(JSON.stringify(complexObject))` "to be safe" — strips `Date`/`Map`/`Set` and signals the author didn't trust the wire.

The canonical resolution: replace plain functions with **Server Actions** (`'use server'` exports), replace class instances with their underlying data, and trust the wire format for `Date`/`Map`/`Set`/`BigInt`/`Promise`/typed arrays.

**Incorrect (non-serializable props):**

```typescript
// Server Component
class PriceFormatter {
  format(price: number) { return `$${price.toFixed(2)}` }
}

export function ProductPage({ product }: { product: Product }) {
  function handleAddToCart() {  // Function - not serializable
    console.log('Added!')
  }

  return (
    <ProductCard
      product={product}
      onAdd={handleAddToCart}            // ❌ Plain function (not 'use server')
      formatter={new PriceFormatter()}   // ❌ Class instance
      logger={console.log}               // ❌ Built-in function
    />
  )
}
// Error: Functions and class instances cannot be passed to Client Components
```

**Correct (serializable props only):**

```typescript
// Server Component
export function ProductPage({ product }: { product: Product }) {
  return (
    <ProductCard
      productId={product.id}              // ✅ String
      productName={product.name}          // ✅ String
      price={product.price}               // ✅ Number
      tags={product.tags}                 // ✅ Array of primitives
      metadata={{                          // ✅ Plain object
        sku: product.sku,
        inStock: product.inStock
      }}
      createdAt={product.createdAt}       // ✅ Date — wire format supports it
      variants={new Map(product.variants)} // ✅ Map — wire format supports it
    />
  )
}

// components/ProductCard.tsx
'use client'

export function ProductCard({
  productId,
  productName,
  price,
  createdAt,
}: {
  productId: string
  productName: string
  price: number
  createdAt: Date
}) {
  function handleAddToCart() {
    // Define action in Client Component
    addToCart(productId)
  }

  return (
    <button onClick={handleAddToCart}>
      Add {productName} - ${price} (added {createdAt.toLocaleDateString()})
    </button>
  )
}
```

**Serializable types** (RSC wire format): strings, numbers, booleans, `null`, `undefined`, `BigInt`, arrays, plain objects, `Map`, `Set`, `Date`, typed arrays, `ArrayBuffer`, `Promise`, JSX elements, and Server Actions (functions in modules with `'use server'`). **Not serializable:** plain functions, class instances, symbols (except registered globals), and DOM nodes.

**Passing callbacks via Server Actions:**

```typescript
// actions.ts
'use server'

export async function addToCart(productId: string) {
  await db.cart.add({ productId })
}

// Server Component — passes server action as prop
import { addToCart } from './actions'

export function ProductPage({ product }: { product: Product }) {
  return (
    <ProductCard
      productId={product.id}
      onAdd={addToCart}  // ✅ Server Actions are serializable
    />
  )
}
```
