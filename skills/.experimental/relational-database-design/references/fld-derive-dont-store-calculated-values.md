---
title: Calculations belong in a view, not a stored field
tags: fld, calculated, derived
---

## Calculations belong in a view, not a stored field

The wrong default is to store a value that is computed from other fields — an `OrderAmount` that is `Quantity * Price`, a `LineExtension`, a concatenated `FullName`. A stored calculation depends on other fields for its value, which breaks the rule that fields be mutually independent, and it goes stale the instant any input changes. Keeping it correct then becomes the user's or the application's burden — exactly the manual-consistency trap that causes wrong information.

Store only the independent inputs; compute the derived value where it is needed, in a view or a query. This keeps every field self-contained and the derived value always current.

**Incorrect (LineExtension and OrderAmount stored, go stale on any edit):**

```sql
CREATE TABLE OrderItems (
  OrderNumber   INTEGER,
  ProductID     INTEGER,
  Quantity      INTEGER,
  UnitPrice     NUMERIC,
  LineExtension NUMERIC   -- = Quantity * UnitPrice : stale the moment either changes
);
```

**Correct (store inputs; derive the value in a view):**

```sql
CREATE TABLE OrderItems (
  OrderNumber INTEGER, ProductID INTEGER, Quantity INTEGER, UnitPrice NUMERIC,
  PRIMARY KEY (OrderNumber, ProductID)
);
CREATE VIEW OrderItemTotals AS
  SELECT OrderNumber, ProductID, Quantity * UnitPrice AS LineExtension FROM OrderItems;
```
