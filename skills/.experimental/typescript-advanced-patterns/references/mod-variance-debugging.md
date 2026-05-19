---
title: Debug Variance Errors with `in` / `out` Annotations
impact: HIGH
impactDescription: prevents 100% of unintended variance inference; moves errors from consumer call sites to declaration sites
tags: mod, variance, in, out, generics, typescript-4-7
---

## Debug Variance Errors with `in` / `out` Annotations

TypeScript infers variance from how a generic parameter is used — read positions are *covariant* (`out`), write positions are *contravariant* (`in`), positions used as both are *invariant*. Inference is usually right, but in complex generic interfaces it sometimes produces a variance the author didn't intend, and the resulting assignability bugs are notoriously hard to diagnose. The TS 4.7 `in` / `out` annotations let the author **state** the intended variance — when inference disagrees, the compiler errors at the declaration instead of producing a confusing error at the consumer.

**Incorrect (variance inferred — wrong direction silently accepted):**

```typescript
// A handler interface — author intends Animal handler to be reusable for Dog handlers (covariant in T).
interface Handler<T> {
  handle(value: T): void
  describe(): string
}

class Animal { name = '' }
class Dog extends Animal { breed = '' }

declare const animalHandler: Handler<Animal>
declare const dogHandler: Handler<Dog>

let target: Handler<Dog> = animalHandler // OK — but is this safe? handle(value: Animal) accepts a Dog. Yes.
let other:  Handler<Animal> = dogHandler  // Also accepted — but handle(value: Dog) called with an Animal will crash.
// The bivariance hole on `handle` method syntax lets both assignments through.
// The error appears at runtime, far from the declaration.
```

**Correct (annotate intended variance — the compiler enforces it):**

```typescript
interface Handler<in T> {            // contravariant: only assignable from supertypes
  handle: (value: T) => void          // property syntax (not method syntax) — see `mod-method-vs-property-bivariance`
  describe(): string
}

let target: Handler<Dog>    = animalHandler  // OK — Handler<Animal> can stand in for Handler<Dog>
let other:  Handler<Animal> = dogHandler     // Error: 'Handler<Dog>' is not assignable to 'Handler<Animal>'.
// The error now appears at the assignment, with a clear message about variance direction.
```

When inference disagrees with the annotation, the *declaration* errors — pointing the author at the inconsistency early:

```typescript
interface Producer<out T> {
  produce(): T
  consume(value: T): void  // both produces AND consumes — actually invariant
}
// Error: Type 'Producer<T>' is not assignable to type 'Producer<T>'.
//   Variance annotations 'out' on type parameter conflict with usage as both source and sink.
// Fix: remove the annotation (let it be invariant), or remove `consume`, or split into two interfaces.
```

**Quick reference**:

| Annotation | Variance | Where the parameter appears | Example |
|------------|---------|----------------------------|---------|
| `in T` | Contravariant | Function parameter positions only | `(value: T) => void` |
| `out T` | Covariant | Return positions only | `() => T` |
| `in out T` | Invariant | Both — explicit declaration | `Box<T>` with get/set |
| *unannotated* | Inferred | Either; compiler decides | most generics |

**When NOT to apply:**
- On generic *functions* — annotations are for `interface`, `type`, and `class` declarations. Function generics don't use them.
- When variance inference is correct and there is no consumer-side confusion. Premature annotation is noise.
- For one-off internal types — the annotation cost exceeds the diagnostic benefit. Reach for it on **public library types** where assignability is part of the contract.

**Scope delta:**
- `typescript-refactor`'s `quirk-variance-annotations` mentions `in`/`out` as syntax. This rule covers the *diagnostic* workflow: when to suspect a variance bug, how to confirm it with annotations, and how to interpret the declaration-site error vs. the consumer-site error.

Reference: [TypeScript 4.7 Release Notes — Optional Variance Annotations](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html#optional-variance-annotations-for-type-parameters)
