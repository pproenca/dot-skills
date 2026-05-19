---
title: Tier staleTime by Data Volatility
impact: HIGH
impactDescription: reduces stale-data refetches 10-100×
tags: cache, stale-time, tiers, volatility
---

## Tier staleTime by Data Volatility

One global `staleTime` is a compromise — too high for inventory (shows out-of-date stock), too low for the country list (refetched needlessly). Classify your data by volatility class and assign each class a `staleTime`. Real-time data (stock, price) gets seconds; user profile gets minutes; catalog/lookup data gets hours.

This tiering is also what HTTP caching does well — `Cache-Control: max-age` per endpoint type. Mirror that policy in your client cache.

**Incorrect (one global staleTime — fights everything):**

```tsx
new QueryClient({
  defaultOptions: { queries: { staleTime: 30_000 } },
});
// Inventory shown 30s stale → user adds to cart, gets "out of stock" at checkout
// Country list refetched every 30s → 100k pointless requests/day across users
```

**Correct (tiered, per data class):**

```ts
// src/queries/stale-tiers.ts
export const STALE = {
  realtime: 5_000,       //   5s — stock, live price, online status
  fresh:    30_000,      //  30s — feed, notifications, cart contents
  warm:     5  * 60_000, //   5m — user profile, settings, preferences
  cold:     60 * 60_000, //   1h — product details, posts, comments
  static:   24 * 60 * 60_000, // 24h — country list, categories, tag taxonomy
} as const;

useQuery({ queryKey: ['stock', id], queryFn: () => fetchStock(id), staleTime: STALE.realtime });
useQuery({ queryKey: ['user', id],  queryFn: () => fetchUser(id),  staleTime: STALE.warm });
useQuery({ queryKey: ['countries'], queryFn: fetchCountries,       staleTime: STALE.static });
```

**Pair with server Cache-Control headers for full-stack consistency:**

```ts
// API route handler
response.headers.set('Cache-Control', 'public, max-age=5, stale-while-revalidate=30'); // stock
response.headers.set('Cache-Control', 'public, max-age=300, stale-while-revalidate=600'); // user
response.headers.set('Cache-Control', 'public, max-age=86400, immutable'); // countries
```

**How to pick a tier:** look at the underlying source of truth. If it's a metric that updates per-second, use `realtime`. If it's a user-editable field, `warm` to `cold`. If it's reference data deployed with the app, `static`.

Reference: [TkDodo — staleTime vs gcTime](https://tkdodo.eu/blog/inside-react-query)
