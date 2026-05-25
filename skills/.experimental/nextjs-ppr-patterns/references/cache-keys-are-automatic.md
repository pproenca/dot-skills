---
title: Let arguments and closures form the cache key automatically
tags: cache, use-cache, cache-keys, serialization
---

## Let arguments and closures form the cache key automatically

The model worries that caching breaks per-user or per-parameter content, or reaches for manual key arrays (`unstable_cache`'s `keyParts`). With `'use cache'` the key is generated automatically from the function's identity plus its **serialized arguments and any closed-over variables** — different inputs produce different entries. So pass the varying input as an argument and let the framework key on it; don't build keys by hand. (Arguments must be serializable: primitives, plain objects/arrays, `Date`/`Map`/`Set` — not class instances, functions, or JSX/`children`, which use the pass-through pattern instead.)

```tsx
async function getOrders(customerId: string, status: 'open' | 'closed') {
  'use cache'
  // customerId and status are part of the cache key automatically →
  // one cache entry per (customer, status) combination.
  return db.order.findMany({ where: { customerId, status } })
}
```

Reference: [use cache — cache keys](https://nextjs.org/docs/app/api-reference/directives/use-cache#cache-keys)
