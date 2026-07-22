---
title: Scope undo to local edits with transaction origins
tags: hist, undomanager, origins, collaboration
---

## Scope undo to local edits with transaction origins

`new Y.UndoManager(type)` reads like local undo, and in a single-user document it is. Its default `trackedOrigins` is `new Set([null])`, and an update applied without an explicit origin also has origin `null` — so remote changes land in the local undo stack. One user pressing the undo shortcut then deletes a colleague's paragraph. The mirror-image failure follows from fixing the first one carelessly: once local writes carry a named origin, the default manager no longer tracks them and undo silently does nothing.

Verified with Yjs 13.6.31: with a default `UndoManager`, applying a remote update through `Y.applyUpdate(doc, update)` and calling `undo()` emptied the document of both the local and the remote text. A transaction tagged `'user-typing'` was not undone by a default manager at all.

**Incorrect (remote edits are indistinguishable from local ones):**

```typescript
Y.applyUpdate(doc, remoteUpdate) // origin null — the local UndoManager will track this
const undoManager = new Y.UndoManager(doc.getText('body'))
```

**Correct (origins name who made the change, and undo tracks only this user):**

```typescript
const LOCAL_ORIGIN = 'local-user'

const undoManager = new Y.UndoManager(doc.getText('body'), {
  trackedOrigins: new Set([LOCAL_ORIGIN]),
})

// Every local edit is tagged...
doc.transact(() => doc.getText('body').insert(0, 'Summary\n'), LOCAL_ORIGIN)

// ...and every remote or storage write carries a different origin.
Y.applyUpdate(doc, remoteUpdate, 'remote')
Y.applyUpdate(doc, storedSnapshot, 'storage')
```

Origins are the general mechanism for answering "where did this change come from", so the same tags drive the network layer — see [`wire-send-updates-not-state`](wire-send-updates-not-state.md), where a handler skips re-broadcasting anything tagged `'remote'`. Providers set their own origins already, which is why an update arriving through `WebsocketProvider` is not caught by a default undo manager but one you apply by hand is.

The transaction is also the unit of undo, which decides how a multi-field change is reverted. Applying a template field by field gives the user one undo step per field and a document nobody authored halfway through; wrapping it makes it one step:

```typescript
doc.transact(() => {
  const brief = doc.getMap('brief')
  brief.set('title', template.title)
  brief.set('owner', template.owner)
  brief.set('status', 'draft')
}, LOCAL_ORIGIN)
```

Reference: [Yjs — UndoManager](https://docs.yjs.dev/api/undo-manager)
