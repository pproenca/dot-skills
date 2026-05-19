---
title: Use Tail-Recursion Accumulator Pattern to Bypass the 50-Step Limit
impact: HIGH
impactDescription: prevents "Type instantiation is excessively deep" errors; 20× larger recursion ceiling (50 to 1000 steps)
tags: tlp, recursion, accumulator, tail-call, type-level
---

## Use Tail-Recursion Accumulator Pattern to Bypass the 50-Step Limit

TypeScript's type checker bounds recursive conditional type instantiations at roughly 50 steps. Naïve `head:rest` recursion blows that limit on any non-trivial input. Since TypeScript 4.5, the checker detects tail-recursive conditional types and processes them iteratively, raising the limit to ~1000. The trick is to thread an *accumulator* through the recursion so each step's result is part of the next call's input, never wrapped in another type constructor on return. Once a rule has this shape, it scales to long tuples, long strings, and deep paths.

**Incorrect (non-tail recursion — limit at ~50 elements):**

```typescript
type Length<T extends readonly unknown[]> =
  T extends readonly [unknown, ...infer Rest] ? Length<Rest> extends infer R extends number ? [...Array<R>, unknown]['length'] : never : 0
// Trying to compute length via incrementing — the wrapper `[...Array<R>, unknown]['length']` happens on return,
// which prevents tail-call detection. Fails on tuples longer than ~50.

type T = Length<[1,2,3,/* … 60 more … */]>  // Type instantiation is excessively deep and possibly infinite.
```

**Correct (accumulator threaded through the recursion):**

```typescript
type Length<T extends readonly unknown[], Acc extends unknown[] = []> =
  T extends readonly [unknown, ...infer Rest]
    ? Length<Rest, [unknown, ...Acc]>
    : Acc['length']
// The recursive call is the *entire* body of the true branch — no wrapping type
// constructor between the recursion and the result. TypeScript can iterate.

type N = Length<[1,2,3,4,5,6,7,8,9,10,/* 200 more */]>  // OK — resolves.
```

Two patterns make a recursive type non-tail and break the optimisation:
1. Wrapping the recursive call in another type constructor: `[X, ...Foo<Rest>]` — the spread happens on return.
2. Using the recursive result in a conditional: `Foo<Rest> extends infer R ? ... : ...` — the conditional re-enters the type-checker.

Fix both by accumulating during the descent, returning the accumulator at the base case.

**When NOT to apply:**
- Recursion that genuinely needs to combine results from both branches (binary tree walks, where you need `Left | Right`) — accumulators don't help.
- Short inputs where the limit will never bite — the accumulator adds noise for no benefit; keep it simple.

**Scope delta:**
- `typescript-refactor`'s `compile-avoid-deep-recursion` says "limit recursion depth." This rule explains *how* to raise that limit when you actually need depth: the structural transformation must be rewritten in tail-recursive form, not just shortened.

Reference: [TypeScript 4.5 Release Notes — Tail-Recursion Elimination on Conditional Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-5.html#tail-recursion-elimination-on-conditional-types)
