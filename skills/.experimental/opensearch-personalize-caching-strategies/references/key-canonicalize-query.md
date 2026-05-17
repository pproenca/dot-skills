---
title: Canonicalise Queries Before Hashing
impact: CRITICAL
impactDescription: 3-10x hit rate increase by collapsing equivalent queries
tags: key, canonicalisation, normalisation, hash, search
---

## Canonicalise Queries Before Hashing

The same logical query can arrive in dozens of textual forms. `"new york"`, `"New York"`, `" new york "`, `"new  york"`, and `"new+york"` all describe one search; with naive `JSON.stringify(filters)` hashing they produce five different cache keys and four guaranteed misses. The same goes for filter arrays — `{categories: ["bar","restaurant"]}` and `{categories: ["restaurant","bar"]}` are logically equal but textually distinct. Canonical form is the contract between writer and reader of the cache; without it, hit rates plateau at a fraction of the achievable ceiling, no matter how big the cache.

**Incorrect (hash the raw input, accept whatever shape it has):**

```typescript
function buildCacheKey(q: string, filters: Record<string, unknown>) {
  return `search:${md5(q + JSON.stringify(filters))}`;
}
// "new york"               -> key A
// "New York"               -> key B  (different cache line)
// "new  york"              -> key C
// filters {a:1,b:2}        -> key D
// filters {b:2,a:1}        -> key E  (different cache line for same filter)
// Hit rate flattens at ~15% even with a large cache.
```

**Correct (canonical pipeline applied before hashing):**

```typescript
import { createHash } from 'node:crypto';

interface SearchInput {
  q: string;
  filters: Record<string, string | number | boolean | string[]>;
  locale: string;
  sort?: string;
  page?: number;
}

function canonicalise(input: SearchInput): SearchInput {
  return {
    // 1. Trim, collapse whitespace, lowercase, NFC-normalise the query string
    q: input.q.trim().replace(/\s+/g, ' ').toLowerCase().normalize('NFC'),

    // 2. Sort array values; sort object keys via JSON.stringify-with-sort
    filters: Object.fromEntries(
      Object.entries(input.filters)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([k, v]) => [k, Array.isArray(v) ? [...v].sort() : v])
    ),

    // 3. Locale is part of the result; never assume a default
    locale: input.locale.toLowerCase(),  // "en-GB" -> "en-gb"

    // 4. Default sort and page must be present even when unspecified
    sort: input.sort ?? 'relevance',
    page: input.page ?? 1,
  };
}

function buildCacheKey(input: SearchInput): string {
  const canon = canonicalise(input);
  return `search:${createHash('sha256').update(JSON.stringify(canon)).digest('hex').slice(0, 32)}`;
}

// "new york"          -> canon.q "new york"  -> key A
// "New York"          -> canon.q "new york"  -> key A  (HIT)
// "new  york"         -> canon.q "new york"  -> key A  (HIT)
// filters {a:1,b:2}   -> canon "{a:1,b:2}"   -> key D
// filters {b:2,a:1}   -> canon "{a:1,b:2}"   -> key D  (HIT)
```

**The unicode trap:** "café" can be encoded as `café` (NFD) or `café` (NFC). Browsers send mixed forms. Without `.normalize('NFC')` you cache the same word twice. Same for fullwidth/halfwidth characters in Asian locales.

**The sort-order trap:** Map/Set iteration order in older runtimes isn't insertion-ordered for non-string keys. Always sort explicitly; never trust object iteration order to produce a stable serialisation.

**Validate empirically:** in observability, track `distinct_keys_per_distinct_canonical_query`. If > 1.05, your canonicalisation has a leak.

Reference: [Unicode Normalization Forms (UAX #15)](https://www.unicode.org/reports/tr15/) · [Pinterest: Feature Caching for Recommender Systems](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762)
