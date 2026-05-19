---
title: Control Distribution with the `[T] extends [U]` Tuple Trick
impact: HIGH
impactDescription: prevents 100% of accidental union distribution in helpers; preserves whole-union semantics where needed
tags: tlp, conditional-types, distribution, unions, type-level
---

## Control Distribution with the `[T] extends [U]` Tuple Trick

A naked type parameter on the left of `extends` triggers distributive conditional types: `T extends U ? A : B` evaluates separately for each member of `T`'s union. This is sometimes what you want (`Exclude<T, U>` relies on it) and sometimes catastrophic (a "type equality" check returns the wrong answer). The discipline is to know which behaviour you need and to wrap one or both sides in a single-element tuple — `[T] extends [U]` — when you want to compare the whole union as one type instead of element-by-element.

**Incorrect (accidental distribution — equality check broken on unions):**

```typescript
type IsString<T> = T extends string ? true : false

type A = IsString<string>            // true
type B = IsString<number>            // false
type C = IsString<string | number>   // boolean — distributes: (string extends string) | (number extends string)
//                                   //          = true | false = boolean.
// The author wanted: "is the whole union assignable to string?" Answer should be false.

type NonNullableWrong<T> = T extends null | undefined ? never : T
type D = NonNullableWrong<string | null>  // string — distribution lucky here, but for the wrong reason.
```

**Correct (wrap both sides to disable distribution when comparing wholes):**

```typescript
type IsString<T> = [T] extends [string] ? true : false

type A = IsString<string>            // true
type B = IsString<number>            // false
type C = IsString<string | number>   // false — whole-union comparison
type D = IsString<never>             // true — distribution-free, so `never` no longer
//                                   //   collapses the conditional to `never`.
```

Three places where you *want* distribution (keep the naked parameter):

```typescript
type ToArray<T> = T extends unknown ? T[] : never
type E = ToArray<string | number>    // string[] | number[] — distributes correctly

type Exclude<T, U> = T extends U ? never : T
//          ^ distribution is what makes Exclude do per-element filtering
```

Three places where you do *not* want distribution (use `[T] extends [U]`):

```typescript
// 1. Equality / assignability checks
type Equals<A, B> = [A] extends [B] ? [B] extends [A] ? true : false : false

// 2. `never` short-circuits — distributing over `never` returns `never`
type Wrap<T> = [T] extends [never] ? null : { value: T }
type F = Wrap<never>  // null — without brackets it would be `never`.

// 3. Tuple-vs-union assignability
type IsTuple<T> = [T] extends [readonly unknown[]]
  ? number extends T['length'] ? false : true
  : false
```

**When NOT to apply:**
- When you genuinely want per-element evaluation (the `Exclude` / `ToArray` cases above). Wrapping defeats the purpose.
- For binary type-level operators (`And`, `Or`, `Not`) that take exactly one type — single-parameter conditionals don't distribute anyway.

**Scope delta:**
- `typescript-refactor`'s `generic-avoid-distributive-surprises` warns that distribution exists. This rule names the specific cases where you need each behaviour and gives the `[T] extends [U]` recipe to switch between them.

Reference: [TypeScript Handbook — Distributive Conditional Types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#distributive-conditional-types)
