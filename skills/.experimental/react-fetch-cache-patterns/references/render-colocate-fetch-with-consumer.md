---
title: Colocate Fetches with Their Consumers
impact: MEDIUM
impactDescription: prevents prop drilling and unnecessary re-renders up the tree
tags: render, colocation, prop-drilling, cache, subscription
---

## Colocate Fetches with Their Consumers

A common refactor mistake: lift `useQuery` to the page root, drill the data down as props through 5 layers. Every prop change now re-renders 5 components even though only the leaf consumes the data. With a shared cache (TanStack Query, SWR), there's no benefit to lifting — every component can call the same `useQuery` and get the same data without a single duplicate request (see [[orch-dedupe-in-flight-requests]]). Put the fetch where the data is consumed.

Colocation also makes deletion safe: if you remove the leaf, the fetch goes with it. Lifted fetches survive even when nothing consumes them.

**Incorrect (fetch at root, prop-drilled through layers):**

```tsx
function ArticlePage({ id }: { id: string }) {
  const { data: article } = useQuery({ queryKey: ['article', id], queryFn: () => fetchArticle(id) });
  const { data: user }    = useQuery({ queryKey: ['user'], queryFn: fetchUser });

  return <ArticleLayout article={article} user={user} />;
}

function ArticleLayout({ article, user }: { article: Article; user: User }) {
  return (
    <>
      <Header user={user} />                  {/* needs user */}
      <ArticleBody article={article} />        {/* needs article */}
      <Sidebar user={user} article={article} />{/* drills both into 5 grandchildren */}
    </>
  );
}
// Every render of ArticlePage re-renders ArticleLayout AND all its children
// Even unrelated state changes at the root cascade through the whole tree
```

**Correct (colocate each fetch with its consumer):**

```tsx
function ArticlePage({ id }: { id: string }) {
  return <ArticleLayout id={id} />;
}

function ArticleLayout({ id }: { id: string }) {
  // Layout is pure — no fetching, no re-render on data changes
  return (
    <>
      <Header />
      <ArticleBody id={id} />
      <Sidebar id={id} />
    </>
  );
}

function Header() {
  const { data: user } = useQuery({ queryKey: ['user'], queryFn: fetchUser });
  return <header>{user?.name}</header>;
}

function ArticleBody({ id }: { id: string }) {
  const { data: article } = useQuery({ queryKey: ['article', id], queryFn: () => fetchArticle(id) });
  return <article>{article?.body}</article>;
}
// Each component subscribes only to what it renders; updates are surgical
// A change to `user` re-renders Header alone, not ArticleBody
```

**Custom hooks make colocation idiomatic:**

```tsx
// One source of truth for "how to fetch X" — testable, reusable
function useArticle(id: string) {
  return useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
    staleTime: 60_000,
  });
}

function ArticleBody({ id }: { id: string }) {
  const { data, isLoading } = useArticle(id);
  // ...
}

function ArticleMeta({ id }: { id: string }) {
  const { data } = useArticle(id); // dedupes — same cache entry, no extra fetch
  return <small>By {data?.authorName}</small>;
}
```

**Combine with [[render-suspense-per-section]]** for the full flow: each consumer suspends independently inside its own Suspense boundary.

**When lifting is correct:**
- Data that must be passed through to a *child library* (a context provider that needs the value)
- Conditional rendering that depends on the data (e.g., redirect if 404) — the conditional has to be above the children
- When the parent uses the data itself, not just for prop drilling

**Test for "should this be lifted?":** if the parent doesn't use the data — only renders children that do — push the fetch down.

Reference: [TkDodo — Practical React Query](https://tkdodo.eu/blog/practical-react-query) | [React — Lifting State Up](https://react.dev/learn/sharing-state-between-components)
