---
title: Provide a Text Alternative for the Canvas
impact: MEDIUM
impactDescription: prevents the map being invisible to screen readers
tags: access, screen-reader, canvas, fallback-content, aria
---

## Provide a Text Alternative for the Canvas

A `<canvas>` exposes nothing to a screen reader but its bitmap — the pixels are opaque to assistive technology. Provide a parallel, accessible representation: fallback DOM nested inside the canvas element (a list of regions and their key metrics, kept in sync), or an ARIA live region that summarises the current view ("Billing region, 1,240 files, 3 failing"). Screen-reader users then get the same structure sighted users see, and the map degrades to a navigable outline rather than a void.

**Incorrect (bare canvas):**

```typescript
<canvas id="map" />   // a silent rectangle to assistive technology
```

**Correct (a synced DOM outline inside the canvas as its accessible alternative):**

```typescript
<canvas id="map" aria-label="Code map">
  <ul aria-label="Regions">
    {regions.map((r) => (
      <li key={r.prefix}>{r.name}: {r.fileCount} files, {r.failing} failing</li>
    ))}
  </ul>
</canvas>   // screen readers read the list; the canvas paints the same data
```

**When NOT to apply:**
- A decorative canvas conveying no information uses `role="presentation"` and empty alt text instead — there is no data to mirror.

Reference: [MDN — `<canvas>` accessibility concerns](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/canvas); [WCAG 2.2 — Non-text Content (1.1.1)](https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html)
