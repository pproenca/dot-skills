---
title: Virtualize Long Lists with TanStack Virtual
impact: HIGH
impactDescription: O(n) to O(1) DOM nodes, 10-100x improvement for large lists
tags: render, virtualization, tanstack-virtual, lists, dom
---

## Virtualize Long Lists with TanStack Virtual

Rendering 1000+ items creates 1000+ DOM nodes that consume memory, slow initial paint, and degrade scroll performance. Virtualization renders only the items visible in the viewport, keeping DOM node count constant regardless of list size.

**Incorrect (renders all 5000 DOM nodes upfront):**

```tsx
interface Product {
  id: string
  name: string
  price: number
}

function ProductCatalog({ products }: { products: Product[] }) {
  return (
    <div className="product-list" style={{ height: 600, overflow: "auto" }}>
      {products.map((product) => (
        <div key={product.id} className="product-row" style={{ height: 48 }}>
          <span>{product.name}</span>
          <span>${product.price.toFixed(2)}</span>
        </div>
      ))}
      {/* 5000 products = 5000 DOM nodes mounted simultaneously */}
    </div>
  )
}
```

**Correct (renders only visible DOM nodes):**

```tsx
import { useVirtualizer } from "@tanstack/react-virtual"
import { useRef } from "react"

interface Product {
  id: string
  name: string
  price: number
}

function ProductCatalog({ products }: { products: Product[] }) {
  const scrollContainerRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => scrollContainerRef.current,
    estimateSize: () => 48, // estimated row height in pixels
  })

  return (
    <div ref={scrollContainerRef} style={{ height: 600, overflow: "auto" }}>
      <div style={{ height: virtualizer.getTotalSize(), position: "relative" }}>
        {virtualizer.getVirtualItems().map((virtualRow) => {
          const product = products[virtualRow.index]
          return (
            <div
              key={product.id}
              className="product-row"
              style={{
                position: "absolute",
                top: virtualRow.start,
                height: virtualRow.size,
                width: "100%",
              }}
            >
              <span>{product.name}</span>
              <span>${product.price.toFixed(2)}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
```

Reference: [TanStack Virtual Documentation](https://tanstack.com/virtual/latest)
