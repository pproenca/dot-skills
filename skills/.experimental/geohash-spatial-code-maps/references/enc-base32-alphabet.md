---
title: Use the Geohash Base32 Alphabet, Not RFC 4648
impact: CRITICAL
impactDescription: prevents unshareable, non-interoperable hashes
tags: enc, base32, alphabet, interoperability, encoding
---

## Use the Geohash Base32 Alphabet, Not RFC 4648

Geohash uses its own base32 alphabet — `0123456789bcdefghjkmnpqrstuvwxyz` — which deliberately omits `a`, `i`, `l`, and `o` to avoid visual ambiguity in printed and spoken hashes. It is **not** RFC 4648 base32 (`A–Z2–7`). Reach for a generic base32 encoder and every hash you emit is incompatible with maps, databases, and other libraries, and round-trips through your own decoder only by luck.

**Incorrect (standard-library base32):**

```typescript
import { base32 } from "rfc4648"; // A-Z, 2-7 — the WRONG alphabet
function badEncode(bits: Uint8Array): string {
  return base32.stringify(bits); // "MFRGG..." — not a geohash; no map will read it
}
```

**Correct (geohash alphabet, 5 bits per character):**

```typescript
const GEOHASH_BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"; // no a, i, l, o

function toBase32(bits: number[]): string {
  let hash = "";
  for (let i = 0; i < bits.length; i += 5) {
    let value = 0;
    for (let j = 0; j < 5; j++) value = (value << 1) | (bits[i + j] ?? 0);
    hash += GEOHASH_BASE32[value]; // index 0-31 into the geohash alphabet
  }
  return hash;
}
```

Decoding must use the same alphabet — build a reverse lookup table once rather than calling `indexOf` per character in a hot loop (see [[idx-integer-sortable-key]] for why the table representation matters at scale).

**When NOT to apply:**
- Never for interoperable geohashes.
- A purely internal token system that never leaves your process could use any alphabet, but you lose the ability to paste a hash into geohash.org or a tile server to debug it.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [davetroy/geohash-js](https://github.com/davetroy/geohash-js)
