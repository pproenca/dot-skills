---
title: Move a multivalued field into its own table
tags: fld, multivalued, repeating-group
---

## Move a multivalued field into its own table

The wrong default is to stuff several occurrences of the same kind of value into one field — `CategoriesTaught = "DTP, SS, WP"` — or to "flatten" them into numbered columns (`Category1`, `Category2`, `Category3`). A comma-delimited field can't be searched, sorted, or grouped reliably, and it caps how many values fit; numbered columns still cap the count, scatter the same value across different columns, and force every query to check all of them. Neither is a fix.

Resolve a multivalued field by moving it into a new table: the field becomes a single-valued column there, and a copy of the original table's key relates the two. When a second field is in strict one-to-one correspondence with the multivalued one (e.g. each category taught has a matching skill level), carry that dependent field into the same new table.

**Incorrect (list crammed into one field, or flattened into fixed columns):**

```sql
CREATE TABLE Instructors (
  InstructorID    INTEGER PRIMARY KEY,
  CategoriesTaught TEXT   -- "DTP, SS, WP" : cannot search/sort/group; hard cap on values
);
```

**Correct (one value per row in a related table; dependent field rides along):**

```sql
CREATE TABLE Instructors (InstructorID INTEGER PRIMARY KEY, InstFirstName TEXT);
CREATE TABLE InstructorCategories (
  InstructorID  INTEGER,
  CategoryTaught TEXT,          -- single value per row
  MaximumLevel   TEXT,          -- dependent 1:1 field travels with it
  PRIMARY KEY (InstructorID, CategoryTaught)
);
```
