---
title: Use the Geohash Prefix as Navigation State and Deep Link
impact: MEDIUM
impactDescription: prevents fragile coordinate links; enables region deep links
tags: nav, deep-link, breadcrumb, url-state, navigation
---

## Use the Geohash Prefix as Navigation State and Deep Link

In a map you want to share "look here" and show "where am I". A geohash prefix *is* that location state: each character is one step down a breadcrumb (`g → gc → gcp → gcpu`), and the current prefix encodes the viewport's region in a few characters. Put it in the URL and a link deep-links straight to a region; back/forward and breadcrumbs fall out of the prefix path. Tracking pan/zoom as opaque lat/lon/zoom triples instead loses the natural hierarchy and makes links fragile to rounding.

**Incorrect (opaque coordinate triple in the URL):**

```typescript
history.pushState(null, "", `?lat=${lat}&lon=${lon}&z=${zoom}`);
// no hierarchy, no breadcrumb, brittle to rounding
```

**Correct (prefix as the route; breadcrumb from the path):**

```typescript
function navigateTo(prefix: string) {
  history.pushState({ prefix }, "", `#/g/${prefix}`); // deep-linkable region
}
function breadcrumb(prefix: string): { label: string; prefix: string }[] {
  return [...prefix].map((_, i) => ({
    label: prefix.slice(0, i + 1),
    prefix: prefix.slice(0, i + 1), // click any crumb to zoom to that region
  }));
}
// On load: read location.hash -> prefix -> centre/zoom via decodeBbox(prefix).
```

For a code map this means a link like `#/g/gcpuv` jumps straight to a domain region ([[map-prefix-as-domain-region]]).

**When NOT to apply:**
- Views that must restore an exact centre and fractional zoom (not a whole cell) still need explicit coordinates — use the prefix for the region and a small offset for the precise framing.

Reference: [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
