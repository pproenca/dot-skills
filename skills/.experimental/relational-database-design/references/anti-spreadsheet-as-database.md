---
title: Reject the spreadsheet layout as a schema
tags: anti, spreadsheet, mindset
---

## Reject the spreadsheet layout as a schema

The wrong default is to carry a spreadsheet straight into a database — one sheet becomes one table, its columns become fields, its visual layout becomes the structure. A spreadsheet is built to store data exactly as it is displayed; a relational database separates how data is *stored* from how it is *presented*. Modeling the storage on the display reproduces every spreadsheet defect: duplicate fields, multipart cells, multivalued cells, and no key.

Break the spreadsheet-view mindset: the database will not store data in the report's shape, and that is the point. Design the underlying tables properly, and reconstruct the familiar layout with a view or report at read time.

```text
Spreadsheet "database" (each column is a duplicate, multipart, multivalued field):
  A: "Store 100 (344-0029)" / "Manager: Mike Hernandez" / "Asst. Mgr: Bob McNeal and Suzi Thompson"
  C: "Store 103 (554-2993)" / ...

Relational tables underneath:
  Stores    (StoreID, StoreName, StorePhone)
  Managers  (ManagerID, StoreID, ManagerName, IsAssistant)   -- one manager per row
  → the spreadsheet's grid is rebuilt by a report/view, not stored as-is.
```
