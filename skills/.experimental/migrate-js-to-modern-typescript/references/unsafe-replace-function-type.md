---
title: Replace the Function Type with Specific Call Signatures
impact: MEDIUM
impactDescription: enables call-site argument checking
tags: unsafe, function-type, signatures
---

## Replace the Function Type with Specific Call Signatures

The bare `Function` type accepts any arguments and returns `any`, so every call through it is unchecked — a frequent crutch when migrating callback registries and event maps. A precise `(arg: T) => R` signature restores argument and return checking at every call site, catching wrong arity and wrong types the `Function` type waves through.

**Incorrect (Function type — calls check nothing):**

```typescript
// Each value is `Function`; calling it verifies neither arity nor types.
const handlers: Record<string, Function> = {}

function dispatch(type: string, payload: unknown): void {
  handlers[type](payload) // wrong arity or argument type fails silently
}
```

**Correct (explicit call signature):**

```typescript
type Handler = (payload: unknown) => void
const handlers: Record<string, Handler> = {}

function dispatch(type: string, payload: unknown): void {
  handlers[type]?.(payload) // arity and argument type are now checked
}
```

Reference: [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
