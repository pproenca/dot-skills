---
title: Use a partial unique index for at most one active row
tags: cons, partial-index, unique-constraint, invariant
---

## Use a partial unique index for at most one active row

"Each customer has one default address" turns into an `is_default boolean` plus
application code that clears the old default before setting the new one, or a
trigger doing the same. Both are read-then-write sequences, so two concurrent
requests can each clear the other's flag and leave a customer with two defaults
or none — and once the data is wrong, nothing detects it, because there is no
constraint to violate. A unique index with a `WHERE` clause enforces uniqueness
only across the rows that satisfy the predicate, which is exactly the statement
"at most one default per customer" and nothing more.

```sql
CREATE TABLE customer_addresses (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customers,
    line1       text   NOT NULL,
    postal_code text   NOT NULL,
    is_default  boolean NOT NULL DEFAULT false
);

CREATE UNIQUE INDEX customer_one_default_address
    ON customer_addresses (customer_id)
    WHERE is_default;
```

Swapping the default now needs both writes in one transaction, which is correct
— the intermediate state where a customer has two defaults never becomes
visible, and a partial swap can no longer be committed.

The predicate can be any immutable expression, which makes this the general tool
for scoped uniqueness: one open subscription per customer
(`WHERE ended_at IS NULL`), one primary contact per account, one in-flight job
per queue key. It is also the fix for a unique constraint broken by soft deletes
— `UNIQUE (email) WHERE deleted_at IS NULL` restores the constraint that
`deleted_at` disabled, though see
[`time-soft-delete-breaks-constraints`](time-soft-delete-breaks-constraints.md)
for why that is treating a symptom.

Two limits. A partial index cannot back a foreign key — a reference target needs
a full unique constraint. And `ON CONFLICT` must repeat the predicate to infer a
partial index: `ON CONFLICT (customer_id) WHERE is_default` works, while
`ON CONFLICT (customer_id)` alone fails with *there is no unique or exclusion
constraint matching the ON CONFLICT specification*.

Reference: [PostgreSQL 18 — Partial Indexes, Example 11.3](https://www.postgresql.org/docs/18/indexes-partial.html)
