---
title: Use identity columns instead of serial
tags: schema, identity, serial, primary-key
---

## Use identity columns instead of serial

`serial().primaryKey()` is the shape every Postgres tutorial teaches, and Postgres itself has recommended against it since version 10. `serial` is not a type — it is a macro that creates an `integer` column plus a standalone sequence plus a default, leaving three loosely coupled objects whose ownership, permissions, and dump/restore behavior have to be managed by hand. Identity columns are the SQL-standard replacement: the sequence is owned by the column, dropped with it, and `GENERATED ALWAYS` additionally rejects an accidental explicit insert into the key rather than silently desynchronising the sequence.

```typescript
import { pgTable, text, integer, timestamp } from 'drizzle-orm/pg-core'

export const customers = pgTable('customers', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  email: text().notNull().unique(),
  createdAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
})
```

Use `generatedByDefaultAsIdentity()` instead when you must be able to supply the id explicitly — data imports and cross-environment seeding are the usual reasons. For keys that must be generatable client-side or must not leak row counts, `uuid().primaryKey().defaultRandom()` is the alternative; it costs more index space and loses insertion locality, so it is a deliberate trade rather than a default.

Reference: [PostgreSQL Wiki — Don't Do This: serial](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_serial) · [PostgreSQL — CREATE TABLE, identity columns](https://www.postgresql.org/docs/current/sql-createtable.html)
