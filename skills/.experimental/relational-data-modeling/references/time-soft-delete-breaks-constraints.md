---
title: Treat soft-delete flags as constraint-disabling, not free
tags: time, soft-delete, lifecycle, partial-index
---

## Treat soft-delete flags as constraint-disabling, not free

`deleted_at timestamptz` gets added to every table as a matter of course, on the
understanding that it is a harmless safety net. It is not harmless — it silently
disables the constraints on the table it is added to, in three ways at once.

**Unique constraints stop meaning what they said.** `UNIQUE (email)` now counts
deleted rows, so a user who deletes their account and returns cannot re-register.
Every unique constraint on the table has to become a partial index
(`UNIQUE (email) WHERE deleted_at IS NULL`), and the ones nobody remembers to
convert are now enforcing a rule the product does not have.

**Foreign keys keep resolving.** A "deleted" parent still satisfies every
reference to it, so children remain valid and reachable, and the database will
never tell you that an order points at a deleted customer. Cascade behaviour
disappears entirely, because nothing was deleted.

**Every query becomes conditionally correct.** The filter is invisible by
omission: a query missing `WHERE deleted_at IS NULL` returns extra rows rather
than an error, so the failure surfaces as deleted records appearing in a report,
an export, or someone else's tenant — a data leak, not a crash.

The usual fix is to ask what the flag actually means. Most soft deletes are not
deletion at all but a state the domain already has a name for:

```sql
CREATE TABLE customers (
    id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email     text NOT NULL,
    status    text NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'suspended', 'closed')),
    closed_at timestamptz,
    CHECK ((status = 'closed') = (closed_at IS NOT NULL))
);

-- The uniqueness rule the product actually has, stated explicitly.
CREATE UNIQUE INDEX customer_active_email
    ON customers (email) WHERE status <> 'closed';
```

Now the lifecycle is modelled, the constraint says what it means, and the state
is visible to every reader rather than assumed.

When rows genuinely are gone — retention expiry, a GDPR erasure — move them to an
archive table in the same transaction as the delete. The live table keeps its
constraints intact and its size bounded, and the archive can carry a different
shape, since it no longer needs to satisfy the live schema's references.

**When NOT to use this pattern:** an undo window of minutes or hours is a real
requirement, and a flag is a reasonable way to serve it. Scope it — one table,
with the partial indexes written at the same time and a job that hard-deletes
after the window — rather than adding `deleted_at` to every table by default.

Reference: [PostgreSQL 18 — Partial Indexes](https://www.postgresql.org/docs/18/indexes-partial.html), [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
