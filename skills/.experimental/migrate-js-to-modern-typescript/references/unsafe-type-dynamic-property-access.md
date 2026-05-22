---
title: Type Dynamic Property Access with Records or Index Signatures
impact: MEDIUM-HIGH
impactDescription: enables typed map-style access
tags: unsafe, records, index-signatures, dynamic-access
---

## Type Dynamic Property Access with Records or Index Signatures

JavaScript routinely uses a plain object as a map (`obj[key] = value`), which under `noImplicitAny` becomes an implicit-any or element-access error. Reaching for `any` to silence it throws away the value type. A `Record<K, V>` or index signature types the dynamic access while keeping the value's type checked.

**Incorrect (object-as-map triggers any and element errors):**

```typescript
// counts is implicitly any; every read and write is unchecked.
const counts = {}
for (const event of events) {
  counts[event.type] = (counts[event.type] || 0) + 1
}
```

**Correct (typed as a Record):**

```typescript
const counts: Record<string, number> = {}
for (const event of events) {
  counts[event.type] = (counts[event.type] ?? 0) + 1
}
```

**Alternative (Map for genuinely unbounded dynamic keys):**

```typescript
const counts = new Map<string, number>()
for (const event of events) {
  counts.set(event.type, (counts.get(event.type) ?? 0) + 1)
}
```

Reference: [TypeScript Handbook: Index Signatures](https://www.typescriptlang.org/docs/handbook/2/objects.html#index-signatures)
