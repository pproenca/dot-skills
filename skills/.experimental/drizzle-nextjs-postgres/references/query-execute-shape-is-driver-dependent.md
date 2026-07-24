---
title: Read db.execute() results by the driver's shape, not a fixed one
tags: query, raw-sql, driver, execute
---

## Read db.execute() results by the driver's shape, not a fixed one

`db.execute(sql\`...\`)` is the escape hatch for raw SQL — estimates from `pg_class`, a window function Drizzle does not model, an extension call — and its return shape is not the same across drivers, which the uniform `db` API hides. On `node-postgres` it resolves to a `pg` `QueryResult`, so the rows are on `result.rows`. On `postgres-js` it resolves to the row array itself, so `result[0]` is a row and `result.rows` is `undefined`. Code written against one driver — `result.rows[0]` — throws `Cannot read properties of undefined` the day the project switches drivers, or when a raw query written for the app's `node-postgres` client is copied into a `postgres-js` migration script.

```typescript
// node-postgres — QueryResult, rows under `.rows`
const pg = await db.execute<{ estimate: number }>(sql`SELECT reltuples::bigint AS estimate FROM pg_class WHERE oid = 'invoices'::regclass`)
const fromNodePg = pg.rows[0].estimate

// postgres-js — the result IS the row array
const js = await db.execute<{ estimate: number }>(sql`SELECT reltuples::bigint AS estimate FROM pg_class WHERE oid = 'invoices'::regclass`)
const fromPostgresJs = js[0].estimate
```

This only bites raw `db.execute()`. The query builder (`db.select()`, `db.query.*`) always returns a plain row array regardless of driver, so it is the safer default whenever the query can be expressed through it — reach for raw SQL only when it genuinely cannot.

Reference: `drizzle-orm@0.45.2/node-postgres/session.d.ts` (`NodePgQueryResultHKT` → `QueryResult`) vs `postgres-js/session.d.ts` (`PostgresJsQueryResultHKT` → `RowList<Row[]>`) · [Drizzle — `sql` operator: `db.execute`](https://orm.drizzle.team/docs/sql)
