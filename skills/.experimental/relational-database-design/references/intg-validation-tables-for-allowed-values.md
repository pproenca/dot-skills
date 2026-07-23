---
title: Use a validation table for a field's allowed values
tags: intg, validation-table, lookup
---

## Use a validation table for a field's allowed values

The wrong default for "this field may only hold these values" is to hardcode the list — in a check constraint, a form dropdown, or application code — so that adding an allowed value means editing code and every place that copied the list. When the set of valid values is data the organization maintains (states served, product categories, status codes), store it in a *validation table* (a lookup table) and enforce the constraint with a foreign key into it. Extending the allowed set is then an INSERT, not a code change.

A validation table typically holds a single subject with just a code and a description; the field being constrained carries a foreign key into it.

```sql
CREATE TABLE Categories (              -- validation table: the allowed values are data
  CategoryID   TEXT PRIMARY KEY,
  CategoryName TEXT NOT NULL
);
CREATE TABLE Products (
  ProductID  INTEGER PRIMARY KEY,
  ProductName TEXT,
  CategoryID  TEXT NOT NULL,
  FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID)  -- restricts to valid values
);
-- New category → INSERT INTO Categories; no schema or code change.
```
