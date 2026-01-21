---
title: Use generateMetadata for Dynamic Metadata
impact: MEDIUM
impactDescription: dynamic SEO, social sharing optimization
tags: meta, generateMetadata, seo, dynamic
---

## Use generateMetadata for Dynamic Metadata

Export `generateMetadata` to create dynamic metadata based on route parameters and fetched data. This enables unique titles, descriptions, and OpenGraph images per page.

**Incorrect (static metadata for dynamic pages):**

```typescript
// app/product/[id]/page.tsx
export const metadata = {
  title: 'Product',  // Same for all products!
  description: 'View product details'
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}
```

**Correct (dynamic metadata per product):**

```typescript
// app/product/[id]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await getProduct(params.id)

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [
        {
          url: product.image,
          width: 1200,
          height: 630,
          alt: product.name
        }
      ]
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description,
      images: [product.image]
    }
  }
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)  // Deduplicated with cache()
  return <ProductDetails product={product} />
}
```

**Note:** Next.js automatically deduplicates `fetch` calls, so `generateMetadata` and the page can call `getProduct` without duplicate requests.
