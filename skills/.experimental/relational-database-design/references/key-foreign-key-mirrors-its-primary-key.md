---
title: Mirror the referenced primary key in every foreign key
tags: key, foreign-key, referential-integrity
---

## Mirror the referenced primary key in every foreign key

The wrong default is to relate tables through a field that merely resembles the target key — `Emp #` pointing at `EmployeeNumber`, `Client #` at `CustomerID`. Mismatched names and specs leave it unclear whether the foreign key is even valid, and nothing stops a value that has no matching primary-key record (an orphan). A foreign key is a disciplined copy of the primary key it points to.

```text
Elements of a foreign key:
  - Same NAME as the primary key it was copied from
    (the one exception: a self-referencing relationship, where the FK needs a
     distinct name because both keys live in the same table).
  - A REPLICA of that primary key's field specification (kept in sync with it).
  - Draws its values from that primary key — a value must already exist there.
    This last element is referential integrity: no orphan records.
```

Set the foreign key's uniqueness to match the relationship: *non-unique* for one-to-many (one parent value relates to many child records), *unique* for one-to-one. Unlike the primary key, foreign-key values are entered by the user, so its range of values is constrained to the existing primary-key values.

```sql
CREATE TABLE Orders (
  OrderNumber    INTEGER PRIMARY KEY,
  CustomerID     INTEGER NOT NULL,   -- same name + spec as Customers.CustomerID
  FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)  -- referential integrity
);
```
