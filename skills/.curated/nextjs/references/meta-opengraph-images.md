---
title: Generate per-page OG images at the route via `opengraph-image.tsx` — not a static fallback in `public/`
impact: LOW-MEDIUM
impactDescription: unique branded social preview per post/product (lifts share CTR meaningfully); falls back to static image at routes that don't define their own
tags: meta, opengraph-image, dynamic-og, social-preview
---

## Generate per-page OG images at the route via `opengraph-image.tsx` — not a static fallback in `public/`

**Pattern intent:** shared links should show a meaningful preview specific to the linked page (post title, product image, author byline). `opengraph-image.tsx` colocated with a route generates this at request time using `ImageResponse`.

### Shapes to recognize

- Every share preview showing the same generic site banner — no per-page OG images defined.
- A `public/og.png` referenced from the layout's metadata — falls back fine but loses the per-post specificity.
- An `opengraph-image.tsx` placed in the root `app/` only — works for the homepage but leaves dynamic routes with no per-resource OG.
- An `og-image.png` URL hard-coded into each page's metadata.openGraph.images — manual; fragile; rarely updated.
- A workaround using a third-party service (Cloudinary OG image generator) — works but introduces a third-party dependency for what Next.js provides natively.

The canonical resolution: place `app/<route>/opengraph-image.tsx` for routes that benefit (blog posts, product pages, profiles); read `params`, fetch the page data, return an `<ImageResponse>` with branded JSX. Keep a `app/opengraph-image.png` (static) as fallback for routes without their own.

Reference: [OpenGraph Images](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image)

**Incorrect (missing or generic OG images):**

```typescript
// No OG image configured
// Social shares show generic placeholder or nothing
```

**Correct (dynamic OG image generation):**

```typescript
// app/blog/[slug]/opengraph-image.tsx
import { ImageResponse } from 'next/og'

export const runtime = 'edge'
export const alt = 'Blog post cover'
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

export default async function Image({
  params
}: {
  params: { slug: string }
}) {
  const post = await getPost(params.slug)

  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          width: '100%',
          height: '100%',
          backgroundColor: '#1a1a1a',
          color: 'white',
          padding: '40px'
        }}
      >
        <h1 style={{ fontSize: '60px', textAlign: 'center' }}>
          {post.title}
        </h1>
        <p style={{ fontSize: '30px', color: '#888' }}>
          {post.author} · {post.readTime} min read
        </p>
      </div>
    ),
    { ...size }
  )
}
```

**Static fallback for routes without dynamic image:**

```typescript
// app/opengraph-image.png
// Place a static image in the route for default OG image
```

Reference: [OpenGraph Images](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image)
