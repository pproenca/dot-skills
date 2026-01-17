---
title: Avoid Request Waterfalls
impact: CRITICAL
impactDescription: 2-10× latency reduction
tags: prefetch, waterfalls, parallel, performance
---

## Avoid Request Waterfalls

Sequential await patterns create waterfalls where each request waits for the previous. Child component queries don't start until parent components render, multiplying latency.

**Incorrect (child waits for parent to render):**

```typescript
function Article({ id }: { id: string }) {
  const { data: article, isPending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  if (isPending) return <Skeleton />

  // Comments query doesn't START until article loads AND renders
  return (
    <>
      <ArticleContent article={article} />
      <Comments articleId={id} /> {/* Waterfall! */}
    </>
  )
}

function Comments({ articleId }: { articleId: string }) {
  const { data } = useQuery({
    queryKey: ['comments', articleId],
    queryFn: () => fetchComments(articleId),
  })
  // This query started AFTER article loaded - wasted time
}
```

**Timeline:** Article (200ms) → then Comments (150ms) = 350ms total

**Correct (hoist queries to parent):**

```typescript
function Article({ id }: { id: string }) {
  // Both queries start immediately, in parallel
  const { data: article, isPending: articlePending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  const { data: comments, isPending: commentsPending } = useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
  })

  if (articlePending) return <Skeleton />

  return (
    <>
      <ArticleContent article={article} />
      {commentsPending ? <CommentsSkeleton /> : <Comments comments={comments} />}
    </>
  )
}
```

**Timeline:** Article (200ms) + Comments (150ms) parallel = 200ms total

**Alternative (prefetch in parent):**

```typescript
function Article({ id }: { id: string }) {
  const { data: article, isPending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  // Prefetch comments while article loads
  useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
    notifyOnChangeProps: [], // Don't re-render this component
  })

  if (isPending) return <Skeleton />

  return (
    <>
      <ArticleContent article={article} />
      <Comments articleId={id} /> {/* Cache already warm! */}
    </>
  )
}
```

Reference: [Request Waterfalls](https://tanstack.com/query/v5/docs/react/guides/request-waterfalls)
