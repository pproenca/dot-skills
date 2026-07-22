---
title: Compact stored updates by loading them into a document
tags: wire, persistence, compaction, storage
---

## Compact stored updates by loading them into a document

Appending every update as a row is the right storage shape — updates are commutative, associative and idempotent, so order and duplicates do not matter. The compaction step is where the wrong default appears: `Y.mergeUpdates` looks like the way to shrink the table, and it does shrink it, but only by re-encoding. It cannot reclaim space held by deleted content, because tombstones are only collected when a real document garbage-collects them. The Yjs documentation is explicit: "this feature only merges document updates and doesn't garbage-collect deleted content. You still need to load the document to a `Y.Doc` to reduce the document size." Skipping the round-trip leaves a brief that was written and heavily edited carrying the weight of every deletion forever.

Measured on 400 append operations: 25,664 bytes across 400 rows, 21,642 after `Y.mergeUpdates`, 18,019 after a document round-trip.

**Incorrect (re-encodes but keeps deleted content):**

```typescript
const rows = await loadBriefUpdates(briefId)
await replaceBriefUpdates(briefId, Y.mergeUpdates(rows))
```

**Correct (round-trip through a document so deletions are collected):**

```typescript
export async function compactBrief(briefId: string) {
  const rows = await loadBriefUpdates(briefId)
  if (rows.length < 100) return // compaction is not free — only run it when rows accumulate

  const doc = new Y.Doc()
  Y.applyUpdate(doc, Y.mergeUpdates(rows), 'compaction')
  const compacted = Y.encodeStateAsUpdate(doc)
  doc.destroy()

  await replaceBriefUpdates(briefId, compacted)
}
```

**When NOT to use this pattern:** a document created with `gc: false` for snapshot history keeps deleted content deliberately, so the round-trip will not shrink it — see [`hist-snapshots-require-gc-disabled`](hist-snapshots-require-gc-disabled.md).

Reference: [Yjs — Document Updates](https://docs.yjs.dev/api/document-updates)
