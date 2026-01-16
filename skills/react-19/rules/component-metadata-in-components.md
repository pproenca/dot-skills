---
title: Define Document Metadata in Components
impact: MEDIUM
impactDescription: eliminates third-party head management libraries
tags: component, metadata, seo, document-head
---

## Define Document Metadata in Components

React 19 hoists `<title>`, `<meta>`, and `<link>` tags to the document head automatically. Define metadata where the content lives instead of using separate head management.

**Incorrect (external head management):**

```tsx
// Using a separate library or context
import { Helmet } from 'react-helmet'

function ProductPage({ product }: { product: Product }) {
  return (
    <>
      <Helmet>
        <title>{product.name} | Store</title>
        <meta name="description" content={product.description} />
      </Helmet>
      <ProductDetails product={product} />
    </>
  )
}
```

**Correct (native metadata support):**

```tsx
function ProductPage({ product }: { product: Product }) {
  return (
    <>
      <title>{product.name} | Store</title>
      <meta name="description" content={product.description} />
      <link rel="canonical" href={`https://store.com/products/${product.slug}`} />
      <ProductDetails product={product} />
    </>
  )
}
// React 19 automatically hoists to <head>
```

**In Server Components:**

```tsx
async function BlogPost({ slug }: { slug: string }) {
  const post = await getPost(slug)

  return (
    <article>
      <title>{post.title}</title>
      <meta name="description" content={post.excerpt} />
      <meta property="og:title" content={post.title} />
      <meta property="og:image" content={post.coverImage} />

      <h1>{post.title}</h1>
      <PostContent content={post.content} />
    </article>
  )
}
```

**Benefits:**
- Metadata lives with the content it describes
- Works with Server Components
- No third-party library needed
- Automatic deduplication of tags

Reference: [Document Metadata](https://react.dev/blog/2024/12/05/react-19#support-for-metadata-tags)
