---
title: Test Types with `Equal`, `Expect`, and `@ts-expect-error`
impact: HIGH
impactDescription: catches 100% of regressions in type-level code at CI time, not at the next call site
tags: tlp, testing, type-tests, ts-expect-error, type-level
---

## Test Types with `Equal`, `Expect`, and `@ts-expect-error`

Type-level code is real code. It has bugs, edge cases, and regressions. The same `tsc --noEmit` that compiles your runtime code can run a type-test suite if you give it a few primitives: a strict `Equal<A, B>` predicate (the standard `extends` check is too loose), an `Expect<T extends true>` assertion, and the `@ts-expect-error` directive to assert that a line *should not* compile. With those three, advanced type machinery becomes maintainable; without them, every change is "let's hope nothing breaks at consumer sites."

**Incorrect (no tests — regressions discovered by users):**

```typescript
type DeepReadonly<T> = /* … the recursive helper from another rule … */

// Used here, used there. If someone breaks the array case, they find out
// when a consumer's tuple becomes mutable in production.
```

**Correct (a type-tests file that runs with `tsc --noEmit`):**

```typescript
// type-tests/deep-readonly.test-d.ts

// The minimum-viable strict equality check.
type Equal<A, B> =
  (<T>() => T extends A ? 1 : 2) extends (<T>() => T extends B ? 1 : 2) ? true : false

type Expect<T extends true> = T

// --- Cases ---

type cases = [
  Expect<Equal<DeepReadonly<{ a: number }>, { readonly a: number }>>,
  Expect<Equal<DeepReadonly<{ a: { b: number } }>, { readonly a: { readonly b: number } }>>,
  Expect<Equal<DeepReadonly<number[]>, readonly number[]>>,
  Expect<Equal<DeepReadonly<readonly [1, 2]>, readonly [1, 2]>>,
  Expect<Equal<DeepReadonly<() => void>, () => void>>,  // functions opt out
]

// Negative case: prove a wrong shape does NOT match.
// @ts-expect-error — DeepReadonly should not produce a mutable array
type _negative = Expect<Equal<DeepReadonly<number[]>, number[]>>
```

The `Equal` predicate is intentionally peculiar — it uses generic function identity to distinguish types that are *bidirectionally assignable but not identical* (e.g. `{ a: 1 } & { b: 2 }` vs `{ a: 1; b: 2 }`). Simpler attempts like `[A] extends [B]` and `[B] extends [A]` give false positives.

Run the tests as part of the type-check pass:

```jsonc
// tsconfig.json
{
  "compilerOptions": { "noEmit": true, "strict": true },
  "include": ["src/**/*", "type-tests/**/*"]
}
```

```bash
# In CI
tsc --noEmit
```

Any failed `Expect` produces a type error; any `@ts-expect-error` that *would* have compiled becomes an error too — both regression directions are caught.

**When NOT to apply:**
- Surface-level type aliases (`type User = { ... }`) — the test would re-state the declaration. Tests are for *computed* types.
- One-off helpers that are inlined at the call site — the call site itself is the test.

**Scope delta:**
- No equivalent in any existing TypeScript skill. This is one of the highest-leverage practices in the entire advanced-patterns space and frequently absent from library codebases.

Reference: [vitest's `expectTypeOf` and `assertType`](https://vitest.dev/api/expect-typeof.html) (a runtime-test integration that re-uses the same primitives)
