---
title: Wire Tiptap collaboration through its own Yjs binding
tags: ui, tiptap, editor, prosemirror
---

## Wire Tiptap collaboration through its own Yjs binding

Every Tiptap-plus-Yjs example written before v3 installs `y-prosemirror`, so that is what gets added — but Tiptap forked it. `@tiptap/extension-collaboration@3.x` declares a peer dependency on `@tiptap/y-tiptap`, and the fork's README states it "is designed for use with Tiptap and is not intended as a general-purpose Yjs binding for ProseMirror." Installing `y-prosemirror` alongside it produces two bindings competing over one document. The second half of the wiring is initial content: passing `content` to `useEditor` re-inserts the template on every load, because the editor cannot know the document already holds it.

**Incorrect (wrong binding, and content re-seeded on every mount):**

```tsx
import Collaboration from '@tiptap/extension-collaboration'
import { ySyncPlugin } from 'y-prosemirror' // wrong package for Tiptap v3

const editor = useEditor({
  extensions: [StarterKit, Collaboration.configure({ document: doc })],
  content: '<h2>Project brief</h2>', // inserted again on every load
})
```

**Correct (Tiptap's binding, content seeded once behind sync):**

```tsx
const editor = useEditor({
  extensions: [
    StarterKit.configure({ undoRedo: false }), // Collaboration provides its own history
    Collaboration.configure({ document: doc }),
    CollaborationCaret.configure({ provider, user: { name: session.user.name, color } }),
  ],
})

useEffect(() => {
  if (!editor) return
  const onSynced = () => {
    const config = doc.getMap('config')
    if (config.get('initialContentLoaded')) return
    config.set('initialContentLoaded', true)
    editor.commands.setContent('<h2>Project brief</h2>')
  }
  provider.on('sync', onSynced)
  return () => provider.off('sync', onSynced)
}, [editor, doc, provider])
```

Use `'sync'` rather than `'synced'`: y-websocket 3.0.0 emits both, but only `'sync'` appears in the provider's typed event map, so `'synced'` is a type error.

Disabling the starter kit's history matters as much as the binding: two undo stacks over one document undo each other's work, and the collaboration extension's stack is the origin-scoped one described in [`hist-scope-undo-by-origin`](hist-scope-undo-by-origin.md). Tiptap documents a related ordering constraint for the UniqueID extension — "make sure to mount the editor only after the collaboration provider has synced. Incorrect initialization order can cause persistent empty paragraphs in the document" ([Collaboration extension](https://tiptap.dev/docs/editor/extensions/functionality/collaboration)) — and the same ordering is worth applying to any extension that writes to the document on creation.

Reference: [Tiptap — Collaboration setup](https://tiptap.dev/docs/collaboration/getting-started/install)
