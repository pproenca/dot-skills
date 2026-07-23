---
title: Place the foreign key on the many side of a one-to-many
tags: rel, foreign-key, placement
---

## Place the foreign key on the many side of a one-to-many

The wrong default is to put the relating field on whichever side feels natural — often the "one" side, where it promptly turns into a multivalued field (a customer row trying to list all its order numbers). In a one-to-many relationship the foreign key goes on the **many** side: each child record stores one copy of the parent's primary key. That single placement expresses "many children, one parent" without any repeating group.

For a one-to-one relationship the foreign key can sit on either table; put it on the side whose participation is mandatory (the record that must exist), and mark that foreign key unique.

**Incorrect (FK on the "one" side becomes a multivalued field):**

```sql
CREATE TABLE Customers (
  CustomerID  INTEGER PRIMARY KEY,
  OrderNumbers TEXT   -- "1001, 1002, 1003" : the classic wrong side
);
```

**Correct (FK on the many side — one parent key per child row):**

```sql
CREATE TABLE Customers (CustomerID INTEGER PRIMARY KEY, CustFirstName TEXT);
CREATE TABLE Orders (
  OrderNumber INTEGER PRIMARY KEY,
  CustomerID  INTEGER NOT NULL,        -- FK on the many side
  FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);
```
