---
title: Lift Fetches into Route Loaders
impact: CRITICAL
impactDescription: 200-800ms saved on route entry
tags: orch, route-loader, prefetch, code-split, tanstack-router
---

## Lift Fetches into Route Loaders

When a component fetches inside `useEffect`, the browser must: download the route's JS chunk → parse → render the component → mount → run effect → start fetch. Each step is sequential. Route loaders flip this: the fetch starts in parallel with the chunk download. By the time the component is ready to render, the data is already there (or close to it).

This is supported natively in TanStack Router, Remix, React Router 6.4+, and Next.js (RSC). Use it for data the route always needs.

**Incorrect (fetch happens after render — sequential waterfall):**

```tsx
// /routes/product.$id.tsx
function ProductPage({ id }: { id: string }) {
  const { data, isLoading } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
  });
  if (isLoading) return <Skeleton />;
  return <Product product={data!} />;
}
// Timeline: nav click → download chunk (200ms) → render → effect → fetch (300ms) → done
// Total: ~500ms
```

**Correct (loader fires fetch in parallel with chunk download):**

```tsx
// /routes/product.$id.tsx — TanStack Router
export const Route = createFileRoute('/product/$id')({
  loader: ({ params, context: { queryClient } }) =>
    queryClient.ensureQueryData({
      queryKey: ['product', params.id],
      queryFn: () => fetchProduct(params.id),
    }),
  component: ProductPage,
});

function ProductPage() {
  const { id } = Route.useParams();
  // Data is already cached by the loader — this resolves synchronously
  const { data } = useSuspenseQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
  });
  return <Product product={data} />;
}
// Timeline: nav click → download chunk + fetch in parallel (max 300ms) → render → done
// Total: ~300ms
```

**Alternative (Next.js Server Component):**

```tsx
// app/product/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetchProduct(params.id); // server-side, no client roundtrip
  return <Product product={product} />;
}
```

**When NOT to use loaders:** for data that's user-interaction-driven (e.g. a modal's content). Keep loaders for route-level data the user committed to seeing by navigating.

Reference: [TanStack Router — Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
