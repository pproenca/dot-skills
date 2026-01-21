---
title: Configure Robots for Crawl Control
impact: MEDIUM
impactDescription: prevents indexing of private pages
tags: meta, robots, seo, crawling
---

## Configure Robots for Crawl Control

Use `robots.ts` and per-page robots metadata to control which pages search engines can crawl and index.

**Incorrect (no robots configuration):**

```typescript
// No robots.ts
// Search engines may index admin pages, staging URLs, etc.
```

**Correct (robots.ts for global rules):**

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL

  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin/', '/api/', '/dashboard/']
      }
    ],
    sitemap: `${baseUrl}/sitemap.xml`
  }
}
```

**Per-page robots metadata:**

```typescript
// app/dashboard/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  robots: {
    index: false,
    follow: false,
    nocache: true,
    googleBot: {
      index: false,
      follow: false
    }
  }
}

export default function DashboardPage() {
  // Private dashboard content
}
```

**Common patterns:**
- `index: false` - Don't show in search results
- `follow: false` - Don't follow links on this page
- `nocache` - Don't cache this page
- `noarchive` - Don't show cached version in results
