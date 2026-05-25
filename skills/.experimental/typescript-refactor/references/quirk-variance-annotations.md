---
title: Use Variance Annotations to Document Generic Intent
impact: LOW-MEDIUM
impactDescription: documents and enforces intended variance on type parameters
tags: quirk, variance, covariance, contravariance, generics
---

## Use Variance Annotations to Document Generic Intent

TypeScript 4.7+ supports `in` and `out` variance annotations on type parameters. Their value is **documentation and correctness**, not speed: they state whether a parameter is covariant (produced, `out`), contravariant (consumed, `in`), or invariant, and the compiler errors if a later edit violates the declared variance. Do not add them for performance — the official guidance is that they help only "in extraordinarily complex types" and only after profiling proves a bottleneck.

**Without annotation (variance is inferred, intent undocumented):**

```typescript
interface Producer<T> {
  produce(): T
}

interface Consumer<T> {
  consume(item: T): void
}

interface Transformer<TInput, TOutput> {
  transform(input: TInput): TOutput
}
// Variance is inferred; a future edit could change it unnoticed
```

**With annotation (intent documented and enforced):**

```typescript
interface Producer<out T> {
  produce(): T
}

interface Consumer<in T> {
  consume(item: T): void
}

interface Transformer<in TInput, out TOutput> {
  transform(input: TInput): TOutput
}
// A method that violates `in`/`out` now fails to compile
```

**When NOT to use:** Most generic interfaces — TypeScript infers variance correctly and annotations add noise. Reach for them only on widely-shared library interfaces where the intended variance is a contract, or after profiling identifies a genuinely expensive type.

Reference: [TypeScript 4.7 - Variance Annotations](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html)
