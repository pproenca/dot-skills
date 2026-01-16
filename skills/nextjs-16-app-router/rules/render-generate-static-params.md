---
title: Use generateStaticParams for Dynamic Routes
impact: MEDIUM
impactDescription: pre-renders pages at build time, reducing TTFB from 200-500ms to <50ms
tags: render, static, build-time, dynamic-routes
---

## Use generateStaticParams for Dynamic Routes

The `generateStaticParams` function tells Next.js which dynamic route segments to pre-render at build time. Without it, dynamic routes render on-demand, adding server processing time to each request.

**Incorrect (on-demand rendering for every request):**

```typescript
// app/blog/[slug]/page.tsx
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  // Every request triggers server-side rendering
  const post = await fetchPost(slug)

  return <Article post={post} />
}
```

**Correct (pre-rendered at build time):**

```typescript
// app/blog/[slug]/page.tsx
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = await fetchPost(slug)

  return <Article post={post} />
}

export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

**Partial pre-rendering for large datasets:**

```typescript
export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  // Pre-render only the most popular posts, others render on-demand
  return posts.slice(0, 100).map((post) => ({ slug: post.slug }))
}
```

**Control fallback behavior:**

```typescript
// Return 404 for non-pre-rendered paths instead of on-demand rendering
export const dynamicParams = false

export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

Reference: [generateStaticParams](https://nextjs.org/docs/app/api-reference/functions/generate-static-params)
