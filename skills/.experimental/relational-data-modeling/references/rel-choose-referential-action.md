---
title: Choose the referential action per relationship
tags: rel, foreign-key, on-delete, cascade
---

## Choose the referential action per relationship

`ON DELETE CASCADE` gets applied uniformly because it makes deletes work, and
omitting the clause entirely gets done because the default is silent. Both
decide the question by accident. The referential action is a statement about
whether the child *is part of* the parent or merely *refers to* it, and getting
it wrong in the cascade direction is unrecoverable: deleting a customer that
cascades into their invoices and ledger entries destroys the financial record
that the delete was never supposed to touch, in one statement, transactively.

- `CASCADE` — the child has no meaning without the parent. Order lines, document
  revisions, message attachments. Deleting the parent is deleting the whole
  thing.
- `RESTRICT` / `NO ACTION` — the child is an independent record that happens to
  cite the parent. Invoices, ledger entries, audit rows, anything a regulator or
  an accountant reads. The delete should fail and force the caller to decide.
- `SET NULL` — only when the reference is genuinely optional and the row still
  means something without it. An `assigned_to` on a ticket survives the assignee
  leaving; a `customer_id` on an order does not.

```sql
CREATE TABLE order_lines (
    order_id   bigint NOT NULL REFERENCES orders ON DELETE CASCADE,
    line_no    int    NOT NULL,
    product_id bigint NOT NULL REFERENCES products ON DELETE RESTRICT,
    quantity   int    NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, line_no)
);
```

Both actions in that one table are load-bearing. The line dies with its order,
because a line belongs to exactly one order and means nothing outside it. The
product does not die with the line, and `RESTRICT` is what turns "delete this
discontinued product" into an error the operator must resolve rather than a
silent hole in every historical order.

`RESTRICT` is strictly stronger than `NO ACTION`, not merely earlier. It cannot
be deferred to commit, and it rejects the action even when the end state would
satisfy the constraint — updating a `numeric` key from `1.0` to `1.00` succeeds
under `NO ACTION` (the values compare equal, so nothing is orphaned) and is
refused under `RESTRICT`. Prefer `NO ACTION` when a transaction legitimately
rewrites parent and children together; reach for `RESTRICT` when you want the
reference itself to be immovable.

Reference: [PostgreSQL 18 — Constraints: Foreign Keys](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-FK)
