---
title: Use SHA-256 over MD5 for High-Cardinality Keys
impact: CRITICAL
impactDescription: prevents silent key collisions on >100M keyspace
tags: key, hash, sha256, md5, collision
---

## Use SHA-256 over MD5 for High-Cardinality Keys

MD5's 128-bit output has ~1.8×10¹⁹ values, but the birthday bound makes a collision likely once you've inserted ~2³² (~4.3 billion) keys. A high-traffic marketplace with many cohorts × surfaces × filters can pass that threshold in a few months. Worse, MD5 is not collision-resistant against adversarial input — a request crafted to collide with another's key can return another user's recommendations or A/B treatment. SHA-256 has 256 bits, no known collisions, and the per-call cost on Node.js is ~1.2µs for sub-1KB inputs (negligible against any Redis RTT). Prefer SHA-256 by default; consider BLAKE3 if you need extreme throughput.

**Incorrect (MD5 on a high-cardinality keyspace):**

```typescript
import { createHash } from 'node:crypto';

function key(input: object): string {
  // 128 bits. Truncated to 16 hex chars for compactness — even worse.
  return `cache:${createHash('md5').update(JSON.stringify(input)).digest('hex').slice(0, 16)}`;
}
// 16 hex chars = 64 bits. Birthday collision likely at 2^32 = 4B entries.
// A high-traffic marketplace hits that in months — silent cross-user data leaks.
// MD5 itself is also broken against adversarial inputs.
```

**Correct (SHA-256, full digest or first 32 chars):**

```typescript
import { createHash } from 'node:crypto';

function key(input: object): string {
  // SHA-256 of canonicalised JSON. 256 bits full; first 32 hex chars = 128 bits
  // — well above any practical collision risk.
  return `cache:${createHash('sha256').update(JSON.stringify(input)).digest('hex').slice(0, 32)}`;
}

// Benchmark on a 2026-era cloud VM:
//   sha256 of 1KB input:  ~1.2 µs
//   md5 of 1KB input:     ~0.7 µs
//   redis GET round trip: ~1500 µs
// The hash cost is irrelevant.
```

**The "we'll never have that many keys" trap:**

```typescript
// Common misjudgement:
//   "We have 100k SKUs, 5 sort orders, 10 filters — only a few million combos."
// Reality after a year:
//   100k × 5 × 2^10 (filter combos) × 30 locales × 5 device classes
//   = 7.7 trillion possible keys. Working set is smaller, but cardinality of
//   ever-seen keys hits 10B+ easily on viral campaigns.
```

**For non-cryptographic uses where you need speed at extreme scale, BLAKE3 is faster than SHA-256 and equally collision-resistant.** But the default should be SHA-256 — it's available in the standard library of every runtime and is fast enough.

**Never use:**
- `String.prototype.hashCode()`-style algorithms — 32-bit, collisions guaranteed
- Truncated MD5 below 64 bits — adversarial collisions trivially constructable
- `JSON.stringify().length` or similar fake hashes — collisions across same-length strings

**The fingerprint pattern:** if you need to store the full key alongside the hash (for debugging or to disambiguate collisions), use `key_hash` (the 32-char SHA) plus `key_fingerprint` (a small array of derived attributes like locale, surface, q-prefix). The hash is the lookup; the fingerprint is the audit trail.

Reference: [RFC 6234 — SHA-256](https://www.rfc-editor.org/rfc/rfc6234) · [BLAKE3 spec](https://github.com/BLAKE3-team/BLAKE3-specs/blob/master/blake3.pdf) · [Birthday problem analysis for hash collisions](https://en.wikipedia.org/wiki/Birthday_problem)
