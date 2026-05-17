---
title: Use Write-Through When User Mutations Are Immediately Re-Read
impact: HIGH
impactDescription: eliminates the "I saved it but I don't see it" UX bug
tags: strat, write-through, mutations, consistency, user-state
---

## Use Write-Through When User Mutations Are Immediately Re-Read

When a user performs an action that produces an immediate re-read — favourite a listing then look at their favourites, save a search then open saved searches, accept a recommendation then load the next page — cache-aside introduces a window in which the cached value is stale. The user mutates the underlying store, but the cache still holds the pre-mutation value. The product bug is "I clicked save but it's not showing up." Write-through fixes this by updating the cache *as part of the write transaction*: the write returns only after the cache has been updated. Reads then see the new state immediately. Use sparingly — write-through couples writes to cache availability, so it's reserved for the specific mutate-then-read paths.

**Incorrect (cache-aside with TTL — stale window after mutation):**

```typescript
async function favouriteListing(userId: string, listingId: string) {
  await db.insert('favourites', { userId, listingId });
  // No cache invalidation. The user's favourites cache will return stale data
  // until the 5-minute TTL expires.
}

async function getFavourites(userId: string) {
  const cached = await redis.get(`favs:${userId}`);
  if (cached) return JSON.parse(cached);  // STALE for up to 5 min after a favourite
  const fresh = await db.select('favourites', { userId });
  await redis.set(`favs:${userId}`, JSON.stringify(fresh), 'EX', 300);
  return fresh;
}
// Product bug: "I favourited it but it's not in my favourites." Reproducible.
```

**Correct (write-through update on the mutation path):**

```typescript
async function favouriteListing(userId: string, listingId: string) {
  // 1. Persist to durable store (source of truth)
  await db.insert('favourites', { userId, listingId });

  // 2. Update the cache as part of the write transaction
  //    — the write does not "complete" until this succeeds
  const fresh = await db.select('favourites', { userId });
  await redis.set(`favs:${userId}`, JSON.stringify(fresh), 'EX', 300);
}

async function getFavourites(userId: string) {
  const cached = await redis.get(`favs:${userId}`);
  if (cached) return JSON.parse(cached);  // always fresh after a write
  const fresh = await db.select('favourites', { userId });
  await redis.set(`favs:${userId}`, JSON.stringify(fresh), 'EX', 300);
  return fresh;
}
```

**The pattern is durable-write first, cache-update second.** If the cache update fails, the durable store is the source of truth — the cache will heal on its TTL or on the next read miss. Reversing the order (cache-first, then DB) makes the cache inconsistent with the durable store on DB failure — far worse.

**Write-around variant** (cache-invalidate, not cache-update): if the new value is expensive to compute, write to DB and *delete* the cache entry. The next read miss recomputes. This avoids the work of building the new cached value during the write — but the next read pays the origin cost. Choose based on read-after-write latency requirements.

**Don't apply write-through to search results.** A new listing being indexed doesn't justify updating every search cache that might contain it — there are too many. Use TTL or event-driven invalidation by tag ([ttl-event-driven-invalidation](ttl-event-driven-invalidation.md)) instead.

**Don't apply write-through to Personalize state.** Personalize is event-driven via PutEvents; the model updates asynchronously over seconds-to-minutes. Trying to write-through Personalize recommendations on every PutEvent collapses the cache and produces no consistency benefit (the model is still updating).

**Apply write-through to:**
- User favourites / saved items / wishlists
- User-edited preferences / settings
- Cart contents (after add-to-cart, the next page renders the cart)
- Saved searches (after save, the saved-searches list opens)
- Profile edits

Reference: [AWS ElastiCache write-through](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html#Strategies.WriteThrough) · [Wikipedia: Cache write policies](https://en.wikipedia.org/wiki/Cache_(computing)#Writing_policies)
