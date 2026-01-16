---
title: Add loading.tsx for Instant Navigation Feedback
impact: CRITICAL
impactDescription: Shows immediate visual feedback (<100ms) instead of frozen UI; enables partial prefetching for dynamic routes
tags: async, loading, suspense, navigation, ux
---

## Add loading.tsx for Instant Navigation Feedback

The `loading.tsx` file creates an automatic Suspense boundary around your page. It displays immediately during navigation while page content loads, eliminating the "frozen" feeling. For dynamic routes, it also enables partial prefetching.

**Incorrect (no loading state):**

```
app/
  blog/
    [slug]/
      page.tsx    # No loading.tsx
```

```typescript
// app/blog/[slug]/page.tsx
export default async function BlogPost({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const post = await getPost(slug) // 500ms API call

  // User sees nothing for 500ms after clicking link
  return <article>{post.content}</article>
}
```

**Correct (with loading.tsx):**

```
app/
  blog/
    [slug]/
      loading.tsx  # Instant feedback
      page.tsx
```

```typescript
// app/blog/[slug]/loading.tsx
export default function Loading() {
  return (
    <article className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-3/4 mb-4" />
      <div className="space-y-3">
        <div className="h-4 bg-gray-200 rounded" />
        <div className="h-4 bg-gray-200 rounded" />
        <div className="h-4 bg-gray-200 rounded w-5/6" />
      </div>
    </article>
  )
}

// app/blog/[slug]/page.tsx
export default async function BlogPost({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const post = await getPost(slug)

  // Skeleton shown immediately, content replaces it when ready
  return <article>{post.content}</article>
}
```

**Benefits:**
- Navigation triggers immediately (no delay)
- Skeleton provides visual progress indicator
- Layout remains stable (no content jumping)
- Enables partial prefetching for dynamic routes

**When NOT to use this pattern:**
- Static pages that render instantly (no need for loading state)
- When you want more granular Suspense boundaries within the page

Reference: [Next.js Loading UI](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
