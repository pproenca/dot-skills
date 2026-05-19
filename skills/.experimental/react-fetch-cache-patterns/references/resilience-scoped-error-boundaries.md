---
title: Scope Error Boundaries to Data Sections
impact: HIGH
impactDescription: prevents one fetch failure from breaking the entire page
tags: resilience, error-boundary, suspense, isolation
---

## Scope Error Boundaries to Data Sections

A single error boundary at the route root means *any* failed fetch crashes the entire page. The user came to read the article and the related-articles carousel failed — now they see a generic error page instead of the article. Scope error boundaries to *each independent data section*: when the carousel fails, the article still renders, and only the carousel shows a "couldn't load" placeholder.

Use one boundary per Suspense boundary. The combination is "this chunk has its own loading state AND its own error state."

**Incorrect (one top-level boundary — failures cascade to whole page):**

```tsx
function ArticlePage() {
  return (
    <ErrorBoundary fallback={<GenericError />}>
      <Suspense fallback={<FullPageSkeleton />}>
        <Article />
        <Comments />
        <RelatedArticles /> {/* if this throws → entire page becomes <GenericError /> */}
      </Suspense>
    </ErrorBoundary>
  );
}
```

**Correct (boundary per data section — failures stay local):**

```tsx
function ArticlePage() {
  return (
    <>
      <SectionBoundary name="article" fallback={<ArticleError />}>
        <Suspense fallback={<ArticleSkeleton />}>
          <Article />
        </Suspense>
      </SectionBoundary>

      <SectionBoundary name="comments" fallback={<CommentsCollapsed />}>
        <Suspense fallback={<CommentsSkeleton />}>
          <Comments />
        </Suspense>
      </SectionBoundary>

      <SectionBoundary name="related" fallback={null /* silently hide */}>
        <Suspense fallback={<RelatedSkeleton />}>
          <RelatedArticles />
        </Suspense>
      </SectionBoundary>
    </>
  );
  // Related fails → silently hidden. Article still renders. User reads the page.
}
```

**Reusable boundary with retry + reporting:**

```tsx
function SectionBoundary({
  name, fallback, children,
}: { name: string; fallback: ReactNode; children: ReactNode }) {
  return (
    <ErrorBoundary
      fallbackRender={({ error, resetErrorBoundary }) => (
        <>
          {typeof fallback === 'function' ? fallback({ error, retry: resetErrorBoundary }) : fallback}
        </>
      )}
      onError={(error) => reportError({ section: name, error })}
    >
      {children}
    </ErrorBoundary>
  );
}
```

**Critical-vs-optional section design:**

| Section type | Boundary fallback | Why |
|--------------|------------------|-----|
| Critical (the article itself) | Show error with retry | User came for this; tell them what failed |
| Important (comments) | Collapsed/minimal placeholder | Visible degradation; user knows it failed |
| Optional (recommendations) | `null` or hidden | Don't visually punish the user for an irrelevant failure |

**Catch async errors in event handlers explicitly:** error boundaries catch render-time errors, not promise rejections from event handlers. Use `try/catch` in handlers and surface failures via toast or local state.

Reference: [React — Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary) | [react-error-boundary](https://github.com/bvaughn/react-error-boundary)
