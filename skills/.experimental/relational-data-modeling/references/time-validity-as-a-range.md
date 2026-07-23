---
title: Model validity as a range and let the database enforce it
tags: time, temporal-key, without-overlaps, effective-dating
---

## Model validity as a range and let the database enforce it

A table with one current row per entity and an `updated_at` answers "what is the
price now" and nothing else. The moment someone asks what the price was on 1
March — to reprice a returned order, to explain an invoice, to reproduce last
quarter's report — the answer is not in the database. The usual retrofit is a
`_history` shadow table written by a trigger, which makes history *available*
but not *correct*: nothing in it prevents two rows claiming to be in effect at
the same instant, so "the price on 1 March" can legitimately return two answers.

Model the period as part of the key instead. PostgreSQL 18 added temporal keys:
`WITHOUT OVERLAPS` on the final column makes it checked for overlap rather than
equality, so two versions of the same product that overlap in time cannot be
committed.

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE product_prices (
    product_id    bigint    NOT NULL REFERENCES products,
    valid_period  daterange NOT NULL,
    unit_amount   bigint    NOT NULL CHECK (unit_amount >= 0),
    PRIMARY KEY (product_id, valid_period WITHOUT OVERLAPS)
);
```

Adjacent periods under the `[)` convention are fine — a price ending 1 April and
the next beginning 1 April do not overlap — while a genuine overlap is rejected
by the primary key. The question that had no answer now has exactly one:

```sql
SELECT unit_amount FROM product_prices
 WHERE product_id = 91 AND valid_period @> DATE '2026-03-01';
```

The matching foreign key form is `PERIOD`, and its semantics are stronger than
they first appear: the child's entire period must be *covered* by the parent, and
the coverage may come from the union of several adjacent parent rows.

```sql
CREATE TABLE price_promotions (
    product_id    bigint    NOT NULL,
    valid_period  daterange NOT NULL,
    discount_bps  int       NOT NULL CHECK (discount_bps BETWEEN 1 AND 10000),
    PRIMARY KEY (product_id, valid_period WITHOUT OVERLAPS),
    FOREIGN KEY (product_id, PERIOD valid_period)
        REFERENCES product_prices (product_id, PERIOD valid_period)
);
```

A promotion cannot exist for a stretch of time in which the product had no
price — an invariant that otherwise lives in a nightly consistency check, if it
is checked at all.

Three constraints on the feature. The range column must be a range or multirange
type and cannot be empty, and `btree_gist` is required for the equality columns
alongside it. The key needs at least two columns — `PRIMARY KEY (valid_period
WITHOUT OVERLAPS)` on its own is rejected with *constraint using WITHOUT OVERLAPS
needs at least two columns*, since a lone non-overlapping range would permit only
one row. And temporal foreign keys support only `NO ACTION` — `CASCADE`,
`RESTRICT`, `SET NULL` and `SET DEFAULT` are all rejected at creation time, so
parent deletions have to be handled explicitly.

On PostgreSQL 17 and earlier, the same shape is available without the temporal
key by using an exclusion constraint —
`EXCLUDE USING gist (product_id WITH =, valid_period WITH &&)` — which gives you
the non-overlap guarantee but not the `PERIOD` coverage check.

Reference: [PostgreSQL 18 — CREATE TABLE](https://www.postgresql.org/docs/18/sql-createtable.html), [PostgreSQL 18 Release Notes](https://www.postgresql.org/docs/release/18.0/)
