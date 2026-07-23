---
title: Store amounts as exact numerics with an explicit currency
tags: type, numeric, money, floating-point
---

## Store amounts as exact numerics with an explicit currency

Reaching for an exact type is the easy part. Two things go wrong after that.
PostgreSQL's `money` type looks purpose-built for the job and is listed under
*Don't Do This*: its fractional precision comes from the `lc_monetary` setting,
so the interpretation of values already on disk changes when that setting
changes, and it carries no currency of its own.

The second is silence about currency. A bare `amount` column is only correct
while the system handles exactly one currency, and the migration that adds the
second one has to touch every historical row without knowing what any of them
meant. The currency is part of the amount; a number without it is not a price.

```sql
CREATE TABLE invoice_lines (
    invoice_id     bigint NOT NULL REFERENCES invoices ON DELETE CASCADE,
    line_no        int    NOT NULL,
    description    text   NOT NULL,
    -- Minor units, exact by construction: 1250 = 12.50. No scale to get wrong,
    -- no rounding on the way in.
    unit_amount    bigint NOT NULL CHECK (unit_amount >= 0),
    currency       text   NOT NULL REFERENCES currencies (code),
    quantity       numeric(12,3) NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (invoice_id, line_no)
);
```

Two representations are defensible. **Minor units in a `bigint`** is exact by
construction and matches what payment processors exchange, at the cost of
carrying the currency's exponent in application code — most are 2, but JPY is 0
and KWD is 3. **`numeric(precision, scale)`** is exact arithmetic with a scale
you declare, and is the better fit when amounts are multiplied by rates or
quantities and intermediate precision matters. Choose one per system and hold
it; mixing them is where rounding bugs actually come from.

Currency is a foreign key into a `currencies` table rather than free text, so a
typo is rejected and the ISO 4217 exponent has somewhere to live — that table is
what tells you JPY has none. The code column itself is `text` with
`CHECK (code ~ '^[A-Z]{3}$')` rather than `char(3)`, for the padding reasons in
[`type-text-over-varchar`](type-text-over-varchar.md).

Never let an exchange rate be implicit: a converted amount needs the rate and
the instant it was taken, or the conversion cannot be audited or reproduced.

Reference: [PostgreSQL Wiki — Don't Do This: money](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_money), [PostgreSQL 18 — Numeric Types](https://www.postgresql.org/docs/18/datatype-numeric.html)
