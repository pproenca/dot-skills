---
title: Sync View-State to the URL for Deep Links
impact: MEDIUM
impactDescription: prevents losing the view on reload or share
tags: interact, deep-link, url, view-state, shareable
---

## Sync View-State to the URL for Deep Links

A code map is most useful when a specific view — "Billing region, zoomed to the failing module" — can be linked in a PR or bookmarked. If the camera lives only in memory, every reload resets to the overview and there is no way to share what you are looking at. Serialise the view-state (and the selected geohash prefix, [[nav-breadcrumb-prefix-path]]) into the URL, throttled so panning does not spam history, and restore from it on load. The URL becomes the map's shareable address.

**Incorrect (view in memory only):**

```typescript
let view = defaultView;
onViewChange((v) => { view = v; });   // nothing leaves memory; reload loses it
```

**Correct (view round-trips through the URL; throttled writes, restore on load):**

```typescript
const writeUrl = throttle((v: ViewState) =>
  history.replaceState(null, "", `#${v.zoom.toFixed(2)}/${v.x.toFixed(4)}/${v.y.toFixed(4)}`), 200);
onViewChange((v) => { view = v; writeUrl(v); });
view = parseHash(location.hash) ?? defaultView;   // a deep link restores the exact view
```

**When NOT to apply:**
- An ephemeral embedded preview that should always open at the overview deliberately omits URL state.

Reference: [MapLibre GL JS (hash option)](https://maplibre.org/); [MDN — History.replaceState](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState)
