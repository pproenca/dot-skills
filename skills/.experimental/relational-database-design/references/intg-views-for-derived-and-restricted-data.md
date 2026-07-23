---
title: Use views for derived, combined, and restricted data
tags: intg, views, virtual-table
---

## Use views for derived, combined, and restricted data

The wrong default, when a report needs fields from several tables, an aggregate, or a subset of columns, is to reshape the base tables — adding reference fields, storing totals, or exposing whole tables to every user. A view (a virtual table computed from base tables on each access) delivers all three needs without touching the stored structure. Reach for the view type that fits:

```text
Data view       — presents selected fields from one or more related base tables.
                  Edits flow back to the base tables, subject to field specs and rules.
                  Use instead of copying reference fields between tables.
Aggregate view  — groups data and adds calculated fields (Count, Sum, Avg, Min, Max).
                  Read-only (all fields are grouping or calculated). Use for reports
                  and statistics instead of storing computed totals.
Validation view — like a validation table, but draws its values from base tables; also
                  restricts which fields a user sees, so it doubles as a security/
                  confidentiality boundary.
```

A data view has no stored data and no primary key of its own — it is not a table. Design the fundamental views during logical design, focused on data access and information retrieval; leave materialized and partitioned views to the physical implementation.
