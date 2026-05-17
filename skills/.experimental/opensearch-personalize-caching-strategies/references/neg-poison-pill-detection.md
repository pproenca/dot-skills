---
title: Checksum Cache Entries to Detect and Reject Poisoned Writes
impact: MEDIUM-HIGH
impactDescription: prevents one bad write from corrupting hours of traffic
tags: neg, integrity, checksum, schema-version, validation
---

## Checksum Cache Entries to Detect and Reject Poisoned Writes

A bug that writes a corrupted value to a hot cache key propagates to every reader for the TTL duration. Symptoms vary: type errors at the consumer, missing fields, wrong-schema data after a deploy that changed the cache value structure. Without entry-level validation, you discover the problem from downstream errors and have to figure out which cache to invalidate. With a stored checksum and schema-version tag, readers detect the bad write at read time, evict the entry, fall through to a fresh origin read, and self-heal. Trades 50 bytes per entry for fast detection.

**Incorrect (cache is a trust-the-bytes blob):**

```typescript
async function getListing(id: string) {
  const cached = await redis.get(`listing:${id}`);
  if (cached) return JSON.parse(cached);
  const fresh = await db.getListing(id);
  await redis.set(`listing:${id}`, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}

// Scenario: a recent deploy changed Listing schema. The new code writes the new shape;
// the OLD running pods read entries written by new code and crash on missing fields.
// Or: a transient encoding bug truncated a JSON write. All readers parse garbage.
// Or: someone manually SET'd a wrong value to "test" something in prod.
// Detection: downstream errors, hours of debugging.
```

**Correct (envelope with schema version + checksum):**

```typescript
import { createHash } from 'node:crypto';

const CURRENT_SCHEMA = 'listing.v3';

type Envelope<T> = {
  schema: string;
  payload: T;
  checksum: string;  // crc32 or short sha256 of canonical-JSON payload
  cachedAt: number;
};

function buildEnvelope<T>(schema: string, payload: T): Envelope<T> {
  const canonicalJson = JSON.stringify(payload, Object.keys(payload as object).sort());
  const checksum = createHash('sha256').update(canonicalJson).digest('hex').slice(0, 16);
  return { schema, payload, checksum, cachedAt: Date.now() };
}

function validateEnvelope<T>(env: Envelope<T>, expectedSchema: string): T | null {
  if (env.schema !== expectedSchema) {
    metrics.increment('cache.poison.schema_mismatch', { expected: expectedSchema, got: env.schema });
    return null;
  }
  const canonicalJson = JSON.stringify(env.payload, Object.keys(env.payload as object).sort());
  const expected = createHash('sha256').update(canonicalJson).digest('hex').slice(0, 16);
  if (expected !== env.checksum) {
    metrics.increment('cache.poison.checksum_mismatch', { schema: env.schema });
    return null;
  }
  return env.payload;
}

async function getListing(id: string): Promise<Listing> {
  const raw = await redis.get(`listing:${id}`);
  if (raw) {
    try {
      const env = JSON.parse(raw) as Envelope<Listing>;
      const validated = validateEnvelope(env, CURRENT_SCHEMA);
      if (validated) return validated;
      // Invalid entry — evict and fall through
      await redis.del(`listing:${id}`);
      log.warn('poisoned cache entry evicted', { key: `listing:${id}` });
    } catch (err) {
      // Unparseable — evict
      await redis.del(`listing:${id}`);
      log.warn('unparseable cache entry evicted', { key: `listing:${id}`, err });
    }
  }

  const fresh = await db.getListing(id);
  const env = buildEnvelope(CURRENT_SCHEMA, fresh);
  await redis.set(`listing:${id}`, JSON.stringify(env), 'EX', 600);
  return fresh;
}
```

**Schema versioning handles the deploy case automatically.** Bump `CURRENT_SCHEMA` from `v3` to `v4` when the payload shape changes; old entries with `v3` are rejected by the new code and self-heal on the next read. Old code reading new entries also rejects them and falls back to origin — degraded performance during deploy, but correctness preserved.

**Checksum size trade-off:**
- 4-byte CRC32: ~1 in 4 billion collision; suitable for accident detection, not adversarial
- 8-byte truncated SHA-256: ~1 in 1.8×10¹⁹; effectively never collides
- Full SHA-256 (32 bytes): overkill for cache integrity; the truncation is fine

**Alert on poisoning.** If `cache.poison.checksum_mismatch` is more than a handful per day, something is actually corrupting writes — investigate. If `cache.poison.schema_mismatch` spikes during a deploy, it's the expected transient; should drop to ~0 within a few minutes as old entries TTL out.

**Don't checksum tiny entries.** A 32-byte payload with an 8-byte checksum and 30 bytes of envelope metadata is 70 bytes vs 32 — significant overhead. For small entries, schema-version-only validation is enough.

**Cross-runtime canonicalisation:** if your producers are written in Python and consumers in TypeScript, ensure both produce the same canonical JSON (sorted keys, no trailing commas, exact float formatting). The `canonical-json` package in many languages handles this. Without it, the checksum is incorrect across languages even when the payload is logically the same.

Reference: [Apache Avro schema evolution](https://avro.apache.org/docs/current/spec.html#Schema+Resolution) · [Protobuf wire format and schema version](https://protobuf.dev/programming-guides/proto3/) · [Canonical JSON spec](https://datatracker.ietf.org/doc/html/draft-staykov-hu-json-canonical-form-00)
