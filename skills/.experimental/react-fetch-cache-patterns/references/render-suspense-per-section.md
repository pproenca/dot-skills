---
title: Place Suspense Boundaries Per Logical Section
impact: MEDIUM
impactDescription: enables independent streaming of data sections
tags: render, suspense, boundaries, streaming, isolation
---

## Place Suspense Boundaries Per Logical Section

A single Suspense boundary at the route root suspends the entire page until *every* query resolves. The article is ready in 50ms, recommendations take 400ms, and the user stares at a full-page skeleton for 400ms. Suspense per section lets each section reveal as its own data lands — the article appears immediately, recommendations follow when ready. The page streams in.

This is also what SSR streaming (RSC, Suspense streaming) requires: each Suspense boundary becomes a streamable unit in the HTML response.

**Incorrect (one boundary — whole page waits for the slowest fetch):**

```tsx
function ArticlePage({ id }: { id: string }) {
  return (
    <Suspense fallback={<FullPageSkeleton />}>
      <Article id={id} />               {/* 50ms */}
      <Comments postId={id} />           {/* 150ms */}
      <RelatedArticles articleId={id} /> {/* 400ms — page waits for THIS */}
    </Suspense>
  );
  // User sees the skeleton for 400ms, then the entire page pops in at once
}
```

**Correct (boundary per section — each renders when its data lands):**

```tsx
function ArticlePage({ id }: { id: string }) {
  return (
    <>
      <Suspense fallback={<ArticleSkeleton />}>
        <Article id={id} /> {/* paints at 50ms */}
      </Suspense>

      <Suspense fallback={<CommentsSkeleton />}>
        <Comments postId={id} /> {/* paints at 150ms */}
      </Suspense>

      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedArticles articleId={id} /> {/* paints at 400ms */}
      </Suspense>
    </>
  );
  // Article visible at 50ms, comments at 150ms, related at 400ms
  // Time to first meaningful paint: 50ms vs 400ms
}
```

**Pair with useSuspenseQuery (suspends until data is available):**

```tsx
function Article({ id }: { id: string }) {
  const { data } = useSuspenseQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  });
  // data is non-nullable — Suspense above handled loading
  return <ArticleBody article={data} />;
}
```

**Combine with [[resilience-scoped-error-boundaries]] for the full pattern:**

```tsx
function ArticlePage({ id }: { id: string }) {
  return (
    <>
      <ErrorBoundary fallback={<ArticleError />}>
        <Suspense fallback={<ArticleSkeleton />}>
          <Article id={id} />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={null /* hide on failure */}>
        <Suspense fallback={<RelatedSkeleton />}>
          <RelatedArticles articleId={id} />
        </Suspense>
      </ErrorBoundary>
    </>
  );
}
```

**Suspense streaming with RSC (Next.js App Router):**

```tsx
// app/article/[id]/page.tsx
export default function ArticlePage({ params }: { params: { id: string } }) {
  return (
    <>
      {/* Server fetches article synchronously — included in initial HTML */}
      <Article id={params.id} />

      {/* These stream in after initial HTML, each as its own chunk */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Comments postId={params.id} />
      </Suspense>

      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedArticles articleId={params.id} />
      </Suspense>
    </>
  );
}
```

**Boundary placement rules:**
- One per *independent* data section — sections with no shared loading dependency
- Not per individual query — too granular leads to skeleton churn
- Below the main content boundary that handles the route's critical data — failures in optional sections don't cascade up

**Don't over-nest:** nested Suspense boundaries cascade fallbacks. If a child's data takes 100ms and its parent boundary handles a 50ms fetch, the child reveals after both — total perceived: 150ms.

Reference: [React — Suspense](https://react.dev/reference/react/Suspense) | [Next.js — Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
