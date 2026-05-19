---
title: Set staleTime to Suppress Redundant Refetches
impact: CRITICAL
impactDescription: 5-50x reduction in refetch rate
tags: cache, stale-time, refetch, swr
---

## Set staleTime to Suppress Redundant Refetches

By default, TanStack Query treats data as "instantly stale" — a refetch fires every time the query mounts, every time a component remounts, every time the window regains focus. For data that rarely changes (a product catalog, a user profile, a list of countries), this is a 50x amplification of backend load over what's needed. `staleTime` tells the cache "trust this data for N seconds — don't refetch within that window."

Pick `staleTime` based on how often the underlying data changes, not how often the user wants to see updates. A product's name changes monthly; a stock count changes per-second.

**Incorrect (default staleTime: refetches on every mount and focus):**

```tsx
function ProductCard({ id }: { id: string }) {
  // staleTime: 0 by default
  // → if the user opens this card in 10 components, focuses the tab,
  //   navigates away and back, you'll see ~12 refetches of /products/:id
  const { data } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
  });
}
```

**Correct (staleTime tuned to data volatility):**

```tsx
function ProductCard({ id }: { id: string }) {
  const { data } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
    staleTime: 5 * 60_000,          // catalog data — fine for 5 minutes
    gcTime: 30 * 60_000,            // keep in memory for 30 min after last use
  });
}

// Different staleTime for different data classes — see [[cache-tiered-stale-fresh]]
function StockBadge({ productId }: { productId: string }) {
  const { data } = useQuery({
    queryKey: ['stock', productId],
    queryFn: () => fetchStock(productId),
    staleTime: 10_000,              // inventory — refresh every 10s
  });
}
```

**Global defaults (set once, override per-query when needed):**

```tsx
new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,            // 30s default — sensible for most app data
      gcTime: 5 * 60_000,
      refetchOnWindowFocus: false,  // opt-in per query
    },
  },
});
```

**Warning:** `staleTime: Infinity` for shared mutable data leaks staleness across users. Reserve it for truly immutable data (a list of country codes).

Reference: [TanStack Query — Important Defaults](https://tanstack.com/query/latest/docs/framework/react/guides/important-defaults)
