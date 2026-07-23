---
title: Keep a one-to-one relationship in one table
tags: rel, one-to-one, table-split, normalization
---

## Keep a one-to-one relationship in one table

Splitting `users` into `users` plus `user_profiles` feels like organisation, and
it is the most common piece of structure added for no reason. It costs a join on
every read that needs a name or an avatar — which is most of them — and it does
not actually enforce the one-to-one it claims: making the child's foreign key
`UNIQUE NOT NULL` gives you at most one child per parent, but nothing requires a
parent to have one. Enforcing both directions needs a foreign key from parent to
child as well, which is circular and therefore has to be deferrable. Almost
nobody does this, so the "one-to-one" is really zero-or-one with a join.

A split earns its place when the two halves differ in a way the storage or the
security model cares about:

- **Write frequency.** A counter updated on every page view does not belong in
  the same row as immutable profile data, because each update writes a whole new
  row version and churns every index on that table.
- **Access control.** Column-level grants exist, but a separate table with its
  own grants is far easier to audit for something like national ID numbers.
- **Row width.** A row that would otherwise carry a large text or bytea column
  the common queries never select — though PostgreSQL's TOAST already moves
  oversized values out of line, so measure before splitting for this reason.
- **A genuine optional subtype**, where the columns exist only for some rows —
  which is [`rel-subtypes-through-the-key`](rel-subtypes-through-the-key.md),
  not a one-to-one.

```sql
-- Same entity, one table. Nullable columns here are honest: a user may not have
-- supplied a display name.
CREATE TABLE users (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         text   NOT NULL UNIQUE,
    display_name  text,
    avatar_url    text,
    created_at    timestamptz NOT NULL DEFAULT now()
);

-- A split that earns it: written on every request, read almost never.
CREATE TABLE user_activity (
    user_id        bigint PRIMARY KEY REFERENCES users ON DELETE CASCADE,
    last_seen_at   timestamptz NOT NULL,
    session_count  bigint NOT NULL DEFAULT 0
);
```

Note the child's primary key *is* the foreign key. That is what makes it at most
one, without a separate surrogate id and a `UNIQUE` constraint doing the same
job twice.

Reference: [Fowler, *PoEAA*: Embedded Value](https://martinfowler.com/eaaCatalog/embeddedValue.html), [PostgreSQL 18 — TOAST](https://www.postgresql.org/docs/18/storage-toast.html)
