---
title: Each table represents exactly one subject
tags: tbl, table, single-subject
---

## Each table represents exactly one subject

The wrong default is to organize a table around a document or a screen — an "orders" table that also carries the customer's name and address and each line item. When a table represents more than one subject (an object like a customer or product, or an event like a sale), the subjects that appear as satellites get duplicated across every row, and updating one fact means updating many rows. This is the root cause of redundant data, inconsistent data, and modification anomalies.

Test each table by asking what single subject it is about; every field must be a characteristic of *that* subject. If fields describe a second subject, that subject is its own table, joined by a key.

**Incorrect (one table, three subjects — customer and product facts repeat per row):**

```sql
CREATE TABLE CustomerOrders (
  OrderNumber   INTEGER,
  OrderDate     DATE,
  CustFirstName TEXT,     -- customer subject, repeats on every order
  CustPhone     TEXT,     -- customer subject
  ProductName   TEXT,     -- product subject, needs many rows per order
  Quantity      INTEGER,
  UnitPrice     NUMERIC   -- three subjects tangled in one table
);
```

**Correct (one subject per table, related by keys):**

```sql
CREATE TABLE Customers (CustomerID INTEGER PRIMARY KEY, CustFirstName TEXT, CustPhone TEXT);
CREATE TABLE Orders    (OrderNumber INTEGER PRIMARY KEY, OrderDate DATE, CustomerID INTEGER);
CREATE TABLE OrderItems(OrderNumber INTEGER, ProductID INTEGER, Quantity INTEGER,
                        PRIMARY KEY (OrderNumber, ProductID));
```
