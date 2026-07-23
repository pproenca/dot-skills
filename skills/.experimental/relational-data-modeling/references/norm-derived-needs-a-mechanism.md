---
title: Give every derived value an enforcement mechanism
tags: norm, generated-column, materialized-view, denormalization
---

## Give every derived value an enforcement mechanism

Denormalizing for a read path is a legitimate decision; "the application keeps it
in sync" is not a mechanism. No constraint in a relational database can hold two
copies of a value equal — `UNIQUE`, `CHECK` and `FOREIGN KEY` all constrain a row
against a value or against another table, and none of them can say "this column
must match that column in another row". So application-maintained copies drift,
and they drift undetectably rather than loudly: a retried request that increments
a counter twice, a code path added later that writes the base table but not the
cache, a backfill script, a manual fix in a psql session. Nothing raises an
alarm; the numbers are just quietly wrong.

The test before adding any derived column: **name the mechanism that keeps this
copy equal to its source.** If you can name one, the copy is safe. If the answer
is "the application updates both", you are not denormalizing — you are adding a
bug with a delay on it. Pick the cheapest mechanism that covers the shape.

**Same row → a generated column.** The value is recomputed by the database on
every write; drift is not possible because the column cannot be written to.

```sql
CREATE TABLE order_lines (
    order_id     bigint NOT NULL REFERENCES orders ON DELETE CASCADE,
    line_no      int    NOT NULL,
    unit_amount  bigint NOT NULL CHECK (unit_amount >= 0),
    quantity     int    NOT NULL CHECK (quantity > 0),
    line_total   bigint GENERATED ALWAYS AS (unit_amount * quantity) STORED,
    PRIMARY KEY (order_id, line_no)
);
```

`STORED` materializes the value at write time; `VIRTUAL` — the default in
PostgreSQL 18 — recomputes it on read and costs no storage. Choose `STORED` when
the value is read far more often than written, or when it must back an index or
constraint, since a virtual column cannot carry a primary key or unique index.
The generation expression must be immutable and confined to the current row: it
cannot call `now()`, cannot reference another table, and cannot reference another
generated column.

**Across rows → a materialized view.** Aggregates over children (order totals,
account balances, per-tenant usage) exceed what a generated column can express.
A materialized view is a real, refreshable snapshot with an explicit staleness
window, which is an honest trade rather than a hidden one.

```sql
CREATE MATERIALIZED VIEW order_totals AS
    SELECT order_id, sum(line_total) AS total_amount, count(*) AS line_count
      FROM order_lines GROUP BY order_id;

CREATE UNIQUE INDEX ON order_totals (order_id);   -- required for CONCURRENTLY
REFRESH MATERIALIZED VIEW CONCURRENTLY order_totals;
```

The unique index is not optional if you want `CONCURRENTLY`, which is what lets
the refresh run without blocking readers.

**Needs to be transactionally exact → a trigger, with a lock.** Only when
staleness is unacceptable — an inventory count that gates a sale, a balance that
must never permit an overdraft. Understand what you are taking on: a trigger that
reads `sum(...)` over sibling rows races exactly like the application code it
replaced unless it first locks the parent row (`SELECT ... FOR UPDATE`), and that
lock serialises every concurrent write to that parent. That serialisation is the
actual cost of an exact cross-row invariant, and it is why the first two options
are worth exhausting.

**One case looks like a derived value and is not.** The unit price on an invoice
line is not a cache of the product's current price — it is the price that was
agreed, and it must stay fixed when the catalogue changes. Giving it a
"synchronisation mechanism" would be the bug. The giveaway is that refreshing the
value would be *wrong* rather than merely unnecessary, and historical documents
are full of these: the shipping address on a dispatched order, the tax rate
applied, the plan terms at signup. Those are independent facts with one home
each, so they need no mechanism — only a comment saying they are deliberately
frozen, because the next reader will assume they are a stale copy.

Reference: [PostgreSQL 18 — Generated Columns](https://www.postgresql.org/docs/18/ddl-generated-columns.html), [PostgreSQL 18 — REFRESH MATERIALIZED VIEW](https://www.postgresql.org/docs/18/sql-refreshmaterializedview.html)
