---
title: Pass Only Serializable Props to Client Components
impact: HIGH
impactDescription: prevents runtime errors, ensures correct hydration
tags: rsc, serializable, props, boundary
---

## Pass Only Serializable Props to Client Components

Props passed from Server to Client Components must be JSON-serializable. Functions, classes, and complex objects cannot cross the boundary.

**Incorrect (non-serializable props):**

```typescript
// Server Component
export function ProductPage({ product }) {
  function handleAddToCart() {  // Function - not serializable
    console.log('Added!')
  }

  return (
    <ProductCard
      product={product}
      onAdd={handleAddToCart}      // ❌ Function
      formatter={new Intl.NumberFormat()}  // ❌ Class instance
      today={new Date()}           // ❌ Date object
    />
  )
}
// Error: Functions cannot be passed to Client Components
```

**Correct (serializable props only):**

```typescript
// Server Component
export function ProductPage({ product }) {
  return (
    <ProductCard
      productId={product.id}      // ✅ String
      productName={product.name}  // ✅ String
      price={product.price}       // ✅ Number
      tags={product.tags}         // ✅ Array of primitives
      metadata={{                 // ✅ Plain object
        sku: product.sku,
        inStock: product.inStock
      }}
      createdAt={product.createdAt.toISOString()}  // ✅ String, not Date
    />
  )
}

// components/ProductCard.tsx
'use client'

export function ProductCard({ productId, productName, price }) {
  function handleAddToCart() {
    // Define action in Client Component
    addToCart(productId)
  }

  return (
    <button onClick={handleAddToCart}>
      Add {productName} - ${price}
    </button>
  )
}
```

**Serializable types:** strings, numbers, booleans, null, arrays, plain objects, Dates (as ISO strings).
