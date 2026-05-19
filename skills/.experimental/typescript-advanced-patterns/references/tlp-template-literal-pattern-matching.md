---
title: Match Structured Strings with `infer` in Template Literals
impact: HIGH
impactDescription: enables URL, CSS, format-string parsing at the type level; eliminates runtime regex for shape extraction
tags: tlp, template-literals, infer, parsing, type-level
---

## Match Structured Strings with `infer` in Template Literals

Template literals don't just *interpolate* — they *parse*. Combined with `infer`, the compiler can decompose a structured string into named pieces: extract a URL's protocol, a route's params, a SQL fragment's table name, a CSS shorthand's component values. This rule covers the decomposition patterns themselves (single match, repeated match, optional segment, greedy vs lazy capture) so they can be composed into the bigger parsers seen in `dsl-route-param-inference` and `dsl-type-safe-object-paths`.

**Incorrect (regex at runtime — type system blind to structure):**

```typescript
function parseUrl(url: string): { protocol: string; host: string; path: string } {
  const m = /^(\w+):\/\/([^/]+)(\/.*)?$/.exec(url)
  return { protocol: m?.[1] ?? '', host: m?.[2] ?? '', path: m?.[3] ?? '' }
}

const u = parseUrl('https://api.example.com/v1/users')
// u.protocol: string — even though the input was a literal, the type system saw `string`.
```

**Correct (`infer` patterns extract typed pieces from literal inputs):**

```typescript
// Single match (eager, leftmost)
type Protocol<S extends string> =
  S extends `${infer P}://${string}` ? P : never

type P1 = Protocol<'https://api.example.com'>  // 'https'
type P2 = Protocol<'ftp://files.example.com'>  // 'ftp'

// Optional segment (use a union in the pattern)
type ParseUrl<S extends string> =
  S extends `${infer Proto}://${infer Rest}`
    ? Rest extends `${infer Host}/${infer Path}`
      ? { protocol: Proto; host: Host; path: `/${Path}` }
      : { protocol: Proto; host: Rest; path: '/' }
    : never

type U = ParseUrl<'https://api.example.com/v1/users'>
//    ^? { protocol: 'https'; host: 'api.example.com'; path: '/v1/users' }

// Repeated match (recurse to collect all occurrences)
type AllParams<S extends string> =
  S extends `${string}:${infer P}/${infer Rest}` ? [P, ...AllParams<`/${Rest}`>]
  : S extends `${string}:${infer P}` ? [P]
  : []

type R = AllParams<'/users/:userId/posts/:postId/comments/:commentId'>
//    ^? ['userId', 'postId', 'commentId']
```

Eager vs lazy: template literals match greedily at the *first* delimiter from the left. To match at the *last* delimiter, switch direction with `${string}` as the leading wildcard and capture the right side: `` `${string}/${infer Last}` ``.

**When NOT to apply:**
- Inputs that aren't literal types at compile time. If the value is `string` and not a specific literal, no inference happens.
- Parsers requiring backtracking or look-ahead (full URL spec, CSS calc(), regex grammar) — template literals can't backtrack. Either simplify the grammar or run the parse at runtime and validate with a schema.

**Scope delta:**
- Provides the *pattern primitives* used by `[[dsl-route-param-inference]]`, `[[dsl-type-safe-object-paths]]`, and `[[tlp-type-level-string-algorithms]]`. Think of it as the lexer; the other rules are parsers built on top.

Reference: [TypeScript 4.1 Release Notes — Inference with Template Literal Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-1.html#template-literal-types)
