---
title: Type Object Path Access with Dot-Notation Inference
impact: CRITICAL
impactDescription: prevents 100% of broken dot-paths at compile time; enables full autocomplete on nested objects
tags: dsl, paths, template-literals, recursive-types, library-design
---

## Type Object Path Access with Dot-Notation Inference

Helpers that take a string path (`get(user, 'address.city')`) are common in form libraries, validators, and i18n systems. Without type-level support, the path is a `string` and the return is `any` — a single typo silently breaks the contract. A path-aware return type uses recursive template literals to enumerate valid paths and walk them to compute the result type, so refactoring a field rename surfaces every stale path at compile time.

**Incorrect (string path, any return):**

```typescript
function get(obj: any, path: string): any {
  return path.split('.').reduce((acc, key) => acc?.[key], obj)
}

const user = { profile: { firstName: 'Ada', address: { city: 'Lovelace' } } }

get(user, 'profile.firstName')    // any
get(user, 'profile.firstname')    // any — typo accepted, returns undefined silently
get(user, 'profile.address.zip')  // any — non-existent key accepted
```

**Correct (paths and return type both inferred):**

```typescript
type Path<T> = T extends object
  ? { [K in keyof T & string]: T[K] extends object ? `${K}` | `${K}.${Path<T[K]>}` : `${K}` }[keyof T & string]
  : never

type PathValue<T, P extends string> =
  P extends `${infer K}.${infer Rest}`
    ? K extends keyof T ? PathValue<T[K], Rest> : never
    : P extends keyof T ? T[P] : never

function get<T, P extends Path<T>>(obj: T, path: P): PathValue<T, P> {
  return (path as string).split('.').reduce<any>((acc, key) => acc?.[key], obj)
}

const user = { profile: { firstName: 'Ada', address: { city: 'Lovelace' } } }

get(user, 'profile.firstName')    // string
get(user, 'profile.address.city') // string
get(user, 'profile.firstname')    // Error: not a valid path
get(user, 'profile.address.zip')  // Error: not a valid path
```

The same `PathValue` machinery powers typed `set`, `pick`, and form-field selectors. Autocomplete now offers every legal path as you type.

**When NOT to apply:**
- Objects with index signatures or unbounded depth (e.g. trees, recursive AST nodes) — `Path<T>` will not terminate or will explode at depth.
- Performance-sensitive type-checking in large codebases: deeply nested objects with hundreds of keys can slow the type-checker noticeably. Cap depth with a counter parameter or accept `string` at the public boundary and refine internally.
- Bracket-notation access (`'items[0].name'`) — needs a different parser; this rule covers dot paths only.

**Scope delta:**
- Combines `[[tlp-recursive-conditional-types]]` (walking the path) with `[[tlp-template-literal-pattern-matching]]` (splitting `K.Rest`).

Reference: [TypeScript 4.1 Release Notes — Template Literal Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-1.html#template-literal-types)
