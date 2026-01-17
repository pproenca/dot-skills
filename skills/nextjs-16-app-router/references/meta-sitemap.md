---
title: Generate Sitemaps Dynamically
impact: MEDIUM
impactDescription: improved crawlability, faster indexing
tags: meta, sitemap, seo, crawling
---

## Generate Sitemaps Dynamically

Create dynamic sitemaps that include all your pages with proper last-modified dates. This helps search engines discover and index content efficiently.

**Incorrect (static sitemap missing dynamic routes):**

```xml
<!-- public/sitemap.xml -->
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
  </url>
  <url>
    <loc>https://example.com/about</loc>
  </url>
</urlset>
<!-- Missing all product pages! -->
```

**Correct (dynamic sitemap.ts):**

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getProducts()
  const posts = await getPosts()

  const productUrls = products.map((product) => ({
    url: `https://example.com/products/${product.slug}`,
    lastModified: product.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.8
  }))

  const postUrls = posts.map((post) => ({
    url: `https://example.com/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'monthly' as const,
    priority: 0.6
  }))

  return [
    {
      url: 'https://example.com',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1
    },
    ...productUrls,
    ...postUrls
  ]
}
```

**For large sites (50,000+ URLs), split into multiple sitemaps:**

```typescript
// app/sitemap/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const page = parseInt(params.id)
  const products = await getProductsPage(page, 10000)
  // Generate sitemap XML for this page
}
```
