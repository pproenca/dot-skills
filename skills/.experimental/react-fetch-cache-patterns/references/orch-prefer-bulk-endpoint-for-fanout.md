---
title: Prefer a Bulk Endpoint over N Parallel Endpoints
impact: CRITICAL
impactDescription: reduces N round-trips to 1
tags: orch, bulk, fanout, api-design, batching
---

## Prefer a Bulk Endpoint over N Parallel Endpoints

`Promise.all([fetchUser(a), fetchUser(b), fetchUser(c)])` is parallel — but it's still three TCP/TLS round-trips, three HTTP header sets, three log lines, three rate-limit decrements. When the backend supports `GET /users?ids=a,b,c`, one round-trip replaces all three. Bulk endpoints are also easier for the backend to plan as a single query.

If the bulk endpoint doesn't exist yet, ask for it before scaling parallel fan-out past ~10 items. Backends almost always prefer one indexed lookup of 200 IDs to 200 indexed lookups of 1 ID each.

**Incorrect (200 parallel requests for a list view):**

```tsx
function FavoritesPage({ favoriteIds }: { favoriteIds: string[] }) {
  // Parallel — but 200 HTTP requests, 200 rows in access log, 200 SSL handshakes
  const queries = useQueries({
    queries: favoriteIds.map(id => ({
      queryKey: ['product', id],
      queryFn: () => fetchProduct(id),
    })),
  });
  // ...
}
```

**Correct (one bulk fetch, then split into the cache):**

```tsx
function FavoritesPage({ favoriteIds }: { favoriteIds: string[] }) {
  const { data: products } = useQuery({
    queryKey: ['products', { ids: [...favoriteIds].sort() }], // sort for stable key
    queryFn: () => fetchProductsBulk(favoriteIds),            // one round-trip
  });

  // After the bulk fetch, seed per-id cache entries so single-item reads hit the cache:
  const queryClient = useQueryClient();
  useEffect(() => {
    products?.forEach(p => queryClient.setQueryData(['product', p.id], p));
  }, [products]);
}
```

**When a bulk endpoint isn't available:** combine with [[orch-batch-n-plus-one-fanout]] (DataLoader) so calls collected in a tick still merge into one bulk request to a bulk endpoint you control.

**Backend-side benefit:** one query with `WHERE id IN (...)` uses one index scan; 200 individual queries do 200 index seeks. The bulk version is often 10-50x faster on the database too.

Reference: [Vercel — Fetching Data on the Server](https://vercel.com/blog/everything-about-data-fetching-in-nextjs)
