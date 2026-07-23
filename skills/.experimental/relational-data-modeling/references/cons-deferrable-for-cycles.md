---
title: Use deferrable constraints for genuine cycles instead of nullable columns
tags: cons, deferrable, circular-reference, not-null
---

## Use deferrable constraints for genuine cycles instead of nullable columns

Two tables that reference each other — a department has a manager who is an
employee, an employee belongs to a department — create a chicken-and-egg on
insert, and the reflex fix is to make one side nullable. That solves a
transient problem permanently: the column is now nullable in every row for the
rest of the schema's life, and no constraint can distinguish "we are mid-insert"
from "this department has lost its manager and nobody noticed". Every query and
every report then has to handle a NULL that should be impossible in any
committed state.

Deferring the check is the accurate statement. `DEFERRABLE INITIALLY DEFERRED`
moves enforcement to `COMMIT`, so the constraint is allowed to be false in the
middle of a transaction but must be true of every state anyone can observe.

```sql
CREATE TABLE departments (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text   NOT NULL,
    manager_id  bigint NOT NULL
);

CREATE TABLE employees (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     text   NOT NULL,
    department_id bigint NOT NULL REFERENCES departments
);

ALTER TABLE departments
    ADD CONSTRAINT department_manager_fk
    FOREIGN KEY (manager_id) REFERENCES employees
    DEFERRABLE INITIALLY DEFERRED;

-- Both rows land in one transaction; the cycle is closed before anyone sees it.
BEGIN;
  INSERT INTO departments (id, name, manager_id)
    OVERRIDING SYSTEM VALUE VALUES (1, 'Platform', 100);
  INSERT INTO employees (id, full_name, department_id)
    OVERRIDING SYSTEM VALUE VALUES (100, 'Ada Okonkwo', 1);
COMMIT;
```

Only `UNIQUE`, `PRIMARY KEY`, `EXCLUDE` and `FOREIGN KEY` can be deferred —
`NOT NULL` and `CHECK` cannot, which is why the cycle has to be broken at the
foreign key. Note also that a deferrable unique constraint cannot serve as the
conflict arbiter in `INSERT ... ON CONFLICT`, so do not make constraints
deferrable by default; do it where a cycle or a bulk reorder actually needs it.

**When NOT to use this pattern:** a nullable column is right when absence is a
real domain state — a ticket with no assignee, a subscription with no end date.
The test is whether a committed row with NULL there means something. If the
answer is "that shouldn't happen", the column is not nullable, the constraint is
deferred.

Reference: [PostgreSQL 18 — CREATE TABLE: DEFERRABLE](https://www.postgresql.org/docs/18/sql-createtable.html), [PostgreSQL 18 — SET CONSTRAINTS](https://www.postgresql.org/docs/18/sql-set-constraints.html)
