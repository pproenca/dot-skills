---
title: Use CDN for Anonymous Traffic; Bypass for Cookies
impact: MEDIUM-HIGH
impactDescription: 10-50x latency reduction via edge POPs for anonymous traffic
tags: tier, cdn, cloudfront, anonymous, edge
---

## Use CDN for Anonymous Traffic; Bypass for Cookies

Anonymous search and recommender responses are a globally-shared keyspace (see [pers-anonymous-vs-logged-split](pers-anonymous-vs-logged-split.md)) — perfect for a CDN. CloudFront, Fastly, or Cloudflare cache the response at the edge POP nearest the user, serving thousands of distant users from a handful of edge entries. Origin RTT drops from 50-200ms (transcontinental) to 5-20ms (edge POP). The trick: configure cache keys so anonymous requests share entries (no cookie, no Authorization header), and logged-in requests bypass the cache entirely or use a different cache key namespace.

**Incorrect (single cache key, cookies pollute, hit rate collapses):**

```yaml
# CloudFront distribution config — naive
DefaultCacheBehavior:
  TargetOriginId: search-api
  ViewerProtocolPolicy: redirect-to-https
  # Forward everything by default — including cookies — to origin AND key the cache by them
  ForwardedValues:
    Cookies:
      Forward: all      # <-- every cookie change makes a new cache key
    QueryString: true
    Headers:
      - Authorization   # <-- every logged-in user has unique Authorization, no reuse
```

**Correct (split cache behaviour by surface; anonymous shares, logged-in bypasses):**

```yaml
CacheBehaviors:
  # /api/search/anon/* — cached at edge
  - PathPattern: /api/search/anon/*
    TargetOriginId: search-api
    CachePolicyId: !Ref AnonSearchCachePolicy
    OriginRequestPolicyId: !Ref AnonSearchOriginPolicy
    ViewerProtocolPolicy: redirect-to-https
    Compress: true

  # /api/search/personalized/* — bypass edge cache
  - PathPattern: /api/search/personalized/*
    TargetOriginId: search-api
    CachePolicyId: !Ref BypassCachePolicy
    ViewerProtocolPolicy: redirect-to-https

AnonSearchCachePolicy:
  Type: AWS::CloudFront::CachePolicy
  Properties:
    CachePolicyConfig:
      Name: AnonSearchPolicy
      DefaultTTL: 300
      MaxTTL: 3600
      ParametersInCacheKeyAndForwardedToOrigin:
        QueryStringsConfig:
          QueryStringBehavior: whitelist
          QueryStrings:
            QueryString: [q, filters, locale, currency, sort, page]
            # Note: utm_*, request_id, _t, ts NOT whitelisted -> stripped by edge
        HeadersConfig:
          HeaderBehavior: whitelist
          Headers:
            Header: [CloudFront-Viewer-Country]  # for geo-keyed cache
        CookiesConfig:
          CookieBehavior: none     # <-- NO cookies in cache key, no cookies forwarded
```

**Origin response headers that drive edge caching:**

```typescript
// In the search-api response handler for anonymous routes:
app.get('/api/search/anon/*', async (req, res) => {
  const result = await search(req.query.q, ctx);
  res.set('Cache-Control', 'public, max-age=300, s-maxage=600, stale-while-revalidate=60, stale-if-error=86400');
  res.set('Vary', 'Accept-Encoding, CloudFront-Viewer-Country');
  res.json(result);
});

// - max-age: browser cache (5 min)
// - s-maxage: CDN edge cache (10 min) — different from browser
// - stale-while-revalidate: serve stale at edge while async-refreshing (60s window)
// - stale-if-error: 24h fallback on origin error
// - Vary by country header: geo-segmented at the edge
```

**Cookie elimination is the hard part.** Frontend frameworks often set unnecessary cookies (analytics opt-in, A/B bucket, locale preference). For routes served by CDN, either (a) route from a cookie-free subdomain (`anon.example.com`), (b) strip cookies at the edge before they reach the cache layer, or (c) accept that any cookie set on the apex domain blocks CDN caching on those routes.

**A/B treatments at the edge:** if you must serve different content per A/B arm to anonymous users, key the cache by the bucket header (computed at the edge from IP/user-agent hash). Each bucket is its own cache key — N times the storage but still globally shareable.

**For logged-in routes:** use the L1+L2 application-tier pattern ([strat-tiered-promotion](strat-tiered-promotion.md)). CDN can still front them with `Cache-Control: private, max-age=60` for browser-side caching, but the edge cache stays empty.

**Personalize at the edge?** Personalize calls can't be served from a CDN because they're per-user. For anonymous "popularity" content, the CDN serves the cached response from OpenSearch directly (see [pers-cold-start-cache-priority](pers-cold-start-cache-priority.md)).

Reference: [CloudFront cache policies](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html) · [Fastly cache invalidation](https://www.fastly.com/documentation/guides/concepts/edge-state/purging/) · [Cloudflare cache rules](https://developers.cloudflare.com/cache/how-to/cache-rules/)
