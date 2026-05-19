---
title: Build Type-Level String Algorithms with Recursive Template Literals
impact: HIGH
impactDescription: enables Split/Join/Replace/CamelCase at the type level; eliminates manual string-shape declarations
tags: tlp, strings, template-literals, recursion, type-level
---

## Build Type-Level String Algorithms with Recursive Template Literals

Template literal types let you pattern-match strings; combined with recursion, they let you *compute* over strings — split on a delimiter, join with a separator, replace substrings, convert cases. This is how route param extractors, path-typed accessors, and codegen-free SDKs are built. The four base algorithms (Split, Join, Replace, Case-convert) are the only ones you need to compose almost everything else.

**Incorrect (manual enumeration — doesn't scale or refactor):**

```typescript
// Trying to support snake_case → camelCase props for a single field
type CamelCase_user_id = 'userId'
type CamelCase_first_name = 'firstName'
type CamelCase_last_login_at = 'lastLoginAt'
// And so on. Adding a new field requires editing this file.
```

**Correct (recursive template-literal algorithms — generic over any input):**

```typescript
// Split: 'a,b,c' → ['a','b','c']
type Split<S extends string, D extends string> =
  S extends `${infer Head}${D}${infer Rest}` ? [Head, ...Split<Rest, D>] : [S]

// Join: ['a','b','c'] with '-' → 'a-b-c'
type Join<T extends readonly string[], D extends string> =
  T extends readonly [infer H extends string, ...infer R extends string[]]
    ? R extends readonly []
      ? H
      : `${H}${D}${Join<R, D>}`
    : ''

// Replace: 'foo_bar_baz', '_', '-' → 'foo-bar-baz'
type Replace<S extends string, From extends string, To extends string> =
  S extends `${infer L}${From}${infer R}` ? `${L}${To}${Replace<R, From, To>}` : S

// CamelCase via Split + Capitalize + Join
type CamelCase<S extends string> =
  Split<S, '_'> extends [infer H extends string, ...infer R extends string[]]
    ? `${H}${Join<{ [K in keyof R]: Capitalize<R[K] & string> }, ''>}`
    : S

type A = Split<'a,b,c', ','>           // ['a','b','c']
type B = Join<['x','y','z'], '/'>      // 'x/y/z'
type C = Replace<'foo_bar_baz', '_', '-'>  // 'foo-bar-baz'
type D = CamelCase<'last_login_at'>    // 'lastLoginAt'
```

These four primitives compose into snake_case ↔ camelCase keys, URL-segment parsers, glob-pattern matchers, and SQL-column transformers. Built-in helpers `Uppercase`, `Lowercase`, `Capitalize`, `Uncapitalize` cover case operations on single segments.

**When NOT to apply:**
- Inputs with unbounded variation (user-typed paths, dynamic config values) — the input is `string`, not a literal, and template-literal pattern matching can't run.
- Very long inputs (hundreds of characters) — split recursion still costs steps. Use the accumulator pattern (`[[tlp-tail-recursion-accumulator]]`) for inputs longer than ~50 segments.
- When the transformation is genuinely runtime-only — don't reify a string algorithm at the type level just because you can. Reach for it only when downstream types must follow the transformation.

**Scope delta:**
- `.curated/typescript`'s `advanced-template-literal-types` introduces template literals at the surface level. This rule covers the *recursive composition* layer — using template literals as control flow, not just as string interpolation.

Reference: [TypeScript 4.1 Release Notes — Template Literal Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-1.html#template-literal-types)
