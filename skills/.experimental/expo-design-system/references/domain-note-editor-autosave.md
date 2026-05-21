---
title: Persist Treatment-Note Edits Offline-First With Debounce
impact: MEDIUM-HIGH
impactDescription: prevents data loss when the app is suspended mid-note
tags: domain, notes, autosave, offline
---

## Persist Treatment-Note Edits Offline-First With Debounce

A treatment note that only saves on a Save button is lost when a clinician switches apps to check a result and the OS suspends the screen. Debounced autosave writes drafts to a local store within a second and syncs them in the background, so an interruption never costs work.

**Incorrect (save only on an explicit button):**

```typescript
function NoteEditor({ noteId }: { noteId: string }) {
  const [text, setText] = useState('')
  return (
    <>
      <AppTextArea value={text} onChangeText={setText} />
      <AppButton title="Save" onPress={() => saveNote(noteId, text)} />
    </>
  )
}
// If the clinician switches apps before tapping Save, the draft is lost.
```

**Correct (debounced autosave to a local store):**

```typescript
function NoteEditor({ noteId }: { noteId: string }) {
  const [text, setText] = useState(() => noteStore.getDraft(noteId))
  const persist = useMemo(
    () => debounce((value: string) => noteStore.saveDraft(noteId, value), 800),
    [noteId],
  )
  const onChangeText = (value: string) => { setText(value); persist(value) }
  useEffect(() => () => persist.flush(), [persist]) // flush any pending draft on unmount
  return <AppTextArea value={text} onChangeText={onChangeText} />
}
// Drafts land in the local store within 800ms and sync to the server in the background.
```

Reference: [Expo AsyncStorage](https://docs.expo.dev/versions/latest/sdk/async-storage/)
