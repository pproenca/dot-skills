---
title: Use generateStaticParams for Dynamic Routes
impact: MEDIUM-HIGH
impactDescription: Pre-generates pages at build time; first visitor gets instant response instead of waiting 200-500ms for on-demand rendering
tags: render, generateStaticParams, static, ISR
---

## Use generateStaticParams for Dynamic Routes

`generateStaticParams` tells Next.js which paths to pre-render at build time. Without it, dynamic routes render on-demand, adding latency for the first visitor. Pre-generate known paths for instant responses.

**Incorrect (on-demand rendering):**

```typescript
// app/blog/[slug]/page.tsx

// No generateStaticParams
// First visitor to /blog/my-post waits for server render
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = await getPost(slug)  // 200ms
  return <article>{post.content}</article>
}

// Build output: λ (Dynamic) - rendered on demand
```

**Correct (pre-rendered at build):**

```typescript
// app/blog/[slug]/page.tsx

// Pre-generate all known blog posts
export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map(post => ({
    slug: post.slug,
  }))
}

export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = await getPost(slug)
  return <article>{post.content}</article>
}

// Build output: ● (SSG) - pre-rendered as static HTML
```

**With nested dynamic segments:**

```typescript
// app/shop/[category]/[product]/page.tsx

export async function generateStaticParams() {
  const categories = await getCategories()

  return categories.flatMap(category =>
    category.products.map(product => ({
      category: category.slug,
      product: product.slug,
    }))
  )
}
// Generates: /shop/electronics/iphone, /shop/clothing/jacket, etc.
```

**Partial pre-rendering (known + on-demand):**

```typescript
// Pre-generate popular posts, render others on-demand
export async function generateStaticParams() {
  // Only pre-generate top 100 posts
  const popularPosts = await getPopularPosts(100)
  return popularPosts.map(post => ({ slug: post.slug }))
}

// New posts render on-demand, then cache for future requests
// Set dynamicParams = true (default) to allow this
```

**Disable on-demand generation:**

```typescript
// Only allow pre-generated paths, return 404 for others
export const dynamicParams = false

export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map(post => ({ slug: post.slug }))
}
// Unknown slugs return 404 instead of rendering on-demand
```

**When NOT to use generateStaticParams:**
- Paths can't be known at build time (user-generated content with no list endpoint)
- Data changes too frequently for static generation
- Millions of possible paths (generate popular ones only)

Reference: [Next.js generateStaticParams](https://nextjs.org/docs/app/api-reference/functions/generate-static-params)
