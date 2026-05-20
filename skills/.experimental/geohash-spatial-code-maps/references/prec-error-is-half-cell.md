---
title: Report Decoded Accuracy as Half the Cell, Not the Full Cell
impact: CRITICAL
impactDescription: prevents 2x overstated accuracy
tags: prec, error-margin, decoding, accuracy, bounding-box
---

## Report Decoded Accuracy as Half the Cell, Not the Full Cell

A geohash names a cell; the only thing you know about the original point is that it lies somewhere inside. The decoded centre is therefore accurate to ±half the cell width/height, not the full cell. Reporting the full cell dimension as the error doubles your stated uncertainty and breaks any logic that decides "are these two hashes close enough" using the margin.

**Incorrect (full-cell error):**

```typescript
function decodeWithError(hash: string) {
  const { width, height } = cellDimensions(hash.length);
  return { lat, lon, latErr: height, lonErr: width }; // 2x too large
}
```

**Correct (half-cell error from the bounding box):**

```typescript
function decodeWithError(hash: string) {
  const [latMin, lonMin, latMax, lonMax] = decodeBbox(hash);
  return {
    lat: (latMin + latMax) / 2,
    lon: (lonMin + lonMax) / 2,
    latErr: (latMax - latMin) / 2, // ± half the cell height
    lonErr: (lonMax - lonMin) / 2, // ± half the cell width
  };
}
```

The half-cell error falls out for free once you decode to a bounding box instead of a bare point — see [[dec-decode-to-bbox]].

**When NOT to apply:**
- Never overstate accuracy.
- If a consumer genuinely wants the full cell extent (e.g. to draw the cell rectangle), give them the bounding box explicitly rather than mislabelling it as "error".

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
