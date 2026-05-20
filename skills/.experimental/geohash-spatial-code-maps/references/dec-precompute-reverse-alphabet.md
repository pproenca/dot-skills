---
title: Decode with a Precomputed Reverse-Alphabet Table
impact: MEDIUM-HIGH
impactDescription: O(1) per character and rejects invalid input
tags: dec, alphabet, lookup-table, validation, performance
---

## Decode with a Precomputed Reverse-Alphabet Table

Decoding maps each character back to its 5-bit value. Calling `GEOHASH_BASE32.indexOf(c)` per character is O(32) each and silently returns `-1` for an invalid character (`a`, `i`, `l`, `o`, or an uppercase typo), which then corrupts the bitstream without an error. Build a reverse table once: it is O(1) per character and lets you reject invalid input explicitly instead of decoding garbage.

**Incorrect (indexOf per character, no validation):**

```typescript
function charValue(c: string): number {
  return GEOHASH_BASE32.indexOf(c); // O(32); returns -1 for 'a','i','l','o' -> garbage bits
}
```

**Correct (precomputed table with explicit rejection):**

```typescript
const DECODE_MAP: Record<string, number> = {};
for (let i = 0; i < GEOHASH_BASE32.length; i++) DECODE_MAP[GEOHASH_BASE32[i]] = i;

function charValue(c: string): number {
  const v = DECODE_MAP[c.toLowerCase()];
  if (v === undefined) throw new RangeError(`invalid geohash character: '${c}'`);
  return v; // O(1), and bad input fails loudly
}
```

**When NOT to apply:**
- For a one-off decode of a known-valid hash the difference is immaterial — but the table is trivial to build and turns silent corruption into a clear error, so prefer it wherever untrusted input is decoded.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [davetroy/geohash-js](https://github.com/davetroy/geohash-js)
