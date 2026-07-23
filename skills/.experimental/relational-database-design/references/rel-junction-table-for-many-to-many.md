---
title: Resolve many-to-many with a junction table
tags: rel, many-to-many, junction-table
---

## Resolve many-to-many with a junction table

The wrong default for a many-to-many relationship is to jam the association into one side — repeating class columns on a student, or a comma-list of students on a class. A relational database cannot express M:N directly; forcing it produces multivalued fields and duplicated records. Resolve it with a third table — a junction (linking) table — whose primary key is the pair of foreign keys pointing at the two related tables. The M:N becomes two one-to-many relationships, one from each side into the junction table.

The junction table often carries fields that belong to the *association itself* (a grade, an enrollment date, a quantity) — data that describes neither entity alone.

**Incorrect (M:N forced into one side — repeating group):**

```sql
CREATE TABLE Students (
  StudentID INTEGER PRIMARY KEY,
  Class1 INTEGER, Class2 INTEGER, Class3 INTEGER   -- caps and scatters the association
);
```

**Correct (junction table keyed on both foreign keys):**

```sql
CREATE TABLE Students (StudentID INTEGER PRIMARY KEY, StudFirstName TEXT);
CREATE TABLE Classes  (ClassID   INTEGER PRIMARY KEY, ClassName TEXT);
CREATE TABLE StudentClasses (
  StudentID INTEGER,
  ClassID   INTEGER,
  Grade     TEXT,                       -- field that belongs to the association
  PRIMARY KEY (StudentID, ClassID),     -- composite of the two foreign keys
  FOREIGN KEY (StudentID) REFERENCES Students (StudentID),
  FOREIGN KEY (ClassID)   REFERENCES Classes  (ClassID)
);
```
