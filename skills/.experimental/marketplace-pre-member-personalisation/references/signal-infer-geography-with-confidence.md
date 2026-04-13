---
title: Infer Geography from IP with Confidence Caveats
impact: CRITICAL
impactDescription: enables same-region content without false certainty
tags: signal, geo-ip, confidence
---

## Infer Geography from IP with Confidence Caveats

Geo-IP lookup gives the marketplace a rough region for every anonymous visitor, and that signal is enormously valuable for preview content — showing sitters in the visitor's own city converts better than showing global popularity. But geo-IP is wrong often enough (VPNs, corporate networks, mobile carriers, edge cache locations) that treating it as definitive is dangerous. Store the inferred region alongside its confidence level, use high-confidence regions directly, and for low-confidence regions fall back to showing an explicit "is this your area?" chooser rather than hardcoding the wrong city.

**Incorrect (geo-IP treated as definitive, no confidence, no override):**

```python
def landing_page_data(request: Request) -> LandingPageData:
    region = geoip_lookup(request.client_ip)
    return LandingPageData(
        hero_text=f"Trusted sitters in {region.city}",
        featured_listings=listings_in_city(region.city, limit=12),
    )
```

**Correct (geo-IP confidence drives whether city is shown or user is asked):**

```python
def landing_page_data(request: Request) -> LandingPageData:
    geo = geoip_lookup(request.client_ip)

    if geo.confidence >= 0.85 and geo.resolution == "city":
        return LandingPageData(
            hero_text=f"Trusted sitters in {geo.city}",
            featured_listings=listings_in_city(geo.city, limit=12),
            region_source="geoip_high",
            editable_region=True,
        )

    return LandingPageData(
        hero_text="Tell us where you need a sitter",
        featured_listings=listings_in_country(geo.country or "GB", limit=12),
        region_source="geoip_low",
        show_region_chooser=True,
    )
```

Reference: [Hightouch — Contextual Bandits for Marketers](https://hightouch.com/blog/contextual-bandits-for-marketers)
