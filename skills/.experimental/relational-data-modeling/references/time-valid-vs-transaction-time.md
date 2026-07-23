---
title: Separate valid time from transaction time only when you must reproduce a past belief
tags: time, bitemporal, audit, correction
---

## Separate valid time from transaction time only when you must reproduce a past belief

One time axis cannot distinguish two different events: a salary that *changed*
in March, and a salary that was *always* what it is now but was recorded wrongly
until March. Both appear in a singly-temporal table as a row with a March
boundary, so a report re-run for February silently disagrees with the one filed
in February — with no way to tell whether the world changed or the data was
fixed. For payroll, billing, insurance and anything a regulator reads, "what did
we believe on the day we filed" is a question that must have an answer, and a
correction must not rewrite it.

Two ranges answer it. **Valid time** is when the fact was true in the world;
**transaction time** is when this database believed it. Rows are never updated —
a correction closes the current row's transaction period and inserts a
replacement — so every past state remains reconstructible.

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE employee_salaries (
    employee_id   bigint    NOT NULL REFERENCES employees,
    -- When this salary applied in the world.
    valid_period  daterange NOT NULL,
    -- When we believed it. Upper bound NULL/infinite = still believed.
    recorded_period tstzrange NOT NULL,
    annual_amount bigint    NOT NULL CHECK (annual_amount > 0),
    -- Uniqueness holds within a single belief window: only one salary is on
    -- record for a given date at a given time of asking.
    EXCLUDE USING gist (
        employee_id WITH =, valid_period WITH &&, recorded_period WITH &&
    )
);
```

A correction never updates the fact. It closes the superseded row's belief window
and inserts the replacement, in one transaction:

```sql
BEGIN;
  UPDATE employee_salaries
     SET recorded_period = tstzrange(lower(recorded_period), '2026-03-01Z')
   WHERE employee_id = 1 AND upper_inf(recorded_period);

  INSERT INTO employee_salaries
    VALUES (1, daterange('2026-01-01','2027-01-01'), tstzrange('2026-03-01Z', NULL), 65000);
COMMIT;
```

Both questions are then plain queries against the same rows — and they give
different answers, which is the entire point:

```sql
-- What we believe now about February  → 65000
SELECT annual_amount FROM employee_salaries
 WHERE employee_id = 1 AND valid_period @> DATE '2026-02-01'
   AND recorded_period @> now();

-- What we believed in February about February  → 60000
SELECT annual_amount FROM employee_salaries
 WHERE employee_id = 1 AND valid_period @> DATE '2026-02-01'
   AND recorded_period @> TIMESTAMPTZ '2026-02-01Z';
```

The February report re-runs to the figure that was filed, while today's report
reflects the correction. A singly-temporal table cannot produce both.

**When NOT to use this pattern:** this is the rule most likely to be
over-applied, and it doubles the width of every key, every index, and every
query predicate on the table. One axis is sufficient — use
[`time-validity-as-a-range`](time-validity-as-a-range.md) — unless you can name a
concrete obligation to reproduce a past belief: a filed report that must still
tie out, a regulator that audits point-in-time state, a dispute process where
"what did the system say then" is the question. Wanting an audit trail is not
that obligation; an append-only change log alongside a singly-temporal table is
cheaper and answers "who changed what" perfectly well.

Apply it to the few tables that carry the obligation, not to the schema.

Reference: [Snodgrass, *Developing Time-Oriented Database Applications in SQL*](https://www2.cs.arizona.edu/~rts/tdbbook.pdf), [PostgreSQL 18 — Exclusion Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION)
