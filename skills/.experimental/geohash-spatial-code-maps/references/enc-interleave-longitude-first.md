---
title: Interleave Longitude on Even Bits, Latitude on Odd
impact: CRITICAL
impactDescription: prevents 100% of swapped-axis hashes
tags: enc, bit-interleaving, longitude, latitude, morton
---

## Interleave Longitude on Even Bits, Latitude on Odd

Geohash interleaves the binary subdivisions of longitude and latitude into one bitstream, with longitude taking the even bit positions (the very first bit) and latitude the odd positions. Swap the order and every hash you produce is internally consistent but incompatible with every other geohash system on earth — your "London" decodes to the Indian Ocean in Redis, PostGIS, or any tile server. The asymmetry is also why cells are wider than tall: longitude gets one extra bit at odd lengths.

**Incorrect (latitude taken first):**

```typescript
// Bits alternate lat, lon, lat, lon... — the WRONG order.
function encodeBits(lat: number, lon: number, bits: number): number[] {
  const latRange = [-90, 90], lonRange = [-180, 180];
  const out: number[] = [];
  for (let i = 0; i < bits; i++) {
    if (i % 2 === 0) {                        // even bit -> latitude (WRONG)
      const mid = (latRange[0] + latRange[1]) / 2;
      if (lat >= mid) { out.push(1); latRange[0] = mid; } else { out.push(0); latRange[1] = mid; }
    } else {                                  // odd bit -> longitude (WRONG)
      const mid = (lonRange[0] + lonRange[1]) / 2;
      if (lon >= mid) { out.push(1); lonRange[0] = mid; } else { out.push(0); lonRange[1] = mid; }
    }
  }
  return out; // hashes incompatible with every standard geohash library
}
```

**Correct (longitude on even bits, latitude on odd):**

```typescript
function encodeBits(lat: number, lon: number, bits: number): number[] {
  const latRange = [-90, 90], lonRange = [-180, 180];
  const out: number[] = [];
  for (let i = 0; i < bits; i++) {
    if (i % 2 === 0) {                        // even bit -> longitude (correct)
      const mid = (lonRange[0] + lonRange[1]) / 2;
      if (lon >= mid) { out.push(1); lonRange[0] = mid; } else { out.push(0); lonRange[1] = mid; }
    } else {                                  // odd bit -> latitude (correct)
      const mid = (latRange[0] + latRange[1]) / 2;
      if (lat >= mid) { out.push(1); latRange[0] = mid; } else { out.push(0); latRange[1] = mid; }
    }
  }
  return out;
}
```

**The same invariant in Rust:**

```rust
// even bit index -> longitude, odd -> latitude
fn encode_bits(lat: f64, lon: f64, bits: u8) -> u64 {
    let (mut lat_lo, mut lat_hi) = (-90.0_f64, 90.0_f64);
    let (mut lon_lo, mut lon_hi) = (-180.0_f64, 180.0_f64);
    let mut hash = 0u64;
    for i in 0..bits {
        hash <<= 1;
        if i % 2 == 0 {
            let mid = (lon_lo + lon_hi) / 2.0;     // longitude on even bits
            if lon >= mid { hash |= 1; lon_lo = mid; } else { lon_hi = mid; }
        } else {
            let mid = (lat_lo + lat_hi) / 2.0;     // latitude on odd bits
            if lat >= mid { hash |= 1; lat_lo = mid; } else { lat_hi = mid; }
        }
    }
    hash
}
```

**When NOT to apply:**
- Never — the order is fixed by the geohash standard.
- The only reason to revisit is a deliberately private, non-interoperable variant; if you build one, document the bit order loudly because no standard tool will read it.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
