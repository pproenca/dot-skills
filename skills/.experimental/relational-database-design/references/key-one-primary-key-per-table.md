---
title: Give every table exactly one primary key
tags: key, primary-key, table-integrity
---

## Give every table exactly one primary key

The wrong default is to leave a table without a real primary key — relying on "the first column" or on no key at all — which is exactly the flat-file failure where the same order number appears on several rows and no value identifies a record. Every table gets one, and only one, primary key, chosen from its qualified candidate keys. The primary key is what enforces table-level integrity: no duplicate records, and each record exclusively identified.

```text
Rules for the primary key:
  - Each table has one — and only one — primary key.
  - Every primary-key value is unique; none is ever null.
  - It exclusively identifies each record and the value of every field in that record.
  - Each primary key is unique across the whole database — no two tables share the
    same primary key, unless one table is a subset of the other (a subset table).
```

When no natural candidate key qualifies cleanly, introduce a surrogate key (a system-assigned identifier) rather than forcing an unstable or sensitive field into the role.

```sql
CREATE TABLE Customers (
  CustomerID   INTEGER PRIMARY KEY,   -- surrogate: stable, unique, never null
  CustFirstName TEXT NOT NULL,
  CustLastName  TEXT NOT NULL
);
```
