---
title: Accumulate Exactly Five Bits per Character
impact: CRITICAL
impactDescription: prevents truncated or misaligned hashes
tags: enc, base32, bit-packing, alignment, precision
---

## Accumulate Exactly Five Bits per Character

Each base32 character carries exactly 5 bits, so a length-N geohash is `N × 5` bits, with the longitude/latitude split alternating 3/2 within each character. If your bit loop and your character loop disagree — emitting a char every 4 bits, or stopping mid-character — you get a hash that is the wrong length, or whose final character encodes leftover bits as zeros and shifts the decoded cell. Drive the encoder by total bit count (`N × 5`) and flush a character only on a 5-bit boundary.

**Incorrect (flushes on the wrong boundary):**

```rust
fn pack_bad(bits: &[u8]) -> String {
    let mut out = String::new();
    let mut acc = 0u8;
    for (i, &b) in bits.iter().enumerate() {
        acc = (acc << 1) | b;
        if (i + 1) % 4 == 0 {            // 4-bit flush -> base16-ish, not geohash
            out.push(BASE32[acc as usize] as char);
            acc = 0;
        }
    }
    out
}
```

**Correct (flush every 5 bits; require a multiple of 5):**

```rust
fn pack_good(bits: &[u8]) -> String {
    debug_assert!(bits.len() % 5 == 0, "geohash bit length must be a multiple of 5");
    let mut out = String::with_capacity(bits.len() / 5);
    for chunk in bits.chunks_exact(5) {
        let v = chunk.iter().fold(0u8, |acc, &b| (acc << 1) | b);
        out.push(BASE32[v as usize] as char);
    }
    out
}
```

**When NOT to apply:**
- Never relax the 5-bit boundary for string geohashes.
- Internal integer geohashes ([[enc-integer-morton-encode]]) are not character-aligned and use a raw bit count, so the multiple-of-5 rule does not apply there.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [davetroy/geohash-js](https://github.com/davetroy/geohash-js)
