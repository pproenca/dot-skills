---
title: Pair TTL with Event-Driven Invalidation for Critical Freshness
impact: HIGH
impactDescription: closes the gap between mutation and cache update from TTL-bound to seconds
tags: ttl, invalidation, events, eventbridge, pub-sub
---

## Pair TTL with Event-Driven Invalidation for Critical Freshness

TTL bounds the maximum staleness, but it's a passive mechanism — readers keep getting stale until the TTL expires. For surfaces where staleness has business impact (inventory sold out, price changed, listing removed for compliance), the gap between "data changed" and "cache reflects the change" must be seconds, not the full TTL. Event-driven invalidation closes the gap: the system that owns the data emits an event on change; subscribers in the cache layer evict or update relevant entries. TTL still acts as the safety net for missed events; the events handle the common path.

**Incorrect (TTL-only — stale until expiry):**

```typescript
async function getListingPrice(listingId: string) {
  const cached = await redis.get(`price:${listingId}`);
  if (cached) return cached;
  const fresh = await db.getPrice(listingId);
  await redis.set(`price:${listingId}`, fresh, 'EX', 300);
  return fresh;
}

async function updateListingPrice(listingId: string, newPrice: number) {
  await db.updatePrice(listingId, newPrice);
  // No cache invalidation. Users see old price for up to 5 minutes.
}
// On a marketplace, "I see one price, get charged another" = chargebacks + trust loss.
```

**Correct (TTL + event-driven invalidation):**

```typescript
// Read path is unchanged — cache-aside with TTL
async function getListingPrice(listingId: string) {
  const cached = await redis.get(`price:${listingId}`);
  if (cached) return cached;
  const fresh = await db.getPrice(listingId);
  await redis.set(`price:${listingId}`, fresh, 'EX', 300);
  return fresh;
}

// Write path emits an event
async function updateListingPrice(listingId: string, newPrice: number) {
  await db.updatePrice(listingId, newPrice);
  await eventBridge.putEvents({
    Source: 'marketplace.listings',
    DetailType: 'listing.price.changed',
    Detail: JSON.stringify({ listingId, newPrice, ts: Date.now() }),
  });
}

// Subscriber — runs as a separate worker (Lambda, ECS task, etc.)
// Invalidates affected keys across the cache topology
export async function onListingPriceChanged(event: ListingPriceChangedEvent) {
  const { listingId } = event.detail;
  // 1. Invalidate the direct price cache
  await redis.del(`price:${listingId}`);

  // 2. Invalidate derived caches (any search/recommender result containing this listing)
  // Tag-based invalidation: every cached entry stores its dependent listing IDs in a tag set.
  await invalidateByTag(`listing:${listingId}`);
}
```

**Tag-based invalidation pattern:**

```typescript
// On cache write, also record which listings are in this entry
async function cacheSetSearchResults(key: string, result: SearchResult) {
  await redis.multi()
    .set(key, JSON.stringify(result), 'EX', 600)
    .sadd(`tag:listings-in-cache:${key}`, ...result.items.map(i => i.id))
    .exec();

  // Reverse index: for each listing, track which cache keys depend on it
  for (const item of result.items) {
    await redis.sadd(`tag:cache-keys-for-listing:${item.id}`, key);
  }
}

async function invalidateByTag(tag: `listing:${string}`) {
  const listingId = tag.split(':')[1];
  const dependentKeys = await redis.smembers(`tag:cache-keys-for-listing:${listingId}`);
  if (dependentKeys.length > 0) {
    await redis.del(...dependentKeys);
  }
  await redis.del(`tag:cache-keys-for-listing:${listingId}`);
}
```

**TTL is still required as a safety net.** Events get lost (queue partition, subscriber down, replay missed). Without TTL, a missed event leaves a stale entry forever. The TTL is the upper bound; the event provides best-effort fast invalidation.

**Don't over-invalidate.** Tagging every cache entry by every listing it contains adds write overhead. For high-volume search caches, accept TTL-bound staleness on the search-results cache and apply event-driven invalidation only to the per-listing direct cache.

**For Personalize:** PutEvents is already the event-driven invalidation mechanism for the model. For the *cache* of Personalize outputs, event-driven invalidation comes from "campaign updated" → sweep cohort recommendations.

**For OpenSearch:** the bulk index write events can drive cache invalidation, but it's usually impractical at index-write rates. Better: short TTL on search-results cache, longer TTL on per-listing direct cache, event-driven invalidation only on the per-listing layer.

Reference: [AWS EventBridge schema registry](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-schema.html) · [Cloudflare cache tags](https://developers.cloudflare.com/cache/how-to/purge-cache/purge-by-tags/)
