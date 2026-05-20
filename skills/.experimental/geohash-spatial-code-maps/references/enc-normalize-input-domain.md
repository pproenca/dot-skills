---
title: Clamp and Validate Coordinates Before Encoding
impact: CRITICAL
impactDescription: prevents silent garbage hashes from out-of-range input
tags: enc, validation, input-normalization, wraparound, robustness
---

## Clamp and Validate Coordinates Before Encoding

The binary chop assumes latitude in `[-90, 90]` and longitude in `[-180, 180]`. Feed it `lon = 200` or a `NaN` and it produces a hash with no warning — every bit comparison falls one way, so you get a corner cell that looks like a real location. The two axes need different handling: longitude is cyclic (wrap at ±180) while latitude is clamped (you cannot go past a pole). Validate and normalise at the system boundary before encoding.

**Incorrect (no validation, no wrap):**

```typescript
function encode(lat: number, lon: number, len: number): string {
  // lat = 95 silently encodes to the north edge; lon = 200 to the east edge;
  // NaN collapses to "s0000..." — all three look like valid locations.
  return toBase32(encodeBits(lat, lon, len * 5));
}
```

**Correct (clamp latitude, wrap longitude, reject non-finite):**

```typescript
function normalize(lat: number, lon: number): [number, number] {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new RangeError(`non-finite coordinate: ${lat}, ${lon}`);
  }
  const clampedLat = Math.max(-90, Math.min(90, lat));        // poles are hard limits
  const wrappedLon = ((((lon + 180) % 360) + 360) % 360) - 180; // 181 -> -179
  return [clampedLat, wrappedLon];
}

function encode(lat: number, lon: number, len: number): string {
  const [nlat, nlon] = normalize(lat, lon);
  return toBase32(encodeBits(nlat, nlon, len * 5));
}
```

Exactly ±180° longitude collapses to the west edge (`-180`) — the standard antimeridian aliasing, harmless for encoding but worth knowing if a caller passes a literal `180`.

**When NOT to apply:**
- If inputs come from a validated source (a branded coordinate already constrained to range) you can skip the per-call check.
- Always keep it at the boundary where raw user or API input first enters the system.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
