---
title: Store structured values as nested shared types
tags: model, ymap, conflict-resolution, data-loss
---

## Store structured values as nested shared types

A `Y.Map` accepts a plain JavaScript object, and TypeScript is perfectly happy with it, so grouped fields get stored as one object per key. Yjs then treats that object as a single opaque value: concurrent writes resolve last-writer-wins over the whole thing, not per field. Two people editing *different* fields of the same record silently lose one of the edits — the document converges, no conflict is reported, and the loss only shows up when someone notices their change reverted.

Verified with Yjs 13.6.31: with `{ title, owner }` stored as a plain object, one client editing `title` while another edits `owner` converged to exactly one of the two writes — which one depends on `clientID`, which is random per document, so the loss is unpredictable as well as silent. With a nested `Y.Map` the same edits deterministically converged to `{"title":"Q3 Roadmap","owner":"ben"}`, keeping both.

**Incorrect (whole-object last-writer-wins discards concurrent field edits):**

```typescript
brief.set('meta', { title: 'Roadmap', owner: 'ana' })
brief.set('meta', { ...brief.get('meta'), title: 'Q3 Roadmap' })
```

**Correct (each field merges independently):**

```typescript
const meta = new Y.Map<string>()
brief.set('meta', meta)
meta.set('title', 'Roadmap')
meta.set('owner', 'ana')

// A concurrent edit to `owner` on another client survives this one.
brief.get('meta').set('title', 'Q3 Roadmap')
```

The principle generalizes past maps: any value you hand Yjs as a plain JavaScript value becomes a single conflict unit. Model a structure as nested shared types down to the level at which you want concurrent edits to merge, and stop there — fields that genuinely change as a unit, such as an RGB colour or a coordinate pair, are correct as plain objects precisely because a half-applied merge would be meaningless.

Reference: [Yjs — Shared Types](https://docs.yjs.dev/getting-started/working-with-shared-types)
