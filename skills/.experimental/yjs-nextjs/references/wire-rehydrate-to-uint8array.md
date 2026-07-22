---
title: Rehydrate updates into a Uint8Array before applying
tags: wire, serialization, applyupdate, silent-failure
---

## Rehydrate updates into a Uint8Array before applying

`Y.applyUpdate` accepts a plain array of numbers without complaining and applies nothing at all. A `Uint8Array` that crosses any JSON boundary — a route handler, `JSON.parse`, a tRPC procedure without a transformer — arrives as `number[]`, so passing it straight through produces an empty document, no exception, and no failed request. The symptom reaches the user as "my document is blank," several layers away from the cause. Node `Buffer` works correctly, because it is a `Uint8Array` subclass — which is why a Postgres `bytea` read behaves while a JSON round-trip does not.

**Incorrect (silently applies nothing):**

```typescript
const { update } = await fetch(`/api/briefs/${briefId}/state`).then((r) => r.json())
Y.applyUpdate(doc, update) // update is number[] — no error, doc stays empty
```

**Correct (typed array reconstructed at the boundary):**

```typescript
const { update } = await fetch(`/api/briefs/${briefId}/state`).then((r) => r.json())
Y.applyUpdate(doc, new Uint8Array(update), 'storage')
```

Because the failure is silent, assert the type at the boundary rather than relying on review to catch it:

```typescript
export function applyBriefUpdate(doc: Y.Doc, update: unknown, origin: string) {
  if (!(update instanceof Uint8Array)) {
    throw new TypeError(`Expected a Uint8Array update, received ${typeof update}`)
  }
  Y.applyUpdate(doc, update, origin)
}
```

Reference: [Yjs — Document Updates](https://docs.yjs.dev/api/document-updates)
