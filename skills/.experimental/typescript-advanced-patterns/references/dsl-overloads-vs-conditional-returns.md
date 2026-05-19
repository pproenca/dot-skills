---
title: Choose Overloads Over Conditional Return Types
impact: CRITICAL
impactDescription: produces better error messages and 2-5× faster type-checking at call sites; preserves narrowing
tags: dsl, overloads, conditional-types, inference, library-design
---

## Choose Overloads Over Conditional Return Types

Both function overloads and conditional return types can give a function different output types based on its input. They look interchangeable. They are not. Overloads produce per-signature error messages and let the compiler narrow eagerly; conditional return types collapse to a single signature whose return is a deferred expression, which the compiler must re-evaluate on every call. For public DSL surfaces, overloads almost always win. Reach for conditional returns only when the output type depends on *runtime-erased* data the overloads can't enumerate.

**Incorrect (conditional return type — opaque errors, slow inference):**

```typescript
type QueryReturn<Opts> =
  Opts extends { single: true } ? User : User[]

function query<Opts extends { id: string; single?: boolean }>(opts: Opts): QueryReturn<Opts> {
  // Implementation needs to assert because the return is conditional
  return (opts.single ? { id: opts.id } : [{ id: opts.id }]) as QueryReturn<Opts>
}

const user = query({ id: 'u_1', single: true })
// Hover shows: QueryReturn<{ id: string; single: true }>
// The user has to mentally evaluate the conditional to understand what they got.

const result = query({ id: 'u_1', single: maybeFlag })
// Error message: "Argument of type ... is not assignable to QueryReturn<...>"
// Practically unactionable.
```

**Correct (overloads — concrete signatures, narrowable errors):**

```typescript
function query(opts: { id: string; single: true }): User
function query(opts: { id: string; single?: false }): User[]
function query(opts: { id: string; single?: boolean }): User | User[] {
  return opts.single ? { id: opts.id } : [{ id: opts.id }]
}

const user = query({ id: 'u_1', single: true })
//    ^? User — hover shows the resolved overload directly.

const list = query({ id: 'u_1' })
//    ^? User[]

query({ id: 'u_1', single: 'yes' })
// Error: 'yes' is not assignable to 'true'. Clear and local.
```

The implementation signature (last one) is internal — callers only see the public overloads. Use conditional return types instead only when:
1. The discriminator is a generic type parameter the caller passes explicitly (`function pick<K extends keyof T>(obj: T, key: K): T[K]`).
2. There are too many combinations to overload (5+ flags).
3. The return depends on a structural property of an inferred type, not a literal value.

**When NOT to apply:**
- When you really need return inference parameterised by a literal generic — conditional return types are the only option (see `[[dsl-type-safe-object-paths]]` for an example).
- When the function genuinely has only one return type but takes many input shapes — neither overloads nor conditional returns; use a discriminated input union.

**Scope delta:**
- `typescript-refactor`'s `generic-return-type-inference` covers preserving inference *within* generics. This rule covers the broader DSL-design question: *should the return shape vary at all*, and if yes, with what mechanism?

Reference: [TypeScript Handbook — Function Overloads](https://www.typescriptlang.org/docs/handbook/2/functions.html#function-overloads)
