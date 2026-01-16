---
title: Use generateMetadata for Dynamic SEO
impact: LOW
impactDescription: 2-3× better click-through rates with accurate page metadata
tags: advanced, metadata, seo, open-graph
---

## Use generateMetadata for Dynamic SEO

Static metadata objects cannot include dynamic content like product names or article titles. Using `generateMetadata` allows you to fetch data and generate accurate metadata per page, improving search engine indexing and social media previews with the correct titles, descriptions, and images.

**Incorrect (static metadata ignores page content):**

```tsx
// app/products/[slug]/page.tsx
export const metadata = {
  title: 'Product Details',
  description: 'View product information',
  // Generic metadata - search engines see same title for every product
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await getProduct(slug)
  return <ProductDetails product={product} />
}
```

**Correct (dynamic metadata matches page content):**

```tsx
// app/products/[slug]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>
}): Promise<Metadata> {
  const { slug } = await params
  const product = await getProduct(slug)

  return {
    title: `${product.name} | Our Store`,
    description: product.description.slice(0, 160),
    openGraph: {
      title: product.name,
      description: product.description,
      images: [{ url: product.imageUrl, width: 1200, height: 630 }],
    },
  }
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await getProduct(slug)
  return <ProductDetails product={product} />
}
```

**Benefits:**
- Search engines index accurate page titles and descriptions
- Social media shares display correct product images and text
- Request deduplication ensures `getProduct` is called only once

**Alternative (combine with static base metadata):**

```tsx
// app/layout.tsx - base metadata inherited by all pages
export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: { default: 'Our Store', template: '%s | Our Store' },
  openGraph: { siteName: 'Our Store' },
}
```

Reference: [Generating Metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata)
