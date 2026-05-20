---
title: Recompute Interval Midpoints; Never Accumulate a Float Step
impact: CRITICAL
impactDescription: prevents off-by-one cell errors at precision >= 9
tags: enc, floating-point, binary-search, precision, drift
---

## Recompute Interval Midpoints; Never Accumulate a Float Step

The encoder narrows `[lo, hi]` by repeated halving. If you precompute a fixed step (`range / 2^bits`) and add it cumulatively, floating-point rounding accumulates over 50+ iterations and the last bit flips for points near a cell edge — the hash jumps to the wrong neighbouring cell. Recomputing `mid = (lo + hi) / 2` each step keeps the comparison exact relative to the current interval, which is what the standard requires.

**Incorrect (cumulative step accumulates error):**

```rust
fn chop_bad(value: f64, lo: f64, hi: f64, bits: u8) -> u64 {
    let mut step = (hi - lo) / 2.0;     // precomputed once
    let mut acc = lo;
    let mut out = 0u64;
    for _ in 0..bits {
        out <<= 1;
        if value >= acc + step { out |= 1; acc += step; } // drift compounds each add
        step /= 2.0;
    }
    out
}
```

**Correct (recompute the midpoint from the live bounds):**

```rust
fn chop_good(value: f64, mut lo: f64, mut hi: f64, bits: u8) -> u64 {
    let mut out = 0u64;
    for _ in 0..bits {
        out <<= 1;
        let mid = (lo + hi) / 2.0;       // exact w.r.t. the current interval
        if value >= mid { out |= 1; lo = mid; } else { hi = mid; }
    }
    out
}
```

**When NOT to apply:**
- At low precision (length <= 6) the drift rarely crosses a cell boundary — but there is no performance reason to prefer the buggy form, since the correct version costs the same.

Reference: [Wikipedia — Geohash (binary subdivision)](https://en.wikipedia.org/wiki/Geohash)
