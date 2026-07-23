---
title: Use text with a CHECK rather than varchar(n)
tags: type, text, varchar, domain
---

## Use text with a CHECK rather than varchar(n)

`varchar(255)` is a reflex carried over from MySQL, where 255 was a row-format
boundary. In PostgreSQL it means nothing: `text`, `varchar`, and `varchar(n)`
share one implementation, and the manual reports no performance difference among
them "apart from increased storage space when using the blank-padded type, and a
few extra CPU cycles to check the length when storing into a length-constrained
column". What `varchar(n)` does is smuggle a business constraint into the type, where it
is the least flexible thing to change — widening it is a catalogue change, but
narrowing it or adding any other rule about the value is a full table rewrite,
and the number itself is almost always arbitrary. A `CHECK` states the same rule
where it can be read, named in an error message, and altered with
`NOT VALID` / `VALIDATE`.

```sql
CREATE TABLE contacts (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email      text NOT NULL CHECK (email = lower(email) AND email LIKE '%_@_%'),
    -- A real limit from a real requirement, not a round number.
    sms_body   text CHECK (length(sms_body) <= 160)
);
```

When the same rule repeats across tables, a domain names it once and applies it
everywhere, which is the part `varchar(n)` cannot do at all:

```sql
CREATE DOMAIN country_code AS text
    CHECK (VALUE ~ '^[A-Z]{2}$');

CREATE TABLE addresses (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country country_code NOT NULL
);
```

Avoid `char(n)` outright: it pads with trailing spaces to the declared width,
which wastes storage and changes comparison semantics, and it buys no
performance over `varchar(n)`. A genuinely fixed-width identifier is still
`text` with a length or pattern `CHECK`.

A length cap is still worth having on anything user-supplied — an unbounded
`text` column is an unbounded write. The point is that the cap is a stated
requirement, not a default of 255.

Reference: [PostgreSQL Wiki — Don't Do This: varchar(n) and char(n)](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_varchar.28n.29_by_default), [PostgreSQL 18 — Character Types](https://www.postgresql.org/docs/18/datatype-character.html)
