---
title: Use a Bloom Filter to Block High-Cardinality Miss Storms
impact: MEDIUM-HIGH
impactDescription: rejects invalid-id traffic before it reaches cache or origin
tags: neg, bloom-filter, cache-penetration, slug, defense
---

## Use a Bloom Filter to Block High-Cardinality Miss Storms

A high-cardinality miss storm is a load pattern where requests target keys that don't exist in either cache or origin — slug-not-found URLs from crawlers, listing IDs from stale links, hash-not-found cache keys from attacks. Each request: cache.GET (miss), origin.GET (404), no cache write, repeat. Negative caching ([neg-cache-empty-results](neg-cache-empty-results.md)) helps but requires Redis lookups per miss. A Bloom filter sits in front of both — set-membership check in ~100ns from in-process memory — and returns "definitely not found" without touching Redis or the origin.

**Incorrect (miss storms reach cache and origin):**

```typescript
async function getListingPage(slug: string) {
  const cached = await redis.get(`page:${slug}`);
  if (cached) return JSON.parse(cached);
  const fresh = await db.queryBySlug(slug);  // for nonexistent slugs, returns null
  if (fresh) {
    await redis.set(`page:${slug}`, JSON.stringify(fresh), 'EX', 600);
    return fresh;
  }
  return null;
}
// Attack/crawler hitting /listing/{random-slug} at 1000 req/s:
//   1000 cache misses/s -> 1000 DB queries/s -> all return null
//   Both cache and DB take load for nothing.
```

**Correct (Bloom filter rejects definite-misses before any IO):**

```typescript
import { BloomFilter } from 'bloom-filters';

// Built nightly from the canonical list of all valid slugs
//   - 10M slugs, 1% false-positive rate = ~12 MB
//   - Shipped to all instances at startup; updated via SIGHUP / config reload
let VALID_SLUGS: BloomFilter = await loadBloomFromS3('s3://catalog/valid-slugs.bloom');

async function getListingPage(slug: string) {
  // 1. Bloom filter check — in-process, ~100ns
  if (!VALID_SLUGS.has(slug)) {
    metrics.increment('bloom.rejected', { kind: 'slug' });
    return null;  // never reaches Redis or DB
  }

  // 2. Bloom said "possibly exists" — proceed with normal cache-aside
  const cached = await redis.get(`page:${slug}`);
  if (cached) return JSON.parse(cached);

  const fresh = await db.queryBySlug(slug);
  if (fresh) {
    await redis.set(`page:${slug}`, JSON.stringify(fresh), 'EX', 600);
    return fresh;
  }

  // Bloom false positive — slug doesn't exist after all
  // Cache the negative to avoid repeated DB hits on this slug
  await redis.set(`page:${slug}:miss`, '1', 'EX', 300);
  return null;
}
```

**Sizing the Bloom filter:**
- N items, FP rate p: size ~= -N * ln(p) / (ln(2)²)
- 10M items at 1% FP rate: ~12 MB; 0.1% FP rate: ~17 MB
- Memory is cheap; default to 0.1% if you can afford it

**Keep the Bloom filter fresh:**
- Nightly batch: rebuild from the catalog's authoritative list
- For new items added during the day: maintain a "delta" in Redis (`SADD valid-slugs-since-last-bloom-rebuild :slug`) and check both
- Or accept that new items have a brief window where Bloom returns "definitely not" — usually fine for SEO content with a 24h indexation lag

**The Cloudflare gotcha:** Cloudflare's "When Bloom Filters Don't Bloom" post documents that naive Bloom filter implementations have terrible cache locality and can be slower than a hash table. Use a well-implemented library (`bloom-filters` for Node, `pybloom-live` for Python, `Guava BloomFilter` for Java) with cache-aware design.

**When NOT to use a Bloom filter:**
- The set of valid keys is small and fits in a hash map (just use the hash map)
- Valid keys are highly volatile (real-time additions/removals — Bloom doesn't support deletion)
- Miss storms don't exist in your traffic pattern (web search has them; B2B SaaS often doesn't)

**Companion: rate limit by IP for the false-positive tail.** Even after Bloom rejection, a determined adversary can construct queries that pass the filter (cache penetration attack). Rate-limit per-IP at the edge as the second line.

Reference: [Cloudflare: When Bloom Filters Don't Bloom](https://blog.cloudflare.com/when-bloom-filters-dont-bloom/) · [Wikipedia: Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter)
