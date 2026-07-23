---
title: Use EXCLUDE constraints for non-overlap instead of application checks
tags: cons, exclusion-constraint, range-type, concurrency
---

## Use EXCLUDE constraints for non-overlap instead of application checks

"No two reservations for the same room may overlap" is almost always implemented
as a `SELECT` for conflicts followed by an `INSERT`. That is a read-then-write
race: two transactions both run the `SELECT`, both find nothing, and both
insert. Neither did anything wrong, and `READ COMMITTED` will not save you —
there is no row to conflict on, because the conflicting row does not exist yet
when either transaction looks. Serializable isolation catches it at the cost of
retry loops on every booking. An exclusion constraint is the direct expression:
it is backed by an index — GiST here — so the conflict is detected at write time
under any isolation level, by the same mechanism that makes `UNIQUE` reliable.

An `EXCLUDE` is `UNIQUE` generalised from equality to any operator — here `&&`,
"ranges overlap", combined with `=` on the room.

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE room_reservations (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id  bigint NOT NULL REFERENCES rooms,
    guest_id bigint NOT NULL REFERENCES guests,
    stay     tstzrange NOT NULL,
    EXCLUDE USING gist (room_id WITH =, stay WITH &&)
);
```

The `btree_gist` extension is what allows the plain-equality column `room_id`
into a GiST index; range columns work without it. A `WHERE` clause makes the
constraint partial, which is how you scope it to live rows —
`EXCLUDE USING gist (room_id WITH =, stay WITH &&) WHERE (status <> 'cancelled')`
lets cancelled reservations overlap freely.

Use the half-open range convention `[)` — `tstzrange(checkin, checkout, '[)')`
— so a stay ending at noon and one starting at noon do not overlap. Two
inclusive bounds make every back-to-back booking a conflict, which is the usual
first bug report after adopting this.

The same shape covers any "these must not collide" rule: staff shifts per
person, price schedules per product, seat assignments per showing, or
non-overlapping network allocations. That last one needs its operator class
named explicitly, because `&&` on `inet` is not in the default GiST family:

```sql
CREATE TABLE subnet_allocations (
    subnet_id bigint NOT NULL REFERENCES subnets,
    block     inet   NOT NULL,
    -- Without `inet_ops` this fails: operator &&(inet,inet) is not a member of
    -- operator family "gist_inet_ops".
    EXCLUDE USING gist (subnet_id WITH =, block inet_ops WITH &&)
);
```

Reference: [PostgreSQL 18 — Exclusion Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION), [PostgreSQL 18 — btree_gist](https://www.postgresql.org/docs/18/btree-gist.html)
