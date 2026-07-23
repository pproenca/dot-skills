---
title: Test every field against the ideal-field checklist
tags: fld, field, checklist
---

## Test every field against the ideal-field checklist

A field's name rarely reveals whether it is well-formed; the defects show up only in the values. Run each field through the elements of the ideal field to catch the three field-level defects — multivalued, multipart, and calculated fields — before they force a table rework.

```text
Elements of the ideal field — every field must satisfy all of these:
  - It represents a distinct characteristic of the table's subject.
  - It contains only a single value (not a list).
  - It cannot be broken into smaller meaningful components (it is atomic).
  - It does not contain a calculated or concatenated value.
  - It is unique within the entire database structure
    (the only fields duplicated across tables are the keys that relate them).
  - It keeps the majority of its characteristics when it appears in more than one table
    (i.e. a foreign key matches its primary key's specification).
```

When a name alone is ambiguous, load a few rows of realistic sample data: a value with embedded commas signals multivalued, a value carrying two distinct items signals multipart, a value that must be recomputed when another field changes signals calculated.
