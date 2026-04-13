---
title: Capture Entry-Point Metadata on Every Page Load
impact: CRITICAL
impactDescription: enables acquisition-channel attribution and personalisation
tags: signal, acquisition, attribution
---

## Capture Entry-Point Metadata on Every Page Load

A visitor arriving from a paid Google ad for "dog sitter london" has a radically different intent profile from a visitor arriving from a friend's referral link or from an organic search for "what is a house sit". Each entry point carries priors the system can use immediately — intent specificity, urgency, commercial vs informational, role probability — but only if the full entry-point metadata (UTM parameters, referrer, campaign ID, landing path) is captured into the session on the very first page load and persisted so every subsequent event can reference it.

**Incorrect (entry-point metadata lost after first render):**

```typescript
export async function onFirstPageLoad(req: Request): Promise<void> {
  analytics.track("page_view", {
    url: req.url.pathname,
    user_agent: req.headers.get("user-agent"),
  })
}
```

**Correct (entry-point captured into session, persisted for the life of the journey):**

```typescript
export async function onFirstPageLoad(req: Request): Promise<void> {
  const entryPoint = {
    landing_path: req.url.pathname,
    referrer: req.headers.get("referer"),
    utm_source: req.query.utm_source,
    utm_medium: req.query.utm_medium,
    utm_campaign: req.query.utm_campaign,
    utm_term: req.query.utm_term,
    gclid: req.query.gclid,
    fbclid: req.query.fbclid,
    first_seen_at: new Date().toISOString(),
  }

  await session.setOnce("entry_point", entryPoint)

  analytics.track("page_view", {
    url: req.url.pathname,
    entry_point: entryPoint,
  })
}
```

Reference: [Snowplow — Users and Identity Stitching](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/)
