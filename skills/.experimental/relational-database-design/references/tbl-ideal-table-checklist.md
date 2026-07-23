---
title: Test every table against the ideal-table checklist
tags: tbl, table, checklist
---

## Test every table against the ideal-table checklist

A table structure that reads fine can still hide the defects that cause data-integrity problems. Run each table through the six elements of the ideal table; a failure on any one names the specific rework needed before keys and relationships are built on top of it.

```text
Elements of the ideal table — every table must satisfy all six:
  1. It represents a single subject (an object or an event).
  2. It has a primary key.
  3. It contains no multipart or multivalued fields.
  4. It contains no calculated fields.
  5. It contains no unnecessary duplicate fields
     (a field used to relate tables — a foreign key — is the one allowed duplicate).
  6. It contains only an absolute minimum of redundant data.
```

A relational database is never completely free of redundant data (foreign keys repeat by design); the goal is the *minimum*. Elements 3 and 4 are usually resolved when refining fields, but re-check them at the table level — a multivalued or calculated field is easy to miss on the first pass. Load a few rows of realistic sample data to confirm: anomalies surface immediately when you try to sort, filter, or update.
