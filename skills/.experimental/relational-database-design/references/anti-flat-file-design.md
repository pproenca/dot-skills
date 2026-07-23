---
title: Reject flat-file design — the one-giant-table structure
tags: anti, flat-file, decomposition
---

## Reject flat-file design — the one-giant-table structure

The wrong default, especially when porting from a nonrelational or file-based system, is the flat file: throw every field into one big table. It reads as "simple," but it concentrates every relational defect in one place. Recognize it by its symptoms and take the table through the full design process rather than patching individual columns.

```text
Symptoms of a flat-file table (all present in the classic CustomerOrders table):
  - Multiple subjects in one table (customers AND orders AND line items).
  - Repeating groups (Item1/Item2/Item3, Quantity1/Quantity2/Quantity3).
  - Multipart fields (a full name, a full address in one column).
  - Calculated fields (OrderAmount, line extensions).
  - Unnecessary duplicate fields.
  - No true primary key — one order spans several rows sharing the same order number.
```

The fix is not to add columns or clean values in place; it is to decompose into one-subject tables (`tbl-one-subject-per-table`), give each a key, and relate them — the same process every other table goes through.
