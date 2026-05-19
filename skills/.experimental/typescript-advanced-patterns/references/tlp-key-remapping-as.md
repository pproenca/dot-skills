---
title: Remap Keys with `as` Clauses in Mapped Types
impact: HIGH
impactDescription: enables rename, filter, and prefix operations in a single mapped type; replaces multi-pass type pipelines
tags: tlp, mapped-types, key-remapping, type-level
---

## Remap Keys with `as` Clauses in Mapped Types

TypeScript 4.1 added `as` clauses to mapped types, letting you transform each key as it's iterated. Three operations become single-pass: filtering keys out (return `never`), renaming keys (return a different literal), and prefixing/suffixing keys (template literal transformation). Before `as`, the same effects required separate `Pick`/`Omit`/conditional-type pipelines. The `as` clause is the most under-used advanced mapped-type feature in real codebases.

**Incorrect (multi-pass: filter then transform):**

```typescript
type FunctionKeys<T> = { [K in keyof T]: T[K] extends Function ? K : never }[keyof T]
type Methods<T> = Pick<T, FunctionKeys<T>>

interface User {
  id: string
  name: string
  save(): Promise<void>
  delete(): Promise<void>
}

type M = Methods<User>
// { save(): Promise<void>; delete(): Promise<void> } — works, but the helper type
// `FunctionKeys` exists only to be passed to `Pick`. Two type aliases to express one idea.
```

**Correct (filter and rename in one mapped type):**

```typescript
type Methods<T> = {
  [K in keyof T as T[K] extends Function ? K : never]: T[K]
}

type M = Methods<User>
// { save(): Promise<void>; delete(): Promise<void> }

// Rename keys with a template literal:
type Getters<T> = {
  [K in keyof T & string as `get${Capitalize<K>}`]: () => T[K]
}

type G = Getters<{ id: string; name: string }>
// { getId(): string; getName(): string }

// Filter and rename simultaneously:
type Setters<T> = {
  [K in keyof T & string as T[K] extends Function ? never : `set${Capitalize<K>}`]:
    (value: T[K]) => void
}

type S = Setters<User>
// { setId(v: string): void; setName(v: string): void } — methods filtered out, others renamed
```

A common library-author use is generating event-handler prop names from an event map (`onLoggedIn`, `onLoggedOut`) or generating selector hooks from a state shape (`useUserName`, `useUserAge`).

**When NOT to apply:**
- When the filtering or renaming logic depends on context the mapped type can't see (e.g. user input, runtime values).
- For non-string keys (`symbol`, `number`) — template literals only work on `string`, so widen with `& string` and accept that symbol-keyed properties get dropped.
- When you genuinely want a multi-stage pipeline so each step is named and reusable.

**Scope delta:**
- `typescript-refactor`'s `generic-mapped-type-utilities` covers mapped types broadly. This rule is specifically about `as` clauses, which were added later and unlock filtering/renaming in one step — many existing codebases still use the older two-step pattern.

Reference: [TypeScript 4.1 Release Notes — Key Remapping in Mapped Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-1.html#key-remapping-in-mapped-types)
