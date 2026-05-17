---
title: Bound TTL by Product Staleness Tolerance, Not the Default
impact: HIGH
impactDescription: prevents serving non-compliant data hours after the rule changed
tags: ttl, staleness, compliance, sla, upper-bound
---

## Bound TTL by Product Staleness Tolerance, Not the Default

The maximum acceptable staleness for any cached value comes from the product or from regulation, not from engineering convenience. "Removed listings disappear within 30 seconds" is a product SLA. "Price changes propagate to search results within 5 minutes" is a UX requirement. "Withdrawn content is not served after notification" may be a legal requirement (GDPR right-to-be-forgotten, content-takedown notices). These translate to upper-bound TTL constraints. A cached value can have a *shorter* TTL than the product allows, but never a longer one. Engineering wins from caching cannot be claimed at the cost of violating the staleness SLA.

**Incorrect (engineering picks TTL for hit rate; product is unaware):**

```typescript
// Engineering: "We need a high hit rate; let's use 1-hour TTL on listings."
async function getListing(id: string) {
  const cached = await redis.get(`listing:${id}`);
  if (cached) return JSON.parse(cached);
  const fresh = await db.getListing(id);
  await redis.set(`listing:${id}`, JSON.stringify(fresh), 'EX', 3600);
  return fresh;
}

// Compliance team finds: a host removed their listing for legal reasons,
// but it kept appearing in search results for 53 minutes. Regulatory finding.
// "Why didn't engineering invalidate on removal?" — because the cache TTL was
// picked without consulting the staleness SLA.
```

**Correct (write down staleness budgets; cap TTL by them):**

```typescript
// /lib/cache/staleness-budget.ts — owned by product, reviewed by legal where relevant
export const STALENESS_BUDGET = {
  // Class              | Max stale (s) | Owner            | Justification
  // -------------------|---------------|------------------|-----------------------
  listing_existence:       30,    // // legal & content team — removal must propagate fast
  listing_price:           300,   // // product & checkout — pricing UX SLA
  listing_inventory:       30,    // // product            — sold-out within 30s
  listing_metadata:        1800,  // // content team       — descriptions edit-rate
  search_results:          300,   // // product            — UX SLA
  recommender_output:      1800,  // // product            — model staleness tolerance
  user_profile:            3600,  // // product            — display data
} as const;

// All cache writes go through cacheSet which enforces the upper bound.
async function cacheSet<T>(
  key: string,
  value: T,
  contentClass: keyof typeof STALENESS_BUDGET,
  desiredTtlSec: number,
) {
  const cap = STALENESS_BUDGET[contentClass];
  const ttl = Math.min(desiredTtlSec, cap);
  if (desiredTtlSec > cap) {
    metrics.increment('cache.ttl_capped', { contentClass });
    // optional: throw in dev/test, warn in prod
  }
  await redis.set(key, JSON.stringify(value), 'EX', ttl);
}

// Engineering can pick a SHORTER TTL for engineering reasons (cost, working set)
// but never longer than the staleness budget.
```

**Combine with event-driven invalidation for sub-budget guarantees.** If `listing_existence` budget is 30s but you can do better with event-driven invalidation ([ttl-event-driven-invalidation](ttl-event-driven-invalidation.md)), aim for sub-second. The budget is the floor of acceptability; events get you below it.

**Document the budget in a single file owned by product/compliance.** Pull requests that introduce a new content class require a budget value. Audit reviews can spot-check that the values are sensible.

**Apply equally to CDN and edge caches.** A CloudFront `max-age` of 1 hour on `/listings/:id` violates the same SLA as Redis TTL. Set the `Cache-Control` header from the same budget table.

**Don't pad the budget for "safety."** A 60s budget capped at 60s gives more freshness signal than padding to "30s to be safe." Cap is the cap; if you need 30s, set the budget to 30s.

**The "purge on takedown" mechanism is separate.** Even with a 30-second budget, content takedowns must invalidate immediately — not wait for the TTL. The budget is "in the absence of an explicit invalidate"; the invalidate path always takes precedence.

Reference: [GDPR Article 17 — Right to erasure](https://gdpr-info.eu/art-17-gdpr/) · [Cloudflare: Cache TTL and Browser TTL](https://developers.cloudflare.com/cache/how-to/configure-cache-status-code/)
