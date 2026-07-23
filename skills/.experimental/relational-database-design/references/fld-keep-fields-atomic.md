---
title: Decompose multipart fields into one field per distinct item
tags: fld, multipart, atomic
---

## Decompose multipart fields into one field per distinct item

The wrong default is to store several *distinct* items in one field — a full name in `InstName`, a whole mailing address in `InstAddress`. A multipart (composite) field is hard to retrieve from, sort by, or group by: you cannot cleanly pull everyone in one city or sort by zip when city and zip are buried in one address string. Resolve it by asking "what distinct items does this value represent?" and turning each item into its own field.

Some multipart fields are hidden inside a value that looks atomic. A code like `InstrumentID = "GUIT2201"` is really two items — a category (`GUIT`) and an identifier (`2201`); the moment the category scheme changes you would be parsing and rewriting the field by hand. Deconstruct these too.

**Incorrect (each field packs several distinct items):**

```sql
CREATE TABLE Instructors (
  InstName    TEXT,   -- "Kira Bently"                    → two items
  InstAddress TEXT    -- "3131 Mockingbird Ln, Seattle, WA 98157" → four items
);
```

**Correct (one atomic field per distinct item):**

```sql
CREATE TABLE Instructors (
  InstFirstName    TEXT,
  InstLastName     TEXT,
  InstStreetAddress TEXT,
  InstCity         TEXT,
  InstState        TEXT,
  InstZipcode      TEXT
);
```
