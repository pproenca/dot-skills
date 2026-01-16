---
title: Isolate Interactivity into Client Islands
impact: HIGH
impactDescription: minimizes client bundle, maximizes server rendering
tags: server, client, islands, composition, bundle-size
---

## Isolate Interactivity into Client Islands

Don't mark entire sections as 'use client'. Extract only the interactive parts into small Client Components while keeping the rest as Server Components.

**Incorrect (entire section is client):**

```tsx
'use client'

export function ProductSection({ products }: { products: Product[] }) {
  const [sortBy, setSortBy] = useState('price')

  const sorted = [...products].sort((a, b) => a[sortBy] - b[sortBy])

  return (
    <section>
      <h2>Featured Products</h2>
      <SortDropdown value={sortBy} onChange={setSortBy} />
      <div className="grid">
        {sorted.map(p => (
          <ProductCard key={p.id} product={p} />  {/* Static, but bundled */}
        ))}
      </div>
    </section>
  )
}
// Everything ships to client, including ProductCard
```

**Correct (only interactive part is client):**

```tsx
// Server Component - renders on server
export function ProductSection({ products }: { products: Product[] }) {
  return (
    <section>
      <h2>Featured Products</h2>
      <SortableProductGrid products={products} />
    </section>
  )
}

// Client island - only the interactive logic
'use client'
function SortableProductGrid({ products }: { products: Product[] }) {
  const [sortBy, setSortBy] = useState('price')
  const sorted = [...products].sort((a, b) => a[sortBy] - b[sortBy])

  return (
    <>
      <SortDropdown value={sortBy} onChange={setSortBy} />
      <div className="grid">
        {sorted.map(p => (
          <ProductCard key={p.id} product={p} />
        ))}
      </div>
    </>
  )
}

// Server Component - can be composed inside client
function ProductCard({ product }: { product: Product }) {
  return (
    <article>
      <img src={product.image} alt={product.name} />
      <h3>{product.name}</h3>
      <AddToCartButton productId={product.id} />  {/* Another small island */}
    </article>
  )
}
```

**Guidelines:**
- Static content = Server Component
- Event handlers = Client Component
- Keep client islands as small as possible

Reference: [Composing Client and Server Components](https://react.dev/reference/rsc/use-client#how-use-client-marks-client-code)
