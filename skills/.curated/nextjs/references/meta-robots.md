---
title: Make crawl rules explicit via `app/robots.ts` and per-page `metadata.robots` — don't rely on "they won't crawl this"
impact: MEDIUM
impactDescription: keeps admin/dashboard/staging URLs out of search results; spells out which routes are public, which are private
tags: meta, robots-ts, crawl-control, indexability
---

## Make crawl rules explicit via `app/robots.ts` and per-page `metadata.robots` — don't rely on "they won't crawl this"

**Pattern intent:** every public-facing Next.js site needs explicit crawl rules. The site-wide rules live in `app/robots.ts`; per-route exceptions live in each page's `metadata.robots`. Implicit defaults vary by environment and surprise teams.

### Shapes to recognize

- No `robots.ts` and no per-page robots metadata — admin pages eventually appear in search results.
- A `robots.ts` that allows everything but key routes (`/dashboard`, `/admin`, `/api`) are missing from `disallow` — those routes get indexed.
- A staging deployment leaking into search results because the production `robots.ts` was copied without the staging-specific disallow.
- A login or password-reset page in search results — should be `index: false, follow: false` in per-page metadata.
- A `noindex` meta tag hard-coded in a layout — works but invisible to maintenance; declare via the typed `metadata.robots` API.

The canonical resolution: `app/robots.ts` exporting site-wide rules (disallow `/admin/`, `/api/`, `/dashboard/`) and sitemap URL; per-route `export const metadata: Metadata = { robots: { index: false, follow: false } }` for sensitive pages.

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
