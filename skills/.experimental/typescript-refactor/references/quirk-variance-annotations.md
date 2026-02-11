---
title: Use Variance Annotations for Generic Interfaces
impact: LOW-MEDIUM
impactDescription: 10-30% faster type-checking on generic-heavy interfaces
tags: quirk, variance, covariance, contravariance, generics
---

## Use Variance Annotations for Generic Interfaces

TypeScript 4.7+ supports `in` and `out` variance annotations on type parameters. These document whether a type parameter is covariant (produced), contravariant (consumed), or invariant (both) — and help the compiler skip expensive structural comparisons.

**Incorrect (no variance annotation, compiler checks structurally):**

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
// Compiler must structurally verify variance on every comparison
```

**Correct (variance annotations document intent, faster checks):**

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
// Compiler uses annotations instead of structural verification
```

**Note:** If you add a method that violates the declared variance, the compiler reports an error — catching design mistakes early.

Reference: [TypeScript 4.7 - Variance Annotations](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html)
