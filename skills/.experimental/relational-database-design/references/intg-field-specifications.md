---
title: Pin down every field with a full field specification
tags: intg, field-specification, field-integrity
---

## Pin down every field with a full field specification

The wrong default is to define a field by a bare type — `TEXT`, `INTEGER` — and move on. A type is a fraction of what a field needs to be trustworthy. A field specification captures the field's identity, its physical storage, and its logical rules; completing one per field *is* field-level integrity, and it is the substrate that business rules later modify.

```text
A field specification has three groups of elements:
  General  — field name, parent table, description, aliases, and whether the spec is
             Unique (its own), Generic (a shared template), or a Replica (of another).
  Physical — data type, length, decimal places, input mask, display format,
             character support.
  Logical  — key type (primary/foreign/alternate/non), uniqueness, null support,
             required value, default value, range of values, and the comparisons
             and operations allowed on the value.
```

Reuse pays off: define a *generic* specification once (e.g. a standard "name" or "phone" spec) and apply it as a template across fields; a foreign key uses a *replica* of its primary key's specification and stays synchronized with it. A business rule is applied by modifying specific elements of this spec (see `intg-database-vs-application-rules`).
