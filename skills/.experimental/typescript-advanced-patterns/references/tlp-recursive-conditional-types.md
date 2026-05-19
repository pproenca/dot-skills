---
title: Use Recursive Conditional Types for Structural Transformations
impact: HIGH
impactDescription: enables deep transformations (DeepReadonly, DeepPartial, NonNullableDeep) that would otherwise require code generation
tags: tlp, recursion, conditional-types, mapped-types, type-level
---

## Use Recursive Conditional Types for Structural Transformations

A conditional type that names itself recursively can walk into nested structures and apply a transformation at every level. This is the engine behind `DeepReadonly`, `DeepPartial`, `DeepRequired`, `Paths<T>`, and most of `type-fest`. The pattern is straightforward but easy to get subtly wrong — common mistakes are missing the array case, treating tuples like arrays, and forgetting to terminate on primitives. Get the base cases right and the rest is mechanical.

**Incorrect (shallow — only the top level is transformed):**

```typescript
type Readonly1<T> = { readonly [K in keyof T]: T[K] }

type Order = {
  id: string
  customer: { name: string; address: { city: string } }
  items: { sku: string }[]
}

const o: Readonly1<Order> = { /* ... */ } as any
o.id = '2'                    // Error: readonly
o.customer.name = 'mutated'   // OK — bug: inner objects not readonly
o.items[0].sku = 'changed'    // OK — bug
```

**Correct (recursive — descend into objects, arrays, and tuples):**

```typescript
type DeepReadonly<T> =
  T extends (infer U)[]                       // arrays and tuples
    ? readonly DeepReadonly<U>[]
    : T extends Function                      // skip functions; freezing them is meaningless
    ? T
    : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T                                       // primitives, terminate

const o: DeepReadonly<Order> = { /* ... */ } as any
o.id = '2'                    // Error
o.customer.name = 'mutated'   // Error
o.items[0].sku = 'changed'    // Error
```

The order of the conditional branches matters: check arrays before plain objects (arrays *are* objects), check functions before objects (functions are also objects), terminate on the primitive fallthrough. Tuples preserve their length because mapped types over an array-like preserve `length` and index signatures.

**When NOT to apply:**
- Cyclic types — they will not terminate. Wrap recursive fields in a non-recursive alias or use `WeakMap` for runtime memoisation if you really need both.
- Types with deeply nested generics where the recursion blows past TypeScript's instantiation depth limit (~50). Use the tail-recursion accumulator pattern (`[[tlp-tail-recursion-accumulator]]`) when applicable.
- When you only need shallow transformation — `Readonly<T>`, `Partial<T>`, `Required<T>` from lib.d.ts are cheaper.

**Scope delta:**
- `typescript-refactor`'s `compile-avoid-deep-recursion` warns *against* deep recursion for compile-time reasons. This rule explains when deep recursion is the *right* answer and how to write it so it stays cheap (good base cases, no double recursion, no nested conditionals on the same generic parameter).

Reference: [TypeScript 3.7 Release Notes — Recursive Type Aliases](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#recursive-type-aliases)
