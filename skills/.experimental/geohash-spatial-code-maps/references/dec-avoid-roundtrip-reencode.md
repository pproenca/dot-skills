---
title: Keep the Original Hash; Don't Decode-then-Re-encode to "Normalise"
impact: MEDIUM-HIGH
impactDescription: prevents cell drift from round-trip conversions
tags: dec, round-trip, drift, normalization, idempotency
---

## Keep the Original Hash; Don't Decode-then-Re-encode to "Normalise"

It is tempting to "normalise" a stored geohash by decoding it to a point and re-encoding. But the decoded centre sits on a cell's halfway line, and floating-point rounding in the re-encode can push it into a neighbouring cell — so the round-trip is not idempotent and your "normalised" hash names a different cell. Treat the hash string as the source of truth; truncate it for coarser precision instead of decoding and re-encoding.

**Incorrect (decode then re-encode):**

```typescript
function coarsen(hash: string, len: number): string {
  const { lat, lon } = decodeCenter(hash);
  return encode(lat, lon, len); // may land one cell over — not the parent of `hash`
}
```

**Correct (truncate the string for coarser precision):**

```typescript
function coarsen(hash: string, len: number): string {
  if (len > hash.length) throw new RangeError("cannot coarsen to a finer precision");
  return hash.slice(0, len); // the parent cell, exactly and idempotently
}
```

**When NOT to apply:**
- Re-encoding is correct when you genuinely have a *new* coordinate (an updated GPS fix). The anti-pattern is round-tripping an existing hash through coordinates with no new information.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
