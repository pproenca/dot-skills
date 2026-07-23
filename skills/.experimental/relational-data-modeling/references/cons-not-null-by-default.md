---
title: Know where NULL silently defeats a constraint
tags: cons, null, three-valued-logic, check-constraint
---

## Know where NULL silently defeats a constraint

Declaring `NOT NULL` on the obvious columns is not the gap — the gap is that a
nullable column quietly disables the constraints you wrote next to it, in ways
that surface as accepted bad data rather than as an error. Under three-valued
logic a constraint is violated only when it evaluates to **false**, so a
constraint that evaluates to NULL *passes*:

```sql
CREATE TABLE promotions (discount_percent int CHECK (discount_percent <= 100));
INSERT INTO promotions VALUES (NULL);   -- accepted; the CHECK returned NULL
```

The same asymmetry runs through the rest of the toolkit. `UNIQUE` permits
unlimited NULLs, because two unknowns are not considered equal — so
`UNIQUE (customer_id, external_ref)` stops constraining the moment `external_ref`
is absent. And `NOT IN` against a set containing a NULL returns no rows at all
rather than the rows you expected, which is why the PostgreSQL wiki recommends
`NOT EXISTS` instead.

So the rule is not "add `NOT NULL`" — it is that every nullable column obliges
you to write the constraint so NULL cannot short-circuit it, and to answer what
absence means there. Often the honest answer is a different model: a missing
shipping address is a missing row in `addresses`, not four NULLs on `orders`.

```sql
CREATE TABLE invoices (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customers,
    issued_at   timestamptz NOT NULL,
    total       numeric(12,2) NOT NULL CHECK (total >= 0),
    -- Nullable and meaningful: NULL is "not yet paid", a state the domain has.
    paid_at     timestamptz,
    -- The IS NULL arm is what keeps the NULL case from passing by accident
    -- rather than by decision. Both sides are timestamptz, so the comparison
    -- is immutable — see cons-check-is-single-row.
    CONSTRAINT invoice_paid_after_issue
        CHECK (paid_at IS NULL OR paid_at >= issued_at)
);
```

Where NULL genuinely should collide for uniqueness purposes, PostgreSQL 15 and
later can be told so explicitly:
`UNIQUE NULLS NOT DISTINCT (customer_id, external_ref)` rejects a second row
with the same customer and an absent reference, which the default
`NULLS DISTINCT` accepts.

Reference: [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html), [PostgreSQL Wiki — Don't Do This: NOT IN](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_NOT_IN)
