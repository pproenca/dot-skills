---
title: Enable noImplicitAny to Surface Every Untyped Value
impact: CRITICAL
impactDescription: eliminates invisible any-debt
tags: strict, noimplicitany, any
---

## Enable noImplicitAny to Surface Every Untyped Value

Auto-migrated JavaScript is full of implicit `any` — untyped parameters, untyped imports, untyped `this`. Without `noImplicitAny` these stay invisible and silently disable type checking wherever they flow. With it, each becomes a tracked compile error, converting hidden, unmeasurable debt into an explicit checklist you can finish.

**Incorrect (implicit any — the whole calculation is unchecked):**

```typescript
// items and rate are implicitly `any`; item.price could be anything.
function applyTax(items, rate) {
  return items.reduce((sum, item) => sum + item.price * rate, 0)
}
```

**Correct (noImplicitAny forces real parameter types):**

```typescript
function applyTax(items: LineItem[], rate: number): number {
  return items.reduce((sum, item) => sum + item.price * rate, 0)
}
```

Reference: [tsconfig: noImplicitAny](https://www.typescriptlang.org/tsconfig/#noImplicitAny)
