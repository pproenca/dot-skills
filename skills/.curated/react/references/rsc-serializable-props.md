---
title: Pass Only Serializable Props to Client Components
impact: HIGH
impactDescription: prevents runtime errors, ensures correct hydration
tags: rsc, serializable, props, boundary
---

## Pass Only Serializable Props to Client Components

Props passed from Server to Client Components must be serializable through the RSC wire format. Regular functions and class instances cannot cross the boundary; native data types like `Date`, `Map`, `Set`, `BigInt`, `Promise`, and typed arrays can.

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
