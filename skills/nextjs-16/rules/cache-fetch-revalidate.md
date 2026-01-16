---
title: Set Appropriate Cache Revalidation Times
impact: MEDIUM
impactDescription: Proper cache times balance freshness and performance; too short = origin overload, too long = stale content
tags: cache, revalidate, ISR, freshness
---

## Set Appropriate Cache Revalidation Times

Every `fetch` request in Server Components can have its own cache configuration. Match revalidation times to how often data actually changes to avoid unnecessary origin requests while keeping content fresh.

**Incorrect (no cache strategy):**

```typescript
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params

  // ❌ No revalidation - cached forever or relies on defaults
  const product = await fetch(`https://api.example.com/products/${id}`)
    .then(r => r.json())

  // ❌ No caching - hits origin every request
  const stock = await fetch(`https://api.example.com/products/${id}/stock`, {
    cache: 'no-store'  // Always fresh but slow
  }).then(r => r.json())

  return <Product product={product} stock={stock} />
}
```

**Correct (strategic cache times):**

```typescript
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params

  // Product details change rarely - cache for 1 day
  const product = await fetch(`https://api.example.com/products/${id}`, {
    next: { revalidate: 86400 }  // 24 hours
  }).then(r => r.json())

  // Prices might change daily - cache for 1 hour
  const pricing = await fetch(`https://api.example.com/products/${id}/pricing`, {
    next: { revalidate: 3600 }  // 1 hour
  }).then(r => r.json())

  // Stock changes frequently - cache for 5 minutes
  const stock = await fetch(`https://api.example.com/products/${id}/stock`, {
    next: { revalidate: 300 }  // 5 minutes
  }).then(r => r.json())

  return <Product product={product} pricing={pricing} stock={stock} />
}
```

**Cache time guidelines:**

| Data Type | Suggested Revalidation | Example |
|-----------|------------------------|---------|
| Static content (about pages) | 86400+ (1 day+) | Company info, legal pages |
| Product catalog | 3600-86400 (1h-1d) | Product descriptions |
| Pricing | 300-3600 (5m-1h) | Prices, discounts |
| Inventory/stock | 60-300 (1-5m) | Stock levels |
| User-specific | 0 or no-store | Cart, preferences |
| Real-time | no-store | Live scores, chat |

**Combining with tags for on-demand revalidation:**

```typescript
const product = await fetch(`https://api.example.com/products/${id}`, {
  next: {
    revalidate: 86400,  // Background revalidation every 24h
    tags: [`product-${id}`]  // On-demand revalidation when product updates
  }
}).then(r => r.json())

// Trigger on-demand revalidation from webhook
// revalidateTag(`product-${id}`)
```

**When NOT to use time-based revalidation:**
- Data is user-specific (use no-store)
- Data must be real-time (use no-store)
- Data changes unpredictably (use tags for on-demand)

Reference: [Next.js Caching](https://nextjs.org/docs/app/building-your-application/caching)
