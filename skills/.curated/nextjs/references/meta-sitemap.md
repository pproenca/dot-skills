---
title: Generate sitemaps at build/request time from the actual data — never hand-maintain `public/sitemap.xml`
impact: MEDIUM
impactDescription: every dynamic route is discoverable; lastModified reflects real changes; updates ship automatically
tags: meta, sitemap-ts, dynamic-sitemap, crawl-discovery
---

## Generate sitemaps at build/request time from the actual data — never hand-maintain `public/sitemap.xml`

**Pattern intent:** the sitemap is a map of the live pages. A hand-maintained `public/sitemap.xml` drifts the moment new content ships. `app/sitemap.ts` generates the sitemap from the source of truth (DB, CMS) at build or request time.

### Shapes to recognize

- A `public/sitemap.xml` that lists `/`, `/about`, `/contact` but no dynamic content — every blog post, product, profile is invisible to crawlers.
- A `sitemap.xml` last updated months ago — stale `lastmod` dates tell crawlers nothing changed.
- A custom Express/Edge route returning sitemap XML by hand — works but reinvents what `app/sitemap.ts` provides natively.
- A static sitemap *plus* an `app/sitemap.ts` — Next.js will be confused about which one wins; remove the static one.
- A sitemap missing `<lastmod>` values — crawlers don't know what to re-fetch.

The canonical resolution: `export default async function sitemap(): Promise<MetadataRoute.Sitemap>` returning entries `{ url, lastModified, changeFrequency, priority }`. Fetch dynamic content (posts, products) and `.map(...)` into entries. For 50k+ URLs, split into paginated sitemaps via `[id]/route.ts`.

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
