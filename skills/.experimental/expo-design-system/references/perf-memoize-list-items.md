---
title: Memoize List Item Components and Callbacks
impact: HIGH
impactDescription: prevents re-rendering every visible row on parent updates
tags: perf, memo, lists, callbacks
---

## Memoize List Item Components and Callbacks

An inline `renderItem` that creates a new `onPress` closure per row hands every row a fresh prop on each parent render, so any unrelated state change re-renders all visible rows. Memoizing the row component and stabilizing its handler with `useCallback` lets unchanged rows skip rendering entirely.

**Incorrect (inline renderItem with a new closure per row):**

```typescript
<FlashList
  data={notes}
  renderItem={({ item }) => (
    <NoteRow note={item} onPress={() => openNote(item.id)} /> // new closure per row, per render
  )}
/>
// Any parent state change re-creates every row's onPress and re-renders visible rows.
```

**Correct (memoized row plus a stable handler):**

```typescript
const NoteRow = memo(({ note, onPress }: NoteRowProps) => (
  <Pressable onPress={() => onPress(note.id)}><AppText>{note.title}</AppText></Pressable>
))

function NotesList({ notes }: { notes: Note[] }) {
  const openNote = useCallback((id: string) => router.push(`/notes/${id}`), [])
  return (
    <FlashList data={notes} keyExtractor={(item) => item.id}
      renderItem={({ item }) => <NoteRow note={item} onPress={openNote} />} />
  )
}
// memo skips rows with unchanged props; useCallback keeps onPress stable across renders.
```

Reference: [Reanimated performance](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
