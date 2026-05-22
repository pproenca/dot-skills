---
title: Convert Frozen-Object Enums to const Objects or Unions
impact: MEDIUM
impactDescription: preserves literal values for narrowing
tags: idiom, const-assertion, unions, enums
---

## Convert Frozen-Object Enums to const Objects or Unions

JavaScript "enums" built with `Object.freeze({ ... })` lose their literal types when migrated naively — each value widens to `string` or `number`, so it can no longer drive narrowing or exhaustiveness checks. An `as const` object preserves the exact literal values, and a derived union type gives you a precise set to switch on.

**Incorrect (frozen object — values widen to string):**

```typescript
// Status.Paid has type string, so it cannot drive an exhaustive switch.
const Status = Object.freeze({
  Pending: "pending",
  Paid: "paid",
  Refunded: "refunded",
})
```

**Correct (as const preserves literals; derive a union):**

```typescript
const Status = {
  Pending: "pending",
  Paid: "paid",
  Refunded: "refunded",
} as const

// A value and a type may share a name; this is the idiomatic enum replacement.
type Status = (typeof Status)[keyof typeof Status]
// "pending" | "paid" | "refunded" — usable in exhaustive narrowing
```

This also avoids the runtime and bundling quirks of TypeScript's `enum`
keyword, which emits a lookup object and is not erased.

Reference: [TypeScript Handbook: const assertions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)
