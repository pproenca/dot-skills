---
title: Convert Dependency Leaves Before Their Dependents
impact: CRITICAL
impactDescription: prevents re-typing modules twice
tags: setup, dependency-graph, ordering, bottom-up
---

## Convert Dependency Leaves Before Their Dependents

A module's types are only as good as the types of what it imports. Migrate leaf modules (those with no internal imports) first so their dependents inherit real types the moment they convert. Going top-down means the entry point is typed against `any` imports, and every fix has to be redone once the leaves are finally typed.

**Incorrect (top-down — dependent typed against untyped imports):**

```typescript
// Entry point migrated first, while ./money is still untyped JavaScript.
import { formatPrice } from "./money.js" // formatPrice resolves to `any`

export function renderReceipt(totalCents: number): string {
  // formatPrice returns `any`, so .padStart is unchecked — bugs hide here
  return formatPrice(totalCents).padStart(12)
}
```

**Correct (leaf first — dependent inherits a real signature):**

```typescript
// money.ts migrated first, exporting a precise signature.
export function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`
}

// renderReceipt.ts now imports a typed formatPrice; .padStart is checked.
import { formatPrice } from "./money.js"

export function renderReceipt(totalCents: number): string {
  return formatPrice(totalCents).padStart(12)
}
```

Build the import graph (`madge`, `dependency-cruiser`, or `tsc --listFiles`)
and migrate from the leaves inward.

Reference: [Migrating from JavaScript](https://www.typescriptlang.org/docs/handbook/migrating-from-javascript.html)
