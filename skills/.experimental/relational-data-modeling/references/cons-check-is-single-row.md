---
title: Keep CHECK constraints single-row and immutable
tags: cons, check-constraint, cross-row-invariant, trigger
---

## Keep CHECK constraints single-row and immutable

A `CHECK` can only see the row being inserted or updated. PostgreSQL blocks the
obvious violation — `CHECK ((SELECT count(*) FROM enrollments ...) < 30)` fails
outright with *cannot use subquery in check constraint* — and the natural next
move is to wrap the query in a function, which PostgreSQL accepts. That version
is worse than the error, because it appears to work: it is evaluated only when
*this* row is written, so once other rows change the condition, the constraint
is false for rows already in the table and nothing re-checks them. The manual
states the rule plainly: a CHECK that references other rows "cannot guarantee
that the database will not reach a state in which the constraint condition is
false", and directs cross-row restrictions to `UNIQUE`, `EXCLUDE`, or
`FOREIGN KEY`.

The same assumption of immutability applies to any function in a `CHECK`.
`CHECK (expires_on > now())` is not a rule that expiry dates are in the future —
it is a rule that they were in the future at write time, and it silently becomes
untrue with the passage of time, which will also break `pg_dump` restores and
`VALIDATE CONSTRAINT`.

So `CHECK` is for predicates that are true of one row forever:

```sql
CREATE TABLE subscriptions (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  bigint NOT NULL REFERENCES customers,
    term         daterange NOT NULL,
    monthly_cents integer NOT NULL,
    seats        integer NOT NULL,
    CONSTRAINT subscription_price_non_negative CHECK (monthly_cents >= 0),
    CONSTRAINT subscription_seats_positive     CHECK (seats > 0),
    CONSTRAINT subscription_term_bounded       CHECK (NOT lower_inf(term) AND NOT isempty(term))
);
```

Match the invariant to the mechanism that can actually hold it:

| Invariant shape | Mechanism |
|---|---|
| A predicate over one row's own columns | `CHECK` |
| No two rows share a value | `UNIQUE`, or a partial unique index if scoped |
| No two rows collide under any operator | `EXCLUDE` |
| A value must exist in another table | `FOREIGN KEY` |
| An aggregate over child rows (capacity, balance) | A derived column maintained under a lock, or a trigger that takes one — see [`norm-derived-needs-a-mechanism`](norm-derived-needs-a-mechanism.md) |

That last row is the genuinely hard case, and it is hard because it is a
cross-row invariant: a trigger reading `count(*)` races exactly like the
application code it replaced unless it locks the parent row first.

Reference: [PostgreSQL 18 — Check Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS)
