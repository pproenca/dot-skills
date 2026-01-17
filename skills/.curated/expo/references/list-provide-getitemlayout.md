---
title: Provide getItemLayout for Fixed-Height FlatList Items
impact: HIGH
impactDescription: eliminates async layout measurement, instant scroll-to-index
tags: list, flatlist, getItemLayout, layout, scrollToIndex
---

## Provide getItemLayout for Fixed-Height FlatList Items

When all list items have the same height, provide `getItemLayout` to skip asynchronous layout measurement. This enables instant `scrollToIndex` and prevents blank areas during fast scrolling.

**Incorrect (async layout measurement):**

```typescript
import { FlatList } from 'react-native'

const ITEM_HEIGHT = 72

function ContactList({ contacts }) {
  const listRef = useRef(null)

  const scrollToContact = (index) => {
    listRef.current?.scrollToIndex({ index, animated: true })
    // May fail or show blank area while measuring
  }

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        <ContactRow contact={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={item => item.id}
    />
  )
}
```

**Correct (pre-calculated layout):**

```typescript
import { FlatList } from 'react-native'

const ITEM_HEIGHT = 72

function ContactList({ contacts }) {
  const listRef = useRef(null)

  const getItemLayout = useCallback((data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  }), [])

  const scrollToContact = (index) => {
    listRef.current?.scrollToIndex({ index, animated: true })
    // Instant scroll, no measurement needed
  }

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        <ContactRow contact={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={item => item.id}
      getItemLayout={getItemLayout}
    />
  )
}
```

**With separators:**

```typescript
const ITEM_HEIGHT = 72
const SEPARATOR_HEIGHT = 1

const getItemLayout = (data, index) => ({
  length: ITEM_HEIGHT,
  offset: (ITEM_HEIGHT + SEPARATOR_HEIGHT) * index,
  index,
})
```

**Note:** Only use `getItemLayout` when ALL items have the exact same height. For variable heights, use FlashList with `estimatedItemSize` instead.

Reference: [React Native FlatList getItemLayout](https://reactnative.dev/docs/flatlist#getitemlayout)
