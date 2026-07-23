---
title: Distinguish acceptable from harmful redundant data
tags: tbl, redundancy, integrity
---

## Distinguish acceptable from harmful redundant data

The wrong default treats all repetition as either fine ("it's just data") or forbidden ("normalize it all away"). Neither is right, and conflating the two leads to either inconsistent data or pointless over-splitting. Redundant data is a value repeated in a field. It is *acceptable* only when it results from a foreign key relating two tables — a foreign-key value repeats by design, and that is how records associate. It is *unacceptable* when it results from a field or table anomaly (a duplicated non-key field, a table with more than one subject), because then the same fact is stored in many places and the copies drift out of sync.

Judge each repetition by its cause, keep the FK-driven kind, and drive everything else to an absolute minimum by fixing the underlying anomaly rather than the symptom.

```text
Acceptable (FK repeats to relate records):
  Orders.CustomerID = 1001 appears on all of customer 1001's orders — by design.

Unacceptable (anomaly duplicates a fact):
  Orders.CustomerName = 'Estela Rosales' repeated on every one of her orders.
  Fix the cause: move the name to Customers, keep only CustomerID on Orders.
```
