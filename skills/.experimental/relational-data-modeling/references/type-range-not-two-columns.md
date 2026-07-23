---
title: Model a period as a range type, not two loose columns
tags: type, range-type, temporal, gist-index
---

## Model a period as a range type, not two loose columns

`starts_at` and `ends_at` as two independent columns is the default, and it
leaves three things undone. Nothing prevents an inverted row where the end
precedes the start. The boundary convention is undeclared, so half the codebase
treats the end as inclusive and half as exclusive, and back-to-back periods
either overlap or leave a gap depending on which query you read. And containment
— "which price was in effect on this date" — cannot use an index, so it degrades
to a scan with two comparisons.

A range type makes the pair one value with one meaning. Inverted bounds are
rejected by construction (`daterange('2026-04-01','2026-01-01')` raises), `@>`
and `&&` are indexable via GiST, and — decisively — a range or multirange is the
only thing a `WITHOUT OVERLAPS` key can be built on, so this choice is what
unlocks
[`cons-exclude-for-non-overlap`](cons-exclude-for-non-overlap.md) and
[`time-validity-as-a-range`](time-validity-as-a-range.md).

```sql
CREATE TABLE product_prices (
    product_id   bigint NOT NULL REFERENCES products,
    -- '[)' — inclusive lower, exclusive upper. A price ending on the 1st and
    -- the next beginning on the 1st are adjacent, not overlapping.
    effective    daterange NOT NULL,
    unit_amount  bigint NOT NULL CHECK (unit_amount >= 0),
    -- Empty ranges are NOT rejected by construction: daterange('2026-01-01',
    -- '2026-01-01') normalises to `empty` rather than raising. Exclude it
    -- explicitly, or a price row can exist that is in effect on no date at all.
    CHECK (NOT isempty(effective) AND NOT lower_inf(effective))
);

CREATE INDEX ON product_prices USING gist (effective);

-- Containment reads as the question it answers.
SELECT unit_amount FROM product_prices
 WHERE product_id = 91 AND effective @> DATE '2026-03-01';
```

Use `[)` everywhere and say so once. It is the convention that makes "adjacent"
and "overlapping" distinguishable, makes duration a subtraction with no
off-by-one, and matches how `daterange` and `tstzrange` normalise discrete
bounds anyway. Mixing conventions across tables is the source of the
"back-to-back bookings conflict" bug.

An open upper bound — `daterange(start, NULL)` — means "still in effect", which
removes the sentinel `9999-12-31` that otherwise appears in every temporal
schema and breaks the moment someone compares it arithmetically.

Reference: [PostgreSQL 18 — Range Types](https://www.postgresql.org/docs/18/rangetypes.html), [PostgreSQL Wiki — Don't Do This: BETWEEN with timestamps](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_BETWEEN_.28especially_with_timestamps.29)
