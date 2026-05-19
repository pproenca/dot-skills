---
title: Hydrate the Client Cache from Server-Rendered Data
impact: HIGH
impactDescription: eliminates first-fetch on cached entities
tags: prefetch, hydration, ssr, rsc, dehydrate
---

## Hydrate the Client Cache from Server-Rendered Data

When the server already fetched a product to render its HTML, the client shouldn't fetch it again on mount. Hydration ships the server's cache state inside the HTML; the client picks it up before the first render so `useQuery` sees fresh data without a network call. Without this, every server-rendered page does a "rehydration refetch" — the most common cause of duplicate work in SSR React apps.

Both TanStack Query (`HydrationBoundary`) and SWR (`fallback` prop) support this pattern. Next.js App Router with RSC builds this in: server-fetched data is embedded in the streamed RSC payload.

**Incorrect (server fetches, client refetches the same thing):**

```tsx
// pages/product/[id].tsx (Pages Router)
export async function getServerSideProps({ params }) {
  const product = await fetchProduct(params.id);
  return { props: { product } }; // ships data as plain prop
}

export default function ProductPage({ product }) {
  // Now the client mounts and...
  const { data } = useQuery({
    queryKey: ['product', product.id],
    queryFn: () => fetchProduct(product.id), // ← refetches what the server already did
  });
  return <Product product={data ?? product} />;
}
```

**Correct (dehydrate on the server, hydrate on the client):**

```tsx
// pages/product/[id].tsx
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query';

export async function getServerSideProps({ params }) {
  const queryClient = new QueryClient();
  await queryClient.prefetchQuery({
    queryKey: productKeys.detail(params.id),
    queryFn: () => fetchProduct(params.id),
  });
  return { props: { dehydratedState: dehydrate(queryClient) } };
}

export default function ProductPage({ dehydratedState }) {
  return (
    <HydrationBoundary state={dehydratedState}>
      <ProductView />
    </HydrationBoundary>
  );
}

function ProductView() {
  const { id } = useParams();
  const { data } = useQuery({
    queryKey: productKeys.detail(id),
    queryFn: () => fetchProduct(id),
    // Reads server-prefetched data — no client refetch within staleTime
    staleTime: 60_000,
  });
  return <Product product={data!} />;
}
```

**With Next.js App Router + RSC (zero-config):**

```tsx
// app/product/[id]/page.tsx — Server Component
import { HydrationBoundary, dehydrate, QueryClient } from '@tanstack/react-query';

export default async function ProductPage({ params }: { params: { id: string } }) {
  const queryClient = new QueryClient();
  await queryClient.prefetchQuery({
    queryKey: productKeys.detail(params.id),
    queryFn: () => fetchProduct(params.id),
  });
  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ClientProductView id={params.id} />
    </HydrationBoundary>
  );
}
```

**Without query libraries (SWR fallback):**

```tsx
<SWRConfig value={{ fallback: { [`/api/products/${id}`]: product } }}>
  <ProductView />
</SWRConfig>
```

**Critical detail (`staleTime` matters during hydration):** if `staleTime` is 0, the client will refetch on hydration anyway because it considers the server data "instantly stale." Set `staleTime` to at least the time it takes the user to start interacting (~1s minimum, typically 30-60s).

Reference: [TanStack Query — SSR & Hydration](https://tanstack.com/query/latest/docs/framework/react/guides/ssr)
