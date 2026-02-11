---
title: Type Catch Clause Variables as unknown
impact: MEDIUM
impactDescription: prevents unsafe property access on caught errors
tags: error, catch-clause, unknown, type-safety
---

## Type Catch Clause Variables as unknown

Caught values in JavaScript can be anything — not just `Error` instances. TypeScript 4.4+ supports `unknown` in catch clauses (and `useUnknownInCatchVariables` enforces it). Always narrow the caught value before accessing properties.

**Incorrect (assumes caught value is Error):**

```typescript
try {
  await submitOrder(order)
} catch (err) {
  console.error(err.message) // Runtime crash if err is a string or number
  logError(err.stack)        // .stack might not exist
}
```

**Correct (narrow before accessing properties):**

```typescript
try {
  await submitOrder(order)
} catch (err: unknown) {
  if (err instanceof Error) {
    console.error(err.message)
    logError(err.stack)
  } else {
    console.error("Unexpected error:", String(err))
  }
}
```

**Note:** Enable `useUnknownInCatchVariables` in tsconfig (included in `strict` since TS 4.4) to enforce this automatically.

Reference: [TypeScript 4.4 - useUnknownInCatchVariables](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-4.html)
