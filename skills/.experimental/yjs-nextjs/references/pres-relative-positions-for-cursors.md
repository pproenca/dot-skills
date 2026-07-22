---
title: Express cursor positions relative to document content
tags: pres, cursors, relative-position, selection
---

## Express cursor positions relative to document content

A caret is an integer offset in every editor API, so it gets broadcast as one. An index only means something against the exact document state that produced it: as soon as anyone inserts text earlier in the document, the same number points somewhere else. Remote carets drift, selection highlights land on the wrong words, and the error compounds with every edit above the cursor. Yjs provides relative positions for this — they identify a place in the content itself, so they survive concurrent edits and resolve back to whatever index that place now has.

Verified with Yjs 13.6.31: with the caret at index 6 of `"Hello world"`, a remote client prepending `"Oh! "` left index 6 pointing at `"llo world"`, while the relative position resolved to index 10, still immediately before `"world"`.

**Incorrect (an index broadcast as presence drifts on every remote insert):**

```typescript
provider.awareness.setLocalStateField('cursor', { index: selection.anchor })
```

**Correct (a position anchored to the content):**

```typescript
const body = doc.getText('body')

provider.awareness.setLocalStateField('cursor', {
  anchor: Y.createRelativePositionFromTypeIndex(body, selection.anchor),
  head: Y.createRelativePositionFromTypeIndex(body, selection.head),
})
```

```typescript
// Rendering a collaborator's caret resolves it against the current document.
const position = Y.createAbsolutePositionFromRelativePosition(remote.cursor.anchor, doc)
if (position) renderCaret(position.index, remote.user.colour)
```

Resolution returns `null` when the anchor content has been deleted, which is the honest answer — the place that caret pointed at no longer exists — so render nothing rather than falling back to an index. Relative positions must be encoded to cross the wire (`Y.encodeRelativePosition` / `Y.decodeRelativePosition`) when your awareness transport does not carry structured values. Editor bindings such as `@tiptap/y-tiptap` and `y-codemirror.next` already do all of this; write it by hand only for surfaces they do not cover.

Reference: [Yjs — Relative Positions](https://docs.yjs.dev/api/relative-positions)
