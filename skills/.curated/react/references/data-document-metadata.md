---
title: Render Document Metadata Inline, Not via react-helmet
impact: MEDIUM
impactDescription: eliminates external metadata libraries, hoists tags to <head> automatically, works across SSR and CSR
tags: data, metadata, title, meta, link, head
---

## Render Document Metadata Inline, Not via react-helmet

React 19 natively hoists `<title>`, `<meta>`, and `<link>` tags to the document `<head>` no matter where they appear in the tree. Drop `react-helmet`, `react-helmet-async`, or framework-specific Head components — render the tags directly inside the component that owns the data.

**Incorrect (third-party head manager):**

```typescript
import { Helmet } from 'react-helmet-async'

function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      <Helmet>
        <title>{post.title}</title>
        <meta name="description" content={post.excerpt} />
        <meta property="og:title" content={post.title} />
        <link rel="canonical" href={`https://blog.example.com/${post.slug}`} />
      </Helmet>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  )
}
// ❌ Extra dependency, runtime context, hydration coordination
```

**Correct (inline metadata tags):**

```typescript
function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      <title>{post.title}</title>
      <meta name="description" content={post.excerpt} />
      <meta property="og:title" content={post.title} />
      <link rel="canonical" href={`https://blog.example.com/${post.slug}`} />
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  )
}
// ✅ Tags hoist to <head> automatically, deduplicated across renders
```

**Server Component variant — works the same:**

```typescript
export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await fetchPost(params.slug)

  return (
    <>
      <title>{post.title} — My Blog</title>
      <meta name="description" content={post.excerpt} />
      <BlogPost post={post} />
    </>
  )
}
```

**Stylesheets with precedence:**

```typescript
function ProductPage({ productId }: { productId: string }) {
  return (
    <>
      <link rel="stylesheet" href="/styles/reset.css" precedence="default" />
      <link rel="stylesheet" href="/styles/product.css" precedence="high" />
      <ProductView productId={productId} />
    </>
  )
}
// React deduplicates, orders by precedence, and waits for stylesheets to load before commit
```

**Notes:**
- Tags are deduplicated by element name + key attributes (e.g., `<meta property="...">`).
- For framework-specific metadata APIs (Next.js `generateMetadata`, Remix `meta` export), prefer those when available — they integrate with route-level SSR optimizations.
- Avoid mixing inline metadata with `react-helmet` in the same tree; pick one strategy.

Reference: [React v19 — Document Metadata](https://react.dev/blog/2024/12/05/react-19#support-for-metadata-tags)
