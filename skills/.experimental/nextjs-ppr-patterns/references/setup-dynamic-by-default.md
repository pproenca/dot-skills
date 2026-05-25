---
title: Treat everything as dynamic by default and opt into caching
tags: setup, mental-model, use-cache, fetch
---

## Treat everything as dynamic by default and opt into caching

In Next.js 14/15 the model assumes routes are static by default and `fetch` is implicitly cached. Cache Components **inverts this**: all dynamic code runs at request time by default, and `fetch` is no longer cached. You make work static or cached by *opting in* with the `'use cache'` directive — not by removing `export const dynamic`. The practical consequence: a page you assume is static is actually rendered per request unless you explicitly cache its data, so reason from "dynamic until proven cached."

```tsx
// Dynamic by default: this fetch runs on every request and is NOT cached.
export default async function PricingPage() {
  const res = await fetch('https://api.acme.com/plans')
  const plans = await res.json()
  return <PlanList plans={plans} />
}

// Opt back into the static shell explicitly:
async function getPlans() {
  'use cache' // now cached and prerendered into the shell
  const res = await fetch('https://api.acme.com/plans')
  return res.json()
}
```

Reference: [Fetching Data — fetch is not cached by default](https://nextjs.org/docs/app/getting-started/fetching-data#with-the-fetch-api)
