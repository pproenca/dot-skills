---
title: Normalise the Code Plane into the Geohash Lat/Lon Domain
impact: HIGH
impactDescription: prevents out-of-range coordinates colliding at a corner
tags: map, normalization, affine, domain, coordinate-space
---

## Normalise the Code Plane into the Geohash Lat/Lon Domain

Your layout produces coordinates in some arbitrary range; geohash encoders expect latitude in `[-90, 90]` and longitude in `[-180, 180]`. Map your plane into that domain with a single fixed affine transform so you can reuse every standard geohash library, tile server, and visualiser without modification. Keep the transform square (equal scale on both axes) and skip the `cos(latitude)` metric correction — your code plane has no real geography, so a square grid is exactly what you want ([[prec-cells-shrink-toward-poles]]).

**Incorrect (feed raw layout coordinates to the encoder):**

```typescript
const [x, y] = coordOf(file); // e.g. x in [-3.2, 4.8], y in [0, 1200]
const hash = encode(y, x, 9); // out of range -> clamped to a corner; all files collide
```

**Correct (fixed affine map into the geohash domain):**

```typescript
function makeProjector(b: { minX: number; maxX: number; minY: number; maxY: number }) {
  const span = Math.max(b.maxX - b.minX, b.maxY - b.minY); // one square scale for both axes
  return ([x, y]: [number, number]): { lat: number; lon: number } => ({
    lon: ((x - b.minX) / span) * 360 - 180, // -> [-180, 180)
    lat: ((y - b.minY) / span) * 180 - 90,  // -> [-90, 90), same scale
  });
}

const toGeo = makeProjector(layoutBounds);
const { lat, lon } = toGeo(coordOf(file));
const hash = encode(lat, lon, 9); // standard tooling now works
```

Compute `layoutBounds` once from the full layout and persist it ([[map-persist-coordinate-sidecar]]); recomputing the bounds per run shifts every hash.

**When NOT to apply:**
- If you have written a geohash encoder that accepts an arbitrary square domain directly, you can skip the lat/lon remap — but you lose drop-in compatibility with off-the-shelf map tooling.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [OSM Slippy Map](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)
