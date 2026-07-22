---
title: Disable garbage collection on documents you snapshot
tags: hist, snapshots, version-history, garbage-collection
---

## Disable garbage collection on documents you snapshot

Version history gets built with `Y.snapshot()` against the document already in hand, and the failure arrives late — snapshots are captured fine, and only restoring one throws. Yjs garbage-collects deleted content by default, so the material a snapshot refers to is gone by the time you ask for it. The decision is made when the document is constructed, which means it cannot be corrected after the fact: documents that ran with collection enabled cannot have their history recovered.

Verified with Yjs 13.6.31: `Y.createDocFromSnapshot` on a default document threw ``Garbage-collection must be disabled in `originDoc`!``. The same sequence on a document created with `gc: false` restored the pre-deletion text.

**Incorrect (snapshots captured, restore throws):**

```typescript
const doc = new Y.Doc()
const version = Y.snapshot(doc)
// ...later
Y.createDocFromSnapshot(doc, version) // Error: Garbage-collection must be disabled in `originDoc`!
```

**Correct (decided at construction, on both the client and the server that stores it):**

```typescript
const doc = new Y.Doc({ gc: false })

// Capture a named version whenever a brief is published.
const version = Y.snapshot(doc)
await saveBriefVersion(briefId, Y.encodeSnapshot(version))

// Restoring reads the document as it existed at that point.
const restored = Y.createDocFromSnapshot(doc, Y.decodeSnapshot(await loadBriefVersion(versionId)))
```

The cost is real and permanent: a document that never collects tombstones keeps every deleted character for the life of the document, and it will not shrink under compaction — see [`wire-compaction-needs-a-doc-roundtrip`](wire-compaction-needs-a-doc-roundtrip.md). Take it only where version history is a product requirement.

**Alternative (history without disabling collection):** storing periodic full updates as separate rows gives restorable versions at coarser granularity while letting the live document collect normally. Prefer it when users need "restore yesterday's draft" rather than character-level attribution.

Reference: [Yjs — Document API](https://docs.yjs.dev/api/y.doc)
