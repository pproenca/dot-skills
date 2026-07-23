---
title: Give a table the key its rows actually have
tags: key, primary-key, surrogate-key, unique-constraint
---

## Give a table the key its rows actually have

The reflex is to stamp `id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY` on
every table and move on. On a table whose identity is a combination of foreign
keys — a membership, an enrollment, a permission grant — that reflex silently
removes the only statement of what makes a row unique, and the duplicate now
inserts cleanly. A surrogate key does not *replace* the natural key; it hides it,
so you must then declare the natural key separately as `UNIQUE`, which is the
step that gets forgotten. Add a surrogate when the natural key is wide, mutable,
or externally supplied; on a pure association table the composite key is both
the correct declaration and a free covering index.

```sql
-- The relationship IS the identity: a user holds a role in a project once.
CREATE TABLE project_memberships (
    project_id  bigint NOT NULL REFERENCES projects,
    user_id     bigint NOT NULL REFERENCES users,
    granted_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (project_id, user_id)
);

-- Surrogate earns its place: the natural key (issuer + external reference) is
-- wide, supplied by a third party, and cited by six other tables. Declaring it
-- UNIQUE is what keeps the surrogate honest.
CREATE TABLE payment_methods (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id    bigint NOT NULL REFERENCES customers,
    processor      text   NOT NULL,
    processor_ref  text   NOT NULL,
    UNIQUE (processor, processor_ref)
);
```

A surrogate primary key with no `UNIQUE` on the real identity is the single most
common way a schema loses the ability to reject a duplicate. When you add one,
say out loud what makes two rows the same row — that sentence is the `UNIQUE`
constraint you owe the table.

Reference: [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html), [Karwin, *SQL Antipatterns*: "ID Required"](https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/)
