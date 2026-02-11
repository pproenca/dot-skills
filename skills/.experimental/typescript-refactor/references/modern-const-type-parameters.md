---
title: Use Const Type Parameters for Literal Inference
impact: HIGH
impactDescription: eliminates as const at call sites
tags: modern, const-type-parameters, inference, generics
---

## Use Const Type Parameters for Literal Inference

The `const` modifier on type parameters (TS 5.0+) makes the compiler infer literal types by default, removing the need for `as const` at every call site. Use it for functions that need to preserve exact shapes.

**Incorrect (callers must remember as const):**

```typescript
function createRoute<T extends readonly string[]>(methods: T, path: string) {
  return { methods, path }
}

const route = createRoute(["GET", "POST"], "/users")
// route.methods type: string[] — literals lost

const route2 = createRoute(["GET", "POST"] as const, "/users")
// route2.methods type: readonly ["GET", "POST"] — but callers must remember
```

**Correct (const type parameter infers literals):**

```typescript
function createRoute<const T extends readonly string[]>(methods: T, path: string) {
  return { methods, path }
}

const route = createRoute(["GET", "POST"], "/users")
// route.methods type: readonly ["GET", "POST"] — automatic
```

Reference: [TypeScript 5.0 - const Type Parameters](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html)
