---
title: Rule Title Here
tags: prefix, concept, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. Explain the *why* — the model generalizes from the reason, not the
instruction. If the schema a capable model would write without this rule is
already correct, the rule should not exist.

For this skill specifically, the wrong default is usually one of three shapes:
an ORM habit that discards referential integrity, an invariant left to
application code that a constraint could hold, or a decision made by reflex
whose cost only appears at migration or scale.

```sql
-- The canonical DDL. Domain-realistic names — never foo/bar, never `my_table`.
-- Run it against PostgreSQL 18 before committing, including the failure case:
--   docker run -d --name pg -e POSTGRES_PASSWORD=x postgres:18
--   docker exec -i pg psql -U postgres -f -
CREATE TABLE order_lines (
    order_id  bigint NOT NULL REFERENCES orders ON DELETE CASCADE,
    line_no   int    NOT NULL,
    quantity  int    NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, line_no)
);
```

Reference: [Source title](https://www.postgresql.org/docs/18/)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example.

     OPTIONAL SECTIONS (include only when they carry weight):
       **When NOT to use this pattern:** — real exceptions. Worth including
         often in this skill, since half its job is preventing over-engineering.
       **Alternative ({context}):** — a second valid approach

     Note the Postgres-only mechanisms explicitly (EXCLUDE, partial unique
     indexes, range types, WITHOUT OVERLAPS, DEFERRABLE, NOT VALID) so a reader
     on MySQL or SQLite knows the rule does not transfer as written. -->
