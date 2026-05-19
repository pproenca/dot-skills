---
title: Enforce Builder Call Order with Phantom State Types
impact: CRITICAL
impactDescription: prevents 100% of out-of-order builder calls at compile time
tags: dsl, builder, phantom-types, state-machine, library-design
---

## Enforce Builder Call Order with Phantom State Types

A fluent builder that exposes every method on every instance is just a wrapper around a mutable object — the type system gives no protection against forgetting required steps. By threading a phantom state type through the builder's generic parameters, the available methods change as required fields are filled, and the final `.build()` only exists when state proves all preconditions were satisfied. This is the core trick behind compile-time-safe DSLs.

**Incorrect (runtime check for required fields):**

```typescript
class QueryBuilder {
  private table?: string
  private columns?: string[]

  from(table: string) { this.table = table; return this }
  select(columns: string[]) { this.columns = columns; return this }

  build(): string {
    if (!this.table) throw new Error('from() is required')
    if (!this.columns) throw new Error('select() is required')
    return `SELECT ${this.columns.join(',')} FROM ${this.table}`
  }
}

new QueryBuilder().build()                              // Compiles. Throws at runtime.
new QueryBuilder().select(['id']).build()               // Compiles. Throws at runtime.
new QueryBuilder().from('users').select(['id']).build() // OK.
```

**Correct (phantom state types make .build() unavailable until ready):**

```typescript
type BuilderState = { table: boolean; columns: boolean }
type Ready = { table: true; columns: true }

class QueryBuilder<S extends BuilderState = { table: false; columns: false }> {
  private constructor(private parts: { table?: string; columns?: string[] }) {}

  static create(): QueryBuilder<{ table: false; columns: false }> {
    return new QueryBuilder({})
  }

  from(table: string): QueryBuilder<S & { table: true }> {
    return new QueryBuilder({ ...this.parts, table }) as QueryBuilder<S & { table: true }>
  }

  select(columns: string[]): QueryBuilder<S & { columns: true }> {
    return new QueryBuilder({ ...this.parts, columns }) as QueryBuilder<S & { columns: true }>
  }

  build(this: QueryBuilder<Ready>): string {
    return `SELECT ${this.parts.columns!.join(',')} FROM ${this.parts.table!}`
  }
}

QueryBuilder.create().build()                                // Error: 'this' context not assignable.
QueryBuilder.create().select(['id']).build()                 // Error: missing { table: true }.
QueryBuilder.create().from('users').select(['id']).build()   // OK.
```

The `this` parameter on `build()` constrains who can call it. The error message points the caller to the missing call.

**When NOT to apply:**
- Internal-only builders called from a small, well-tested surface — runtime checks are cheaper to maintain.
- Builders with no required fields (only optional configuration).
- When the call order is enforced by a code generator or schema, not by a hand-written builder.

**Scope delta:**
- `typescript-refactor`'s `arch-branded-types` covers nominal typing for IDs. This rule applies the same nominal-tag mechanism to builder *state*, where the brand is a record of which methods have been called.

Reference: [TypeScript Handbook — Generics with `this` Parameters](https://www.typescriptlang.org/docs/handbook/2/functions.html#declaring-this-in-a-function)
