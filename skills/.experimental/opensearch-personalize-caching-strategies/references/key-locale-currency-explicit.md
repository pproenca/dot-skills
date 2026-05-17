---
title: Make Locale, Currency, and Timezone Explicit in the Key
impact: CRITICAL
impactDescription: prevents silent cross-locale cache poisoning
tags: key, locale, i18n, currency, timezone
---

## Make Locale, Currency, and Timezone Explicit in the Key

Search results, recommendations, and ranked listings depend on the user's locale (language → analysers, synonyms, copy), currency (prices, price filters, "from €99" copy), and timezone (date filters, "open now" status, time-decay scoring). When these aren't in the cache key, the first request "wins" — a user in `en-GB` populates the cache, and `pt-PT` requests get English copy, GBP prices, and London times. The bug is silent: results render, no error fires, only the content is wrong. Always-explicit locale/currency/timezone in the key prevents this category of bug entirely.

**Incorrect (locale/currency/timezone implicit, derived from request headers but not keyed):**

```typescript
async function search(q: string, ctx: RequestContext) {
  const key = `search:${md5(q + JSON.stringify(ctx.filters))}`;
  const cached = await redis.get(key);
  if (cached) {
    // ctx.locale was 'en-GB' when this was written — we no-op the locale here.
    return JSON.parse(cached);
  }
  const result = await opensearch.search(buildQuery(q, ctx));  // uses ctx.locale internally
  await redis.set(key, JSON.stringify(result), 'EX', 600);
  return result;
}
// Request 1: locale=en-GB, currency=GBP, tz=Europe/London  -> populates the cache
// Request 2: locale=pt-PT, currency=EUR, tz=Europe/Lisbon  -> CACHE HIT, gets en-GB result.
// User in Lisbon sees English copy and GBP prices.
```

**Correct (locale/currency/timezone in the key, explicit):**

```typescript
async function search(q: string, ctx: RequestContext) {
  const canon = canonicalise({
    q,
    filters: ctx.filters,
    locale: ctx.locale,         // 'en-gb' (lowercased in canonicalise)
    currency: ctx.currency,     // 'GBP' — uppercased; ISO 4217
    timezone: ctx.timezone,     // 'Europe/London' — IANA tz name, NOT 'BST'
  });
  const key = `search:${sha256(canon)}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const result = await opensearch.search(buildQuery(q, ctx));
  await redis.set(key, JSON.stringify(result), 'EX', 600);
  return result;
}
// Different locale/currency/tz produces different keys -> clean separation.
```

**The timezone subtleties:** use IANA names (`Europe/London`), never the local abbreviation (`BST` vs `GMT` flips by season — same user, two cache keys 6 months apart). Many libraries (Moment, Day.js without timezone plugins) silently use the server's timezone — always pass an explicit tz.

**The currency-formatting trap:** even if prices are stored as integers in cents/pence, the rendered price strings differ per currency. If you cache the rendered string, currency MUST be in the key. If you cache only the raw integer, currency can be applied post-cache.

**Multi-tenant SaaS variant:** include `tenantId` for the same reason. Same query, different tenant configs (synonyms, boosts, taxonomy) — all keyed separately.

**Validation:** track `(distinct_keys / distinct_locales / distinct_currencies) ≈ 1.0` in observability. If users with different locales/currencies produce the same key, the bug is here.

Reference: [Unicode CLDR — locale identifiers](https://cldr.unicode.org/) · [IANA Time Zone Database](https://www.iana.org/time-zones)
