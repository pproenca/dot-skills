---
title: Type Caught Errors as unknown, Not any
impact: HIGH
impactDescription: prevents unsafe error property access
tags: strict, useunknownincatchvariables, error-handling
---

## Type Caught Errors as unknown, Not any

JavaScript code assumes `catch (e)` hands back an `Error` and reads `e.message`, but anything can be thrown — strings, `undefined`, rejected non-Error values. `useUnknownInCatchVariables` (on under `strict`) types the caught value as `unknown`, forcing you to narrow it before access so a thrown string cannot crash the error handler itself.

**Incorrect (assumes Error shape):**

```typescript
try {
  await chargeCard(order)
} catch (e: any) {
  logger.error(e.message) // throws again when a string or null was thrown
}
```

**Correct (narrow unknown before use):**

```typescript
try {
  await chargeCard(order)
} catch (e: unknown) {
  const message = e instanceof Error ? e.message : String(e)
  logger.error(message)
}
```

Reference: [tsconfig: useUnknownInCatchVariables](https://www.typescriptlang.org/tsconfig/#useUnknownInCatchVariables)
