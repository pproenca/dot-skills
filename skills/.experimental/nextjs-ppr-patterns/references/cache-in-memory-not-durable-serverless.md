---
title: Know that in-memory use cache is not durable on serverless
tags: cache, use-cache, serverless, use-cache-remote
---

## Know that in-memory use cache is not durable on serverless

The model assumes a `'use cache'` entry computed once is reused across all requests everywhere. By default entries are stored **in-memory (LRU)**. On serverless each request can hit a fresh instance, so a *runtime* cache entry may re-execute on every request (build-time caching still works normally); on a self-hosted / long-lived server, in-memory entries do persist across requests. When you need a durable, shared runtime cache (Redis/KV), opt the scope into `'use cache: remote'` — at the cost of a network roundtrip and platform fees. This distinction mainly bites runtime caching on serverless.

```tsx
async function getExchangeRates() {
  'use cache: remote' // shared, durable handler — survives across serverless invocations
  cacheLife('minutes')
  const res = await fetch('https://api.acme.com/fx')
  return res.json()
}
```

Reference: [use cache — runtime caching considerations](https://nextjs.org/docs/app/api-reference/directives/use-cache#runtime-caching-considerations)
