---
title: Seed initial content once and record that it happened
tags: model, initialization, duplication, sync
---

## Seed initial content once and record that it happened

Seeding reads as a local question — "is this document empty? then insert the template" — and every client answers it independently before sync completes. Each one sees an empty document, each one inserts, and Yjs faithfully merges all of them. The template appears two or three times. The emptiness check is not a guard, because a document that has not yet synced is indistinguishable from a document that is genuinely new.

Verified with Yjs 13.6.31: two clients each running "if empty, insert" converged to `"Meeting notes\nMeeting notes\n"`.

**Incorrect (an emptiness check every client passes):**

```typescript
const body = doc.getText('body')
if (body.length === 0) body.insert(0, 'Meeting notes\n')
```

**Correct (a flag inside the document, checked after sync):**

```typescript
provider.on('sync', (isSynced: boolean) => {
  if (!isSynced) return

  const config = doc.getMap('config')
  if (config.get('seeded')) return

  doc.transact(() => {
    config.set('seeded', true)
    doc.getText('body').insert(0, 'Meeting notes\n')
  })
})
```

The flag lives in the document rather than in component state because it has to survive reloads and be visible to every client. Writing it in the same transaction as the content means a client that seeds concurrently still converges to one flag, and the duplicate insert window shrinks to the sync round-trip rather than the whole session. Tiptap documents the same shape for editors and warns about the failure directly: "you might notice that the initial content is repeatedly added each time the editor loads."

**Alternative (seed on the server):** creating the document server-side when the brief record is created removes the race entirely — clients then only ever load an already-seeded document. Prefer this when a brief is created through an explicit action rather than lazily on first visit.

Reference: [Tiptap — Collaboration setup](https://tiptap.dev/docs/collaboration/getting-started/install)
