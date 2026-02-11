---
title: Use NoInfer to Control Type Parameter Inference
impact: MEDIUM-HIGH
impactDescription: prevents incorrect inference from secondary parameters
tags: modern, noinfer, generics, inference-control
---

## Use NoInfer to Control Type Parameter Inference

`NoInfer<T>` (TS 5.4+) marks a type parameter position as non-inferring. Use it when a generic function has multiple parameters and you want inference to come from one specific parameter, not all of them.

**Incorrect (default infers from all positions, widening the type):**

```typescript
function createSignal<T>(initial: T, fallback: T): T {
  return initial ?? fallback
}

const signal = createSignal("active", "unknown")
// T inferred as "active" | "unknown" — but "unknown" should not widen T
```

**Correct (NoInfer prevents inference from fallback):**

```typescript
function createSignal<T>(initial: T, fallback: NoInfer<T>): T {
  return initial ?? fallback
}

const signal = createSignal("active", "unknown")
// T inferred as "active" — fallback must be assignable to "active"
// Compile error: "unknown" not assignable to "active"
```

Reference: [TypeScript 5.4 - NoInfer](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-4.html)
