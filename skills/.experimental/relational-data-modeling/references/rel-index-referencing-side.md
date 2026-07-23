---
title: Index the referencing side of every foreign key yourself
tags: rel, foreign-key, index, locking
---

## Index the referencing side of every foreign key yourself

MySQL creates this index for you — InnoDB requires one and states that "such an
index is created on the referencing table automatically if it does not exist" —
and that habit transfers silently to PostgreSQL, which does not. The PostgreSQL
manual is explicit: "the declaration of a foreign key constraint does not
automatically create an index on the referencing columns." Only the *referenced*
side is indexed, because it has to be unique. The consequence is invisible until
someone deletes a parent row: PostgreSQL must prove no child references it, and
with no index that is a sequential scan of the child table, holding locks on it
for the duration. On a large child table, deleting one customer becomes a
minutes-long statement that blocks writers.

```sql
CREATE TABLE support_tickets (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  bigint NOT NULL REFERENCES customers,
    assignee_id  bigint REFERENCES users ON DELETE SET NULL,
    opened_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON support_tickets (customer_id);
CREATE INDEX ON support_tickets (assignee_id);
```

A composite index whose *leading* columns are the foreign key serves this
purpose too, which is why a child whose primary key already starts with the
parent's key — `order_lines (order_id, line_no)` — needs nothing extra. Check
the leading columns before adding an index; that is the common case where the
index already exists under another name.

The cost of getting this wrong scales with how the table is used, not how large
it is: a lookup table with a thousand rows and no deletes will never notice, and
an events table with a hundred million rows and a nightly purge will notice
immediately.

Reference: [PostgreSQL 18 — Constraints: Foreign Keys](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-FK), [MySQL 8.4 — FOREIGN KEY Constraints](https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html)
