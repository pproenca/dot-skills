---
title: Move Fetches to the Server When Possible
impact: HIGH
impactDescription: eliminates client-side round-trip + JS payload
tags: orch, rsc, ssr, server-components, nextjs
---

## Move Fetches to the Server When Possible

A client-side fetch costs: JS bundle to do the fetching (kb) + a round-trip from the user's network (often a slow mobile connection) + a render shift when data arrives. A server-side fetch on the same data costs: an intra-datacenter round-trip (often <5ms). When the fetch doesn't depend on client-only state (window size, auth tokens in localStorage), do it on the server.

React Server Components, Next.js App Router, and Remix loaders all support this. Use them for the "first paint" data of any route.

**Incorrect (client fetches data the server already had):**

```tsx
'use client';
function ProductPage({ id }: { id: string }) {
  const { data, isLoading } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetch(`/api/products/${id}`).then(r => r.json()),
  });
  if (isLoading) return <Skeleton />;
  return <Product product={data!} />;
}
// Cost: ~30kb of fetch/query/serializer JS shipped, +1 client round-trip on a 3G phone (~600ms)
```

**Correct (server component fetches and embeds):**

```tsx
// app/products/[id]/page.tsx — Server Component (no 'use client')
import { db } from '@/lib/db';

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await db.products.findUnique({ where: { id: params.id } });
  return <Product product={product} />; // HTML streamed directly, zero client fetching code
}
```

**When to keep it client-side:**
- Data that depends on client state (window, cookies set via JS, in-page selections)
- Real-time data (subscriptions, polling) — server is one-shot
- Mutations and their optimistic responses

**Hybrid pattern (server-fetch the trunk, client-fetch the branches):**

```tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetchProduct(params.id); // server: critical content
  return (
    <>
      <Product product={product} />
      <RelatedProducts productId={product.id} /> {/* client: lazy, optional */}
    </>
  );
}
```

Reference: [React — Server Components](https://react.dev/reference/rsc/server-components)
