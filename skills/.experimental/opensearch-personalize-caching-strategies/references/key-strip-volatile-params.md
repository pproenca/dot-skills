---
title: Strip Volatile and Tracking Params Before Hashing
impact: CRITICAL
impactDescription: hit rate collapses to <5% with UTM/request-id leakage
tags: key, normalisation, utm, request-id, hash
---

## Strip Volatile and Tracking Params Before Hashing

Query params with no effect on the result — UTM tags, request_id, client timestamp, browser fingerprint, A/B-bucket-disambiguation tokens — must never reach the hash. When they leak, every request gets a unique key by construction and the cache hit rate collapses to near-zero. The cache fills up with thousands of variants of the same logical request, evicting useful entries. The bug presents as "hit rate is 4% and the cache is full" — and the fix is upstream of the hash function: a strict allowlist of params that participate in the key.

**Incorrect (hash the whole URL or full request object):**

```typescript
function buildCacheKey(req: Request): string {
  // Includes everything: ?utm_source=newsletter&request_id=abc-123&ts=1717012345&q=pizza
  return `search:${sha256(req.url + JSON.stringify(req.body))}`;
}

// Every email-driven request has a different utm_content
// Every request from the frontend has a different request_id
// Every request gets a different ts
// Net effect: each cache entry is read exactly once before eviction.
// Hit rate: 3%.
```

**Correct (allowlist the keying params, ignore everything else):**

```typescript
// What participates in the key:
const KEYABLE_PARAMS = new Set([
  'q',           // the actual search query
  'filters',     // structured filter object (already canonicalised separately)
  'sort',
  'page',
  'pageSize',
  'locale',
  'currency',
  'timezone',
  'tenantId',
]);

// Everything else is explicitly excluded:
const VOLATILE_PARAMS = new Set([
  'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_id',
  'request_id', 'trace_id', 'span_id',
  'ts', 'timestamp', '_t',
  'cb', 'cache_bust', '_',
  'gclid', 'fbclid', 'mc_cid', 'mc_eid',
  'referrer', 'origin_url',
]);

function buildCacheKey(req: SearchRequest): string {
  // 1. Project to keyable fields only
  const keyed: Record<string, unknown> = {};
  for (const k of KEYABLE_PARAMS) {
    if (req[k] !== undefined) keyed[k] = req[k];
  }

  // 2. Assert: no volatile param leaked into the keyable set
  for (const k of Object.keys(keyed)) {
    if (VOLATILE_PARAMS.has(k)) {
      throw new Error(`Volatile param ${k} in cache key — likely a bug`);
    }
  }

  // 3. Canonicalise + hash (see key-canonicalize-query)
  const canon = canonicalise(keyed);
  return `search:${sha256(JSON.stringify(canon))}`;
}
```

**Allowlist, not denylist.** New tracking params get added by marketing, product analytics, and ad networks faster than you can denylist them. Allowlist what *should* affect the result; the rest is stripped by construction.

**The header trap:** beware of using `User-Agent` or `Cookie` as part of the key. A cookie change (a session refresh, a consent banner click) creates a new key for the same user. Pick the specific cookie fields you need (`tenant_id`, `cohort_id`) and ignore the rest of the header.

**Frontend cooperation:** for client-driven caches (Service Worker, SWR), publish the canonicalisation rules to the frontend so requests are stripped before they leave the browser. Otherwise you pay for the round trip even on hits.

**Validation:** in observability, plot `cache_keys_per_canonical_request`. Expected: 1.0. If > 1.1, a volatile param has leaked.

Reference: [Cloudflare cache key documentation](https://developers.cloudflare.com/cache/how-to/cache-keys/) · [HTTP RFC 9111 — Caching](https://www.rfc-editor.org/rfc/rfc9111)
