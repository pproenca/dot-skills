---
title: Generate Dynamic Metadata for SEO
impact: LOW-MEDIUM
impactDescription: Proper meta tags improve search rankings and social sharing; generateMetadata ensures unique metadata per page
tags: advanced, metadata, SEO, social
---

## Generate Dynamic Metadata for SEO

Use the `generateMetadata` function to create page-specific titles, descriptions, and Open Graph tags. This improves SEO and ensures proper previews when shared on social media.

**Incorrect (missing or static metadata):**

```typescript
// ❌ No metadata - poor SEO
export default async function ProductPage({ params }) {
  const { id } = await params
  const product = await getProduct(id)
  return <Product product={product} />
}
// Browser shows "localhost:3000" as title
// Social shares show no preview
```

**Correct (dynamic metadata):**

```typescript
import { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>
}): Promise<Metadata> {
  const { id } = await params
  const product = await getProduct(id)

  return {
    title: `${product.name} | MyStore`,
    description: product.description.slice(0, 160),
    openGraph: {
      title: product.name,
      description: product.description,
      images: [
        {
          url: product.image,
          width: 1200,
          height: 630,
          alt: product.name,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description,
      images: [product.image],
    },
  }
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)
  return <Product product={product} />
}
```

**Static metadata export:**

```typescript
// For pages with fixed metadata
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About Us | MyStore',
  description: 'Learn about our company mission and team.',
}

export default function AboutPage() {
  return <About />
}
```

**Layout-level defaults:**

```typescript
// app/layout.tsx - Base metadata inherited by all pages
import { Metadata } from 'next'

export const metadata: Metadata = {
  metadataBase: new URL('https://mystore.com'),
  title: {
    default: 'MyStore',
    template: '%s | MyStore',  // Pages can override with just title
  },
  description: 'Your one-stop shop for everything.',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    siteName: 'MyStore',
  },
}
```

**JSON-LD structured data:**

```typescript
export default async function ProductPage({ params }) {
  const { id } = await params
  const product = await getProduct(id)

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    description: product.description,
    image: product.image,
    offers: {
      '@type': 'Offer',
      price: product.price,
      priceCurrency: 'USD',
    },
  }

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Product product={product} />
    </>
  )
}
```

**When NOT to generate metadata:**
- Private/authenticated pages (robots: noindex)
- Temporary/draft content

Reference: [Next.js Metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata)
