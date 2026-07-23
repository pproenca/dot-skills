---
title: Treat the partition axis as a key decision, not a later tuning knob
tags: key, partitioning, unique-constraint, schema-evolution
---

## Treat the partition axis as a key decision, not a later tuning knob

Partitioning gets filed under performance work to do later, which would be fine
if it did not reach back and change the primary key. PostgreSQL requires that a
unique or primary key constraint on a partitioned table include every partition
key column, because each partition's index can only enforce uniqueness within
itself — the partition structure has to guarantee the rest. So the day a large
events table is partitioned by time, its key stops being `(id)` and becomes
`(occurred_at, id)`, and every foreign key pointing at it grows a column too.
Doing that under load, on the table that got big enough to need partitioning, is
the expensive version.

This is not an argument for partitioning early, and still less for widening
every key against a need that will never arrive. It applies to the specific
tables whose growth is structural rather than incidental — append-only event and
audit logs, time-series measurements, per-tenant activity — where the axis is
almost always time or tenant, and is a column you wanted in the key anyway.

```sql
CREATE TABLE audit_events (
    occurred_at  timestamptz NOT NULL,
    id           bigint GENERATED ALWAYS AS IDENTITY,
    actor_id     bigint NOT NULL REFERENCES users,
    action       text   NOT NULL,
    payload      jsonb  NOT NULL,
    PRIMARY KEY (occurred_at, id)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE audit_events_2026q3 PARTITION OF audit_events
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');
```

Partition by the raw column and let the range bounds do the bucketing. Reaching
for `PARTITION BY RANGE (date_trunc('month', occurred_at))` fails twice over:
against a `timestamptz` it is rejected immediately, because `date_trunc` is only
STABLE there and *functions in partition key expression must be marked
IMMUTABLE*; and even over a plain `timestamp`, where the expression is
immutable and the table does create, adding the primary key then fails with
*PRIMARY KEY constraints cannot be used when partition keys include
expressions*. An expression partition key forecloses the primary key entirely.

**When NOT to use this pattern:** for a table with a bounded row count — most
reference and configuration tables, and the great majority of entity tables —
this decision never arrives, and the propagated column is pure cost. The
question is not "could this be partitioned" but "will this table's size be
driven by traffic rather than by the business".

Reference: [PostgreSQL 18 — Table Partitioning](https://www.postgresql.org/docs/18/ddl-partitioning.html)
