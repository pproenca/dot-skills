---
title: Generate Dynamic OpenGraph Images
impact: LOW-MEDIUM
impactDescription: better social sharing, higher CTR
tags: meta, opengraph, image, social
---

## Generate Dynamic OpenGraph Images

Use `opengraph-image.tsx` to generate dynamic social preview images. This creates unique, branded images for each page.

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
