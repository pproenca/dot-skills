---
title: Dynamic routes export `generateMetadata` so each variant gets per-resource title/description/OG image
impact: MEDIUM
impactDescription: per-resource SEO and social sharing instead of one generic title across all dynamic routes
tags: meta, generate-metadata, per-resource-seo, dynamic-meta
---

## Dynamic routes export `generateMetadata` so each variant gets per-resource title/description/OG image

**Pattern intent:** a `/product/[id]` page must surface unique title, description, and OG image per product. The static `export const metadata` cannot read route params; only `generateMetadata({ params })` can.

### Shapes to recognize

- `export const metadata = { title: 'Product' }` in a dynamic route — every product gets the same `<title>` in the HTML head.
- A `generateMetadata` that ignores `params` and returns a static value — same problem with extra ceremony.
- A `generateMetadata` that calls a different fetcher than the page itself — duplicate fetches; should share a `cache()`-wrapped fetcher.
- A `<title>{post.title}</title>` rendered inline in the page body — works for React 19 head-hoisting, but Next.js framework convention uses `generateMetadata` for crawler-safe metadata.
- A workaround setting `document.title` in a `useEffect` — client-side; SEO crawlers never see it.

The canonical resolution: `export async function generateMetadata({ params }): Promise<Metadata>` that fetches the same data the page does (via a `cache()`-wrapped getter — Next.js dedupes) and returns the per-resource fields.

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
