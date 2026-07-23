---
title: Use uuidv7 when keys must be client-generated
tags: key, uuid, index-locality, btree
---

## Use uuidv7 when keys must be client-generated

`gen_random_uuid()` is the default that comes to hand, and it produces version 4
UUIDs — uniformly random. Every insert therefore lands on a random leaf of the
primary key's B-tree, so the index pages you need to write are scattered across
the whole index rather than concentrated at its right-hand edge. Once the index
exceeds memory, insert throughput collapses to a disk read per row, and the
table gains no physical correlation with insertion order, which removes the
cheap "recent rows are adjacent" range scan that a sequential key gives you for
free. Version 7 UUIDs put a millisecond timestamp in the high bits, so they sort
by creation time while staying globally unique and unguessable-enough for
external exposure. PostgreSQL 18 ships `uuidv7()` in core — no extension.

```sql
CREATE TABLE upload_sessions (
    id           uuid PRIMARY KEY DEFAULT uuidv7(),
    tenant_id    bigint NOT NULL REFERENCES tenants,
    started_at   timestamptz NOT NULL DEFAULT now()
);
```

**When NOT to use this pattern:** a UUID is 16 bytes against 8 for `bigint`, and
that cost is paid again in every foreign key and every index that carries it.
Reach for a UUID only when you actually need the property it buys — the key is
minted by a client or a peer database before the row reaches this server, or the
key appears in a URL and a guessable sequential id would leak volume. A single
database assigning its own keys should use identity.

If the id is externally visible and *ordering* is the leak you care about, note
that v7 exposes the creation timestamp by design; use a separate opaque public
identifier in that case rather than reverting to v4 for the primary key.

Reference: [PostgreSQL 18 — UUID Functions](https://www.postgresql.org/docs/18/functions-uuid.html), [PostgreSQL 18 Release Notes](https://www.postgresql.org/docs/release/18.0/)
