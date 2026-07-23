---
title: Choose between CHECK, a lookup table, and an enum type deliberately
tags: type, enum, lookup-table, check-constraint
---

## Choose between CHECK, a lookup table, and an enum type deliberately

`status text` with the permitted values living only in an application constant
is the common shape, and it means a typo — `'canceled'` where the rest of the
system writes `'cancelled'` — produces a row the database is perfectly happy
with and no query will ever find again. All three real options fix that; they
differ in what changing the value set costs, and picking by habit is how a
schema ends up with an enum it cannot modify.

**`CHECK` with a literal list** — for a small, closed set that changes only when
the code changes. Adding a value is `NOT VALID` plus `VALIDATE`, no rewrite, no
lock of consequence. This is the right default.

```sql
CREATE TABLE orders (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status  text NOT NULL DEFAULT 'pending'
        CONSTRAINT order_status_known
        CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled'))
);
```

**A lookup table with a foreign key** — when the values carry attributes of
their own (a display label, a sort position, a translation, a flag for "counts
as terminal"), or when operators need to add one without a deploy. The values
become data, joinable and constrainable, and the foreign key does the
validation.

```sql
CREATE TABLE ticket_priorities (
    code           text PRIMARY KEY,
    label          text NOT NULL,
    response_hours int  NOT NULL,   -- an attribute a CHECK list cannot carry
    sort_order     int  NOT NULL
);

CREATE TABLE support_tickets (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    priority text NOT NULL REFERENCES ticket_priorities (code)
);
```

**A PostgreSQL `enum` type** — when the set is genuinely fixed and you want
declared sort order and compact storage. Know the asymmetry before choosing it:
adding a value is easy, and a value added inside a transaction block cannot be
used until that transaction commits; renaming is supported via
`ALTER TYPE ... RENAME VALUE`; but **there is no way to remove a value**. The
only route is creating a replacement type and rewriting every column that uses
it. An enum for a set you expect to prune is a one-way door.

The decision in one line: does the value need attributes, or will non-developers
change it? Lookup table. Otherwise `CHECK`, and reach for `enum` only when the
declared ordering or the storage actually earns the migration cost.

Reference: [PostgreSQL 18 — ALTER TYPE](https://www.postgresql.org/docs/18/sql-altertype.html), [PostgreSQL 18 — Enumerated Types](https://www.postgresql.org/docs/18/datatype-enum.html)
