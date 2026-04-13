---
title: Extract Role from URL Path and Referrer Before First Render
impact: CRITICAL
impactDescription: enables side-specific content on the first page
tags: signal, routing, url
---

## Extract Role from URL Path and Referrer Before First Render

A visitor landing on `/become-a-sitter` is almost certainly on the supply side; a visitor landing on `/find-a-sitter` is almost certainly on the demand side. Treating every landing page the same way wastes the single richest signal the system has — the URL the visitor chose to click — and forces the team to ask role questions in an onboarding form that users will abandon. Extract the role hint from the URL path, referrer, campaign parameters and internal link context on the server before the first byte is rendered, so the very first page the visitor sees is already shaped to their side.

**Incorrect (role inferred late, every landing page generic):**

```typescript
export async function getPageProps(req: Request): Promise<PageProps> {
  return {
    hero: defaultHero(),
    heroListings: topListingsGlobal(limit: 12),
    cta: "Join the marketplace",
  }
}
```

**Correct (role inferred from URL, referrer and UTM before render):**

```typescript
export async function getPageProps(req: Request): Promise<PageProps> {
  const role = inferRole({
    path: req.url.pathname,
    referrer: req.headers.get("referer"),
    utmCampaign: req.query.utm_campaign,
    internalLinkSource: req.query.src,
  })

  return {
    hero: role === "sitter" ? sitterHero() : ownerHero(),
    heroListings: role === "sitter"
      ? popularStaysByRegion(req.geo.region, limit: 12)
      : popularSittersByRegion(req.geo.region, limit: 12),
    cta: role === "sitter" ? "Start sitting" : "Find a sitter",
    inferredRole: role,
    inferredRoleConfidence: confidenceFor(role),
  }
}
```

Reference: [Kameleoon — Contextual Bandits Guide](https://www.kameleoon.com/blog/contextual-bandits)
