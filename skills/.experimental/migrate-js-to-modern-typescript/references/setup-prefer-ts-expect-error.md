---
title: Prefer ts-expect-error over ts-ignore for Suppressions
impact: HIGH
impactDescription: eliminates silently stale suppressions
tags: setup, suppressions, ts-expect-error, cleanup
---

## Prefer ts-expect-error over ts-ignore for Suppressions

A migration accumulates many temporary suppressions while imports are still untyped. `@ts-expect-error` itself becomes an error once the line below stops erroring, so fixing the underlying type forces you to delete the suppression. `@ts-ignore` never reports anything, so it lingers after the original error is gone and silently hides a different error introduced later.

**Incorrect (@ts-ignore — rots after the underlying error is fixed):**

```typescript
// @ts-ignore — addDays is untyped legacy code
const dueDate = addDays(invoice.issuedAt, 30)
// After addDays gets types, this ignore is pointless but stays, and will
// mask a genuine error introduced on this line months from now.
```

**Correct (@ts-expect-error — self-removes once the type lands):**

```typescript
// @ts-expect-error addDays is untyped until the dates module migrates
const dueDate = addDays(invoice.issuedAt, 30)
// Once addDays is typed, this line stops erroring, so @ts-expect-error
// itself errors — TypeScript tells you to delete the now-needless comment.
```

Reference: [TypeScript 3.9 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-9.html)
