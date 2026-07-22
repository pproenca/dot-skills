---
title: Reserve Y.Text for prose that two people type into together
tags: model, ytext, ymap, fields
---

## Reserve Y.Text for prose that two people type into together

`Y.Text` is the shared type for strings, so every string field becomes one — including titles, labels, slugs and select values. Character-level merging is the wrong semantic for a field a user replaces rather than co-edits: two people each clearing the field and typing a new value produce a document containing both values spliced together. Nobody typed that string and no interface can present it as a conflict, because to Yjs it is simply the merged result.

Verified with Yjs 13.6.31: two clients concurrently replacing a `Y.Text` title with `'Q3 Roadmap'` and `'Launch Plan'` converged to `"Q3 RoadmapLaunch Plan"`. The same edits against a `Y.Map` key converged to `"Q3 Roadmap"` on both clients — one writer wins, cleanly.

**Incorrect (single-line field as Y.Text interleaves whole-value replacements):**

```typescript
const title = doc.getText('title')
title.delete(0, title.length)
title.insert(0, 'Q3 Roadmap')
```

**Correct (single-line field as a Y.Map key resolves last-writer-wins):**

```typescript
const brief = doc.getMap('brief')
brief.set('title', 'Q3 Roadmap')
```

The dividing question is whether concurrent edits to this field should merge or one should win. Body copy in an editor merges — that is the whole point of a CRDT, and `Y.Text` (or `Y.XmlFragment` for rich text) is right. A title, a status, an assignee or a tag is replaced wholesale, so last-writer-wins is both the correct semantic and the one users can reason about. Making that choice per field also decides how the input is bound — see [`ui-do-not-drive-inputs-from-the-doc`](ui-do-not-drive-inputs-from-the-doc.md).

Reference: [Yjs — Y.Text](https://docs.yjs.dev/api/shared-types/y.text)
