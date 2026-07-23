---
title: Use JSONB for genuinely open shapes, not as a schema escape hatch
tags: norm, jsonb, eav, schemaless
---

## Use JSONB for genuinely open shapes, not as a schema escape hatch

A `metadata jsonb` or `settings jsonb` column gets added because the attribute
set feels like it might change, and it then absorbs fields that are perfectly
well known — `preferred_language`, `plan_tier`, `referred_by_user_id`. Inside
JSONB none of the relational machinery reaches them: no foreign key, so
`referred_by_user_id` can name a user who never existed; no `NOT NULL` and no
type, so a value arrives as `"3"` in some rows and `3` in others and both are
valid JSON; no column-level grants; and no per-key statistics, so the planner
estimates selectivity for a filter on one key from whole-column statistics and
picks bad plans on any query that reaches through the blob. The escape hatch trades away every guarantee the database
exists to provide, in exchange for skipping a migration that
[`cons-not-valid-then-validate`](cons-not-valid-then-validate.md) makes cheap.

The test is concrete: **can you enumerate the keys?** If yes, and any of them is
ever filtered on, joined on, or required, they are columns. JSONB earns its place
when the shape is genuinely not yours to know:

```sql
-- Legitimate: an inbound webhook, stored verbatim for replay and audit. The
-- fields this system relies on are lifted into real columns beside it.
CREATE TABLE processor_events (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    processor     text        NOT NULL,
    event_type    text        NOT NULL,
    received_at   timestamptz NOT NULL DEFAULT now(),
    external_id   text        NOT NULL,
    payload       jsonb       NOT NULL,
    UNIQUE (processor, external_id)
);

-- Legitimate: per-tenant custom fields, where the key set differs by tenant and
-- is defined by the tenant. A GIN index makes containment queries indexable.
CREATE INDEX ON customer_custom_fields USING gin (values jsonb_path_ops);
```

The other legitimate cases are sparse attribute sets where most keys are absent
for most rows, and configuration documents read whole and never queried by part.

Entity-attribute-value — a table of `(entity_id, attribute_name, value)` rows —
is the same decision made worse. It loses everything JSONB loses and adds a join
per attribute plus a `text` column holding every type at once. If you find
yourself designing one, the requirement behind it is usually per-tenant custom
fields, which is the JSONB case above, or a subtype, which is
[`rel-subtypes-through-the-key`](rel-subtypes-through-the-key.md).

When a JSONB key does stabilise into something the system depends on, promote it
to a column — a stored generated column extracting it (`(payload->>'currency')`)
gives you a real, indexable, constrainable column without rewriting the writers.

Reference: [PostgreSQL 18 — JSON Types](https://www.postgresql.org/docs/18/datatype-json.html), [Karwin, *SQL Antipatterns*: "Entity-Attribute-Value"](https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/)
