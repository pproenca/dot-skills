---
title: Stabilize renderItem with useCallback
impact: CRITICAL
impactDescription: prevents full list re-render on parent update
tags: list, useCallback, render-item, stability
---

## Stabilize renderItem with useCallback

Defining `renderItem` inline creates a new function on every render, causing FlashList/FlatList to think the renderer changed and re-render all visible items. Extract and memoize the render function.

**Incorrect (inline renderItem recreated every render):**

```typescript
// screens/ContactList.tsx
export function ContactList({ contacts }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <>
      <SearchInput value={searchQuery} onChangeText={setSearchQuery} />
      <FlashList
        data={filteredContacts}
        renderItem={({ item }) => (
          <ContactRow contact={item} />
        )}  // New function on every keystroke = all rows re-render
        estimatedItemSize={60}
      />
    </>
  );
}
```

**Correct (stable renderItem with useCallback):**

```typescript
// screens/ContactList.tsx
export function ContactList({ contacts }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  const renderContact = useCallback(
    ({ item }: { item: Contact }) => <ContactRow contact={item} />,
    []
  );

  return (
    <>
      <SearchInput value={searchQuery} onChangeText={setSearchQuery} />
      <FlashList
        data={filteredContacts}
        renderItem={renderContact}
        estimatedItemSize={60}
      />
    </>
  );
}
```

**Important:** If `renderItem` uses callbacks like `onPress`, include them in the dependency array or use functional updates to avoid stale closures.

Reference: [Optimizing FlatList](https://reactnative.dev/docs/optimizing-flatlist-configuration)
