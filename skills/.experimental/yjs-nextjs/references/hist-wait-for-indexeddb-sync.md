---
title: Wait for local persistence before reading or seeding
tags: hist, indexeddb, offline, initialization
---

## Wait for local persistence before reading or seeding

`new IndexeddbPersistence(name, doc)` returns synchronously, so the document appears ready on the next line — but loading stored updates is asynchronous, and until it finishes the document is empty. Code that reads it immediately renders an empty editor that fills in a moment later, and code that seeds it inserts a second copy of the template over content that was already on disk. The check that would catch this does not exist: the provider's `synced` event "is also fired when no content is available yet," so an empty document is indistinguishable from an unloaded one by inspection.

**Incorrect (reads and seeds before storage has loaded):**

```typescript
const persistence = new IndexeddbPersistence(`brief:${briefId}`, doc)
const body = doc.getText('body')
if (body.length === 0) body.insert(0, 'Meeting notes\n') // duplicates stored content
```

**Correct (gate on the load completing):**

```typescript
const persistence = new IndexeddbPersistence(`brief:${briefId}`, doc)

await persistence.whenSynced // resolves once stored updates have been applied
setLocalContentReady(true)
```

In React the same gate is a piece of state, so the editor renders a skeleton rather than an empty document:

```tsx
useEffect(() => {
  const persistence = new IndexeddbPersistence(`brief:${briefId}`, doc)
  let cancelled = false
  persistence.whenSynced.then(() => { if (!cancelled) setLoadedFromCache(true) })

  return () => { cancelled = true; void persistence.destroy() }
}, [briefId, doc])
```

Local persistence resolving is not the same event as the network provider syncing, and seeding belongs behind the network one — see [`model-seed-the-document-once`](model-seed-the-document-once.md). Reading local storage first is still worth it: it is what lets a returning user see their brief before the socket connects, and what lets edits made offline survive.

Reference: [Yjs — y-indexeddb](https://docs.yjs.dev/ecosystem/database-provider/y-indexeddb)
