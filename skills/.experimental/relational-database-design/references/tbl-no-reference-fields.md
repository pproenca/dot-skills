---
title: Avoid reference fields copied from another table
tags: tbl, reference-fields, duplication
---

## Avoid reference fields copied from another table

The wrong default is to add a field to a table because a report built from that table needs it — copying, say, a manufacturer's phone and website into the products table so one query has everything. These are *reference fields*: duplicates of fields that already live in another table, added on the mistaken belief that a table must contain every field its reports display. They are unnecessary duplicate fields, and they force the user or application to keep every copy consistent by hand — a high-risk, error-prone burden.

A report does not require its source table to hold every column; a view can assemble fields from several related tables at query time. The only field legitimately duplicated across tables is the foreign key that establishes a relationship.

**Incorrect (ManPhone and WebSite duplicate the Manufacturers table):**

```sql
CREATE TABLE Instruments (
  InstrumentID  INTEGER PRIMARY KEY,
  ProductName   TEXT,
  Manufacturer  TEXT,   -- foreign key: legitimate
  ManPhone      TEXT,   -- reference field: already in Manufacturers, remove
  WebSite       TEXT    -- reference field: already in Manufacturers, remove
);
```

**Correct (keep only the relating field; pull the rest through a view):**

```sql
CREATE TABLE Instruments (
  InstrumentID   INTEGER PRIMARY KEY,
  ProductName    TEXT,
  ManufacturerID INTEGER      -- foreign key into Manufacturers
);
-- ManPhone, WebSite come from Manufacturers when a report joins the two tables.
```
