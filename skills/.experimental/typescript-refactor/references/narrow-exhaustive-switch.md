---
title: Enforce Exhaustive Switch with never
impact: CRITICAL
impactDescription: prevents silent fallthrough when union members expand
tags: narrow, exhaustive-switch, never, discriminated-unions
---

## Enforce Exhaustive Switch with never

When switching on a discriminated union, assign the default case to `never`. If a new member is added to the union but the switch is not updated, the compiler reports an error immediately — no silent fallthrough.

**Incorrect (default swallows new variants silently):**

```typescript
type PaymentMethod = "card" | "bank" | "crypto"

function processFee(method: PaymentMethod): number {
  switch (method) {
    case "card": return 0.029
    case "bank": return 0.005
    default: return 0 // "crypto" silently returns 0, new methods too
  }
}
```

**Correct (never catches unhandled variants):**

```typescript
type PaymentMethod = "card" | "bank" | "crypto"

function assertNever(value: never): never {
  throw new Error(`Unhandled value: ${value}`)
}

function processFee(method: PaymentMethod): number {
  switch (method) {
    case "card": return 0.029
    case "bank": return 0.005
    case "crypto": return 0.015
    default: return assertNever(method) // Compile error if a case is missing
  }
}
```

Reference: [TypeScript Handbook - Exhaustiveness Checking](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
