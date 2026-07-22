---
title: Avoid driving text inputs from the document on every change
tags: ui, shadcn, forms, caret
---

## Avoid driving text inputs from the document on every change

The controlled-input idiom says read `value` from state, so a collaborative field gets wired straight to the shared type. That rewrites the input's value on every remote keystroke, and the HTML specification requires the browser to respond by discarding the user's caret: when the assigned value differs from the old one, the browser must "move the text entry cursor position to the end of the text control, unselecting any selected text." A user typing in the middle of a field while someone else edits it is thrown to the end on every incoming update. Yjs ships no binding for plain form controls — the `yjs/y-textarea` repository is empty and has never had a commit — so this is unhandled unless the application handles it.

Most fields do not need character-level merging at all, and for those the fix is to stop treating the field as continuously shared. Commit on blur, and let last-writer-wins settle it, per [`model-ytext-only-for-prose`](model-ytext-only-for-prose.md).

**Incorrect (every remote update resets the caret to the end):**

```tsx
const title = useYSnapshot(brief, () => brief.get('title') as string)

<Input value={title} onChange={(e) => brief.set('title', e.target.value)} />
```

**Correct (local state while focused, document state otherwise):**

```tsx
export function BriefTitle({ brief }: { brief: Y.Map<unknown> }) {
  const shared = useYSnapshot(brief, () => (brief.get('title') as string) ?? '')
  const [draft, setDraft] = useState<string | null>(null)

  return (
    <Input
      value={draft ?? shared}
      onChange={(event) => setDraft(event.target.value)}
      onFocus={() => setDraft(shared)}
      onBlur={() => {
        if (draft !== null && draft !== shared) brief.set('title', draft)
        setDraft(null)
      }}
    />
  )
}
```

The same rule decides how react-hook-form fits: it owns the draft the user is editing, and the document owns what has been committed. Registering a collaborative field directly with `useForm` and resetting the form on every remote update produces the identical caret problem, plus a validation pass on every remote keystroke.

**Alternative (true character-level merging in a plain field):** an input bound to a `Y.Text` needs a real binding that applies diffs and restores `selectionStart` / `selectionEnd` around each remote update. Nothing official exists; the maintained editor bindings do this correctly, so prefer a small editor over a hand-written input binding when the field genuinely needs co-typing.

Reference: [HTML Standard — the input value IDL attribute](https://html.spec.whatwg.org/multipage/input.html#dom-input-value)
