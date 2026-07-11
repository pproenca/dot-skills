---
title: Consume loader-ensured queries with useSuspenseQuery
tags: ssr, tanstack-query, suspense, hydration
---

## Consume loader-ensured queries with useSuspenseQuery

The wrong default is pairing a loader's `ensureQueryData` with plain `useQuery` in the component. `useQuery` does not execute on the server: its `data` is `undefined` during SSR, so the route server-renders a loading state for data the loader already fetched, then flashes to content after hydration. `useSuspenseQuery` runs during SSR and streams, which is the documented pairing for loader-ensured data; `useQuery` is reserved for data the server render does not need.

**Evidence of violation:** a component calling `useQuery(` with the same query options its route's `loader` passed to `context.queryClient.ensureQueryData(`.

**Incorrect (data is undefined server-side despite the loader fetching it):**

```tsx
export const Route = createFileRoute('/posts')({
  loader: ({ context }) => context.queryClient.ensureQueryData(postsQuery),
  component: PostsPage,
})

function PostsPage() {
  const { data } = useQuery(postsQuery)
  if (!data) return <Spinner />
  return <PostList posts={data} />
}
```

**Correct (SSR renders the real content; no loading flash):**

```tsx
function PostsPage() {
  const { data } = useSuspenseQuery(postsQuery)
  return <PostList posts={data} />
}
```

Reference: [TanStack Router — TanStack Query Integration](https://tanstack.com/router/latest/docs/integrations/query)
