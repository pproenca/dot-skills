---
title: Give a self-referencing table a distinctly named foreign key
tags: rel, self-referencing, hierarchy
---

## Give a self-referencing table a distinctly named foreign key

The wrong default when a table relates to itself — employees who report to a manager who is also an employee, parts made of parts — is either to add a second "manager" table (duplicating the entity) or to reuse the primary key's name for the pointer. A table can relate to itself: the foreign key lives in the *same* table and points at that table's own primary key. Because both keys share the table, the foreign key must take a **distinct name** (the one sanctioned exception to "a foreign key has the same name as its primary key").

Set the deletion rule and participation on the primary-key and foreign-key fields of the one table. Note that Cascade is usually wrong here — you would not delete every employee because their manager left; Restrict or Nullify typically fits.

```sql
CREATE TABLE Employees (
  EmployeeID INTEGER PRIMARY KEY,
  EmpFirstName TEXT,
  ManagerID  INTEGER,                 -- FK into this same table; distinct name (not EmployeeID)
  FOREIGN KEY (ManagerID) REFERENCES Employees (EmployeeID)
);
-- Deletion of a manager: Nullify or Restrict the ManagerID of their reports — not Cascade.
```
