---
title: Replace any with unknown at Untrusted Boundaries
impact: HIGH
impactDescription: prevents any from spreading through the codebase
tags: unsafe, unknown, any, boundaries
---

## Replace any with unknown at Untrusted Boundaries

`any` disables every check and propagates silently to everything it touches, so one `any` parameter quietly un-types its whole call chain. `unknown` keeps the value opaque until you narrow it, forcing safe handling at the boundary. Auto-migration scatters `any` across function inputs — converting each to `unknown` is the single change that re-enables type safety downstream.

**Incorrect (any spreads from the boundary outward):**

```typescript
function parseMessage(raw: any): QueueMessage {
  // Every access on raw is unchecked, and the any leaks into the result.
  return { id: raw.id, body: raw.payload.body }
}
```

**Correct (unknown forces narrowing before use):**

```typescript
function parseMessage(raw: unknown): QueueMessage {
  if (typeof raw !== "object" || raw === null || !("id" in raw)) {
    throw new Error("Malformed queue message")
  }
  // raw is now narrowed; validate the remaining fields before returning
  return QueueMessageSchema.parse(raw)
}
```

Reference: [TypeScript Handbook: unknown](https://www.typescriptlang.org/docs/handbook/2/functions.html#unknown)
