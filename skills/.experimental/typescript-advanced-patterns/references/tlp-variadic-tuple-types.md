---
title: Use Variadic Tuples for Position-Aware Type Algorithms
impact: HIGH
impactDescription: enables typing of curry, compose, concat, and reverse without combinatorial overload explosion
tags: tlp, variadic-tuples, spread, infer, type-level
---

## Use Variadic Tuples for Position-Aware Type Algorithms

Variadic tuple types (TS 4.0+) let a tuple's middle hold a spread of another tuple — `[...A, ...B]`, `[head, ...rest]`, `[...init, last]`. This is the foundation for typing higher-order combinators where the *position* of arguments matters: curry, compose, partial application, concat, last/init. Before variadics, libraries shipped 7–10 overloaded signatures per arity and hit the type-checker's overload limit at modest arity counts. Variadics replace those with a single generic signature.

**Incorrect (per-arity overloads — doesn't scale beyond ~7 args):**

```typescript
function concat<A>(a: [A]): [A]
function concat<A, B>(a: [A], b: [B]): [A, B]
function concat<A, B, C>(a: [A], b: [B], c: [C]): [A, B, C]
function concat<A, B, C, D>(a: [A], b: [B], c: [C], d: [D]): [A, B, C, D]
// ...repeat to arity N. Breaks at any input the author didn't enumerate.
function concat(...arrs: any[][]): any[] { return arrs.flat() }
```

**Correct (single variadic signature handles any arity):**

```typescript
function concat<T extends readonly unknown[][]>(
  ...arrs: [...T]
): ConcatAll<T> {
  return arrs.flat() as ConcatAll<T>
}

type ConcatAll<T extends readonly unknown[][]> =
  T extends readonly [infer Head extends readonly unknown[], ...infer Tail extends readonly unknown[][]]
    ? [...Head, ...ConcatAll<Tail>]
    : []

const r = concat([1, 2] as const, ['a', 'b'] as const, [true] as const)
//    ^? readonly [1, 2, 'a', 'b', true]
```

Common variadic patterns:

```typescript
// Last element of a tuple
type Last<T extends readonly unknown[]> = T extends readonly [...unknown[], infer L] ? L : never

// Init (all but last)
type Init<T extends readonly unknown[]> = T extends readonly [...infer I, unknown] ? I : never

// Reverse
type Reverse<T extends readonly unknown[], Acc extends unknown[] = []> =
  T extends readonly [infer H, ...infer R] ? Reverse<R, [H, ...Acc]> : Acc

// Curry — signature of `curry(fn)`
type Curry<F> = F extends (...args: infer A) => infer R
  ? A extends [infer First, ...infer Rest]
    ? (a: First) => Rest extends [] ? R : Curry<(...args: Rest) => R>
    : () => R
  : never
```

The `[...infer A]` form preserves both *element types* and *labels* in tuples — labels survive when present.

**When NOT to apply:**
- When the operation doesn't depend on position (set union, dedupe). Use mapped types or plain unions instead — variadics waste type-checker cycles for no expressive gain.
- When you need to track tuple length as a number for arithmetic — the index-into-array trick (`T['length']`) is sufficient; full variadic descent is overkill.

**Scope delta:**
- Variadic tuples are the structural primitive that makes the accumulator pattern in `[[tlp-tail-recursion-accumulator]]` ergonomic. This rule covers the *uses* of variadics; the accumulator rule covers their *recursion behaviour*.

Reference: [TypeScript 4.0 Release Notes — Variadic Tuple Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-0.html#variadic-tuple-types)
