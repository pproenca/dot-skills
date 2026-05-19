---
title: Encode Query Shape in the Builder's Return Type
impact: CRITICAL
impactDescription: prevents 100% of column-name and result-shape mismatches at the call site
tags: dsl, query-builder, generics, library-design, sql
---

## Encode Query Shape in the Builder's Return Type

A query builder that returns `any[]` or `Record<string, unknown>[]` is a string-concatenator with a fluent dressing. The advanced pattern — used by Drizzle, Kysely, and ts-pattern-based DSLs — is to thread the *currently-selected columns* through the builder's generic parameter so the final `.execute()` resolves to an exact row shape. Every change to `.select()` updates downstream `.where()`, `.orderBy()`, and result type in lockstep.

**Incorrect (column names are strings, results are any):**

```typescript
class Query {
  constructor(private table: string, private cols: string[] = []) {}
  select(cols: string[]) { return new Query(this.table, cols) }
  where(predicate: (row: any) => boolean) { /* ignored at compile time */ return this }
  async execute(): Promise<any[]> { /* ... */ return [] }
}

const rows = await new Query('users').select(['id', 'eml']).execute()
//                                              ^^^^^ typo, accepted
rows[0].name // any — no error, undefined at runtime
```

**Correct (selected columns drive the row type):**

```typescript
type Schema = {
  users: { id: number; email: string; name: string; createdAt: Date }
  orders: { id: number; userId: number; total: number }
}

type Pick<T, K extends keyof T> = { [P in K]: T[P] }

class Query<Table extends keyof Schema, Cols extends keyof Schema[Table] = keyof Schema[Table]> {
  constructor(private table: Table, private cols: readonly Cols[] = [] as never) {}

  select<C extends keyof Schema[Table]>(cols: readonly C[]): Query<Table, C> {
    return new Query(this.table, cols)
  }

  where(predicate: (row: Pick<Schema[Table], Cols>) => boolean): this {
    return this
  }

  async execute(): Promise<Pick<Schema[Table], Cols>[]> {
    return [] // real impl runs SQL
  }
}

const rows = await new Query('users').select(['id', 'email']).execute()
//    ^? { id: number; email: string }[]
rows[0].name        // Error: Property 'name' does not exist
rows[0].email       // string

new Query('users').select(['id', 'eml'])
//                              ^^^^^ Error: 'eml' is not assignable to keyof Schema['users']
```

The `where()` callback receives the same projected shape, so predicates can only reference columns that are actually present.

**When NOT to apply:**
- Truly dynamic queries where columns are decided at runtime (admin tools, ad-hoc analytics) — accept `string` at the public boundary and fall back to `unknown`-typed rows.
- Aggregations and joins beyond simple projection — they need additional type machinery (renaming, conflict resolution) that's worth keeping in a separate rule or library.

**Scope delta:**
- This is a more elaborate cousin of `[[dsl-fluent-builder-phantom-state]]`: the builder's generic parameter tracks *what data exists*, not *which methods have been called*.

Reference: [Drizzle ORM — Type-safe SQL queries](https://orm.drizzle.team/docs/select)
