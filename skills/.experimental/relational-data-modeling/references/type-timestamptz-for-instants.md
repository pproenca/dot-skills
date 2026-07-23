---
title: Use timestamptz for instants and date or time for civil values
tags: type, timestamp, timezone, temporal
---

## Use timestamptz for instants and date or time for civil values

`timestamp` is the type that gets chosen, because it is the one whose name
matches the concept. It is the wrong one: `timestamp without time zone` stores a
picture of a wall clock with no indication of whose wall it was on, so the same
stored value names a different moment in every zone, and arithmetic across a
daylight-saving boundary has no defined answer. PostgreSQL's own wiki lists it
under *Don't Do This* for exactly this reason. `timestamptz` stores an absolute
instant and renders it in the session's zone — it does not store a zone, which
is the usual misconception, but it does store an unambiguous point in time.

The mirror-image error is forcing everything into `timestamptz`. A date of
birth, a public holiday, and a store's 09:00 opening are not instants — they are
civil values that stay the same as the reader moves between zones. Storing them
as `timestamptz` invents an offset and produces off-by-one-day bugs the first
time someone reads the row from another region.

```sql
CREATE TABLE store_hours (
    store_id     bigint NOT NULL REFERENCES stores,
    day_of_week  int    NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    opens_at     time   NOT NULL,   -- civil: 09:00 local, everywhere
    closes_at    time   NOT NULL,
    PRIMARY KEY (store_id, day_of_week)
);

CREATE TABLE shipments (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id     bigint NOT NULL REFERENCES orders,
    dispatched_at timestamptz NOT NULL,   -- an instant: one moment worldwide
    delivery_due  date        NOT NULL    -- civil: "by the 14th" in the buyer's terms
);
```

When a future event is scheduled in a place — a meeting at 09:00 in Lisbon next
March — the instant is not yet determined, because the zone's rules can change.
Store the civil `timestamp` plus the IANA zone name (`Europe/Lisbon`) and
resolve to an instant at read time. That is the one case where naked `timestamp`
is correct, and it needs the zone column next to it.

Two related traps from the same source: `BETWEEN` on timestamps uses closed
intervals, so a range ending at midnight double-counts the boundary row — use
`>= lower AND < upper`. And `timestamp(0)` rounds rather than truncates, so a
value at 12:00:00.7 is stored as 12:00:01; use `date_trunc('second', ...)`.

Reference: [PostgreSQL Wiki — Don't Do This: timestamp](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29), [PostgreSQL 18 — Date/Time Types](https://www.postgresql.org/docs/18/datatype-datetime.html)
