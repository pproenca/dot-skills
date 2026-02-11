---
title: Default to Server Components for New Code
impact: HIGH
impactDescription: 30-60% less client JavaScript for new features
tags: migrate, server-components, client-boundary, bundle-size
---

## Default to Server Components for New Code

New components should be Server Components unless they require interactivity, browser APIs, or stateful hooks. Adding `'use client'` by default sends code to the browser that never needed to leave the server, inflating bundle size and increasing time-to-interactive for every new feature.

**Incorrect (adding 'use client' by default to every new component):**

```tsx
// app/products/[id]/page.tsx
"use client"; // Forces entire page to be client-rendered

import { useState, useEffect } from "react";

export default function ProductPage({ params }: { params: { id: string } }) {
  const [product, setProduct] = useState<Product | null>(null);

  // Fetching on the client adds a waterfall: HTML → JS → fetch → render
  useEffect(() => {
    fetch(`/api/products/${params.id}`).then((r) => r.json()).then(setProduct);
  }, [params.id]);

  if (!product) return <LoadingSkeleton />;

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>{formatCurrency(product.price)}</span>
      <ProductReviews productId={product.id} />
      <AddToCartButton productId={product.id} />
    </div>
  );
}
```

**Correct (Server Component by default, 'use client' only for interactive leaf):**

```tsx
// app/products/[id]/page.tsx — Server Component, no directive needed
import { getProduct } from "@/lib/products";

export default async function ProductPage({ params }: { params: { id: string } }) {
  // Data fetched on the server — no client JS, no waterfall
  const product = await getProduct(params.id);

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>{formatCurrency(product.price)}</span>
      <ProductReviews productId={product.id} />
      <AddToCartButton productId={product.id} />
    </div>
  );
}

// components/AddToCartButton.tsx — only this leaf needs client JS
"use client";

import { useState } from "react";

export function AddToCartButton({ productId }: { productId: string }) {
  const [isAdding, setIsAdding] = useState(false);

  async function handleAdd() {
    setIsAdding(true);
    await addToCart(productId);
    setIsAdding(false);
  }

  return (
    <button onClick={handleAdd} disabled={isAdding}>
      {isAdding ? "Adding..." : "Add to Cart"}
    </button>
  );
}
```

Reference: [Server Components — React Docs](https://react.dev/reference/rsc/server-components)
