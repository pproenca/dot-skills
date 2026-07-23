---
title: Store the parts and generate the composite, never parse it back
tags: norm, first-normal-form, smart-key, generated-column
---

## Store the parts and generate the composite, never parse it back

Human-facing reference codes — `INV-2026-0001`, `ORD-EU-4471`, a SKU encoding
size and colour — get stored as the string, because the string is what people
quote. Everything downstream then has to take it apart: the year comes out with
`substring`, "the next number this year" is a `max()` over a parsed fragment,
and the uniqueness rule that actually matters ("one sequence per fiscal year")
is expressed nowhere the database can see. The format also becomes load-bearing
in every consumer at once, so changing it means finding every parser.

Invert the direction. Store the parts as columns, constrain them there, and let
the database generate the display string:

```sql
CREATE TABLE invoices (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fiscal_year int    NOT NULL,
    seq_no      int    NOT NULL CHECK (seq_no > 0),
    reference   text   GENERATED ALWAYS AS
                    ('INV-' || fiscal_year || '-' || lpad(seq_no::text, 4, '0')) STORED,
    -- The rule the encoded string was implying all along, now enforced.
    UNIQUE (fiscal_year, seq_no)
);
```

`reference` cannot drift from its parts, because it cannot be written to, and it
is still a real indexable column for lookup by the code a customer quotes.

The general form of this is that **a column the application has to parse is a
column the database cannot constrain** — no `CHECK` on a fragment, no foreign
key from one, no index that a query on a part can use. The same reasoning
governs a repeating group: if the application splits a value into a list and
then looks up its members, those members need to be rows, because that is the
only shape a foreign key and a per-member unique constraint can attach to.

**When NOT to use this pattern:** atomicity is about whether the *database* ever
needs the parts, not about whether the value has internal structure. A webhook
payload kept for replay, a rendered Markdown body, an encoded image, a list of
opaque labels in a `text[]` — all are single values to this schema, and
splitting them buys nothing. The line is crossed when one element needs a
foreign key or a constraint of its own, which is the boundary discussed in
[`norm-jsonb-for-open-shapes`](norm-jsonb-for-open-shapes.md).

Reference: [PostgreSQL 18 — Generated Columns](https://www.postgresql.org/docs/18/ddl-generated-columns.html), [Karwin, *SQL Antipatterns*: "Jaywalking" and "Multicolumn Attributes"](https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/)
