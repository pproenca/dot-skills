---
title: Constrain `infer` with `extends` for Validated Extraction
impact: HIGH
impactDescription: prevents 100% of unsafe `as` casts after type-level parsing; produces narrowed primitives instead of `string`
tags: tlp, infer, conditional-types, template-literals, type-level
---

## Constrain `infer` with `extends` for Validated Extraction

By default, `infer X` captures whatever shape the position allows — usually `string`, `unknown`, or a wide union — and downstream rules then re-narrow with extra conditionals. TypeScript 4.7 added `infer X extends Y`, which both binds the variable *and* asserts a constraint. The resulting type is exactly `Y`, not the wider position. This eliminates entire layers of post-narrowing and turns "parse-then-validate" type-level pipelines into single-step extractions.

**Incorrect (extract, then re-narrow):**

```typescript
type ToNumber<S extends string> =
  S extends `${infer N}` ? N extends `${number}` ? unknown extends N ? never : N : never : never
// Hard to read. The `extends ` ${number} ` ` check happens *after* extraction,
// and the result is still typed as string.

type A = ToNumber<'42'>     // '42' — a string literal, not a number.
type B = ToNumber<'forty'>  // never
```

**Correct (`infer N extends number` constrains and binds in one step):**

```typescript
type ToNumber<S extends string> =
  S extends `${infer N extends number}` ? N : never
// `N` is bound to the parsed number literal type, not its string form.

type A = ToNumber<'42'>     // 42 — actually a number literal type
type B = ToNumber<'forty'>  // never — extends number fails, conditional takes the false branch
type C = ToNumber<'3.14'>   // 3.14
```

Use this for any pattern where the extracted token must be a primitive of a specific kind: `infer N extends number`, `infer K extends keyof T`, `infer S extends 'GET' | 'POST'`. It also works on tuple positions: `infer Args extends readonly unknown[]`.

A worked example — parsing a numeric range:

```typescript
type ParseRange<S extends string> =
  S extends `${infer Lo extends number}..${infer Hi extends number}`
    ? { lo: Lo; hi: Hi }
    : never

type R1 = ParseRange<'1..10'>   // { lo: 1; hi: 10 }
type R2 = ParseRange<'a..z'>    // never — constraints prevent unsafe extraction
```

**When NOT to apply:**
- The constraint position is itself a union with non-literal kinds (`string | number | boolean`) — the result widens, defeating the purpose. Split the rule into a union of conditionals instead.
- Pre-4.7 codebases. The bare `infer X` form will compile but does not narrow.

**Scope delta:**
- Companion to `[[tlp-template-literal-pattern-matching]]`: pattern matching identifies *where* to extract, `infer extends` controls *what shape* the extracted token must take.

Reference: [TypeScript 4.7 Release Notes — `extends` Constraints on `infer` Type Variables](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html#extends-constraints-on-infer-type-variables)
