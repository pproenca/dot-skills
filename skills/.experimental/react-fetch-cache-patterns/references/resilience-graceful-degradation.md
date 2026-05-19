---
title: Gracefully Degrade Non-Critical Sections
impact: MEDIUM-HIGH
impactDescription: preserves core flow when peripheral data fails
tags: resilience, graceful-degradation, isolation, optional
---

## Gracefully Degrade Non-Critical Sections

Not all data is equal. The user came to read the article — the related-articles carousel, the inline ads, the social count, the "people also viewed" rail are all decorations. When they fail, the core experience should still work. The pattern: classify each data fetch as critical or optional at design time, and let optional sections fail silently (rendering `null` or a minimal placeholder).

The contrast: ungated optional content shows error states that confuse the user about what's broken, and worse, can cascade through error boundaries to break the page entirely.

**Incorrect (all data sections treated equally — peripheral failure breaks layout):**

```tsx
function ArticlePage({ id }: { id: string }) {
  const article = useQuery({ queryKey: ['article', id], queryFn: () => fetchArticle(id) });
  const related = useQuery({ queryKey: ['related', id], queryFn: () => fetchRelated(id) });
  const ads = useQuery({ queryKey: ['ads', id], queryFn: () => fetchAds(id) });

  // If any of these is loading/error, we render their loading/error states
  if (article.isLoading) return <Skeleton />;
  if (article.error || related.error || ads.error) return <ErrorPage />; // 🚨 ads failed → no article

  return <>{/* render all */}</>;
}
```

**Correct (criticality-aware rendering):**

```tsx
function ArticlePage({ id }: { id: string }) {
  // Critical — must succeed
  const article = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
    throwOnError: true, // bubble to ErrorBoundary
  });

  // Optional — failure tolerated
  const related = useQuery({
    queryKey: ['related', id],
    queryFn: () => fetchRelated(id),
    throwOnError: false, // never bubbles
    retry: 1,
  });

  const ads = useQuery({
    queryKey: ['ads', id],
    queryFn: () => fetchAds(id),
    throwOnError: false,
    retry: 0,
  });

  if (article.isLoading) return <ArticleSkeleton />;
  // article.error → handled by parent ErrorBoundary

  return (
    <>
      <Article data={article.data!} />
      {/* Optional sections render only if data is present; silent on failure */}
      {related.data && <RelatedCarousel items={related.data} />}
      {ads.data && <Ads items={ads.data} />}
    </>
  );
}
```

**Decoration helper:**

```ts
export function useOptionalQuery<T>(
  options: UseQueryOptions<T> & { queryKey: QueryKey; queryFn: QueryFunction<T> }
) {
  return useQuery({
    ...options,
    throwOnError: false,
    retry: 1,
    // Optional data should fail fast — don't burn retry budget
    retryDelay: 1000,
  });
}

// Now usage is intent-revealing:
const related = useOptionalQuery({ queryKey: ['related', id], queryFn: () => fetchRelated(id) });
```

**Three-tier classification:**

| Tier | Examples | On failure |
|------|----------|-----------|
| Critical | Article content, account info, cart contents | Throw to error boundary; user must retry |
| Important | Comments, follow status, related items | Show degraded placeholder; allow retry |
| Decorative | Ads, recommendation carousels, social proof counts | Render `null`; silent failure |

**Combine with [[resilience-scoped-error-boundaries]]:** scoped boundaries protect against unexpected errors; tier classification handles expected partial failure.

**Log silent failures:** even when not user-visible, send the error to your observability stack. A silently-failing recommendation engine still needs fixing.

Reference: [Resilient Web Design — Jeremy Keith](https://resilientwebdesign.com/) | [Vercel — Building resilient UIs](https://vercel.com/blog/everything-about-data-fetching-in-nextjs)
