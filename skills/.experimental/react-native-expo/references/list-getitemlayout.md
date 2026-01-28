---
title: Implement getItemLayout for Fixed-Height Items
impact: CRITICAL
impactDescription: eliminates measurement overhead, instant scroll-to
tags: list, flatlist, getItemLayout, virtualization, scroll
---

## Implement getItemLayout for Fixed-Height Items

When list items have consistent heights, `getItemLayout` lets FlatList calculate positions without measuring each item.

**Incorrect (FlatList measures every item):**

```tsx
function ContactList({ contacts }) {
  return (
    <FlatList
      data={contacts}
      renderItem={({ item }) => <ContactRow contact={item} />}
      keyExtractor={item => item.id}
    />
  )
}
// FlatList measures each item as it renders
// scrollToIndex is slow or inaccurate
```

**Correct (pre-calculated layout):**

```tsx
const ITEM_HEIGHT = 72  // Fixed row height
const SEPARATOR_HEIGHT = 1

function ContactList({ contacts }) {
  const getItemLayout = useCallback((data, index) => ({
    length: ITEM_HEIGHT,
    offset: (ITEM_HEIGHT + SEPARATOR_HEIGHT) * index,
    index,
  }), [])

  return (
    <FlatList
      data={contacts}
      renderItem={({ item }) => <ContactRow contact={item} />}
      keyExtractor={item => item.id}
      getItemLayout={getItemLayout}
      ItemSeparatorComponent={Separator}
    />
  )
}

// ContactRow must have fixed height
const ContactRow = memo(function ContactRow({ contact }) {
  return (
    <View style={styles.row}>
      <Avatar uri={contact.avatar} />
      <Text>{contact.name}</Text>
    </View>
  )
})

const styles = StyleSheet.create({
  row: {
    height: ITEM_HEIGHT,  // Fixed height matches getItemLayout
    flexDirection: 'row',
    alignItems: 'center',
  },
})
```

**With headers and sections:**

```tsx
const ITEM_HEIGHT = 60
const HEADER_HEIGHT = 40

function getItemLayout(data, index) {
  // Calculate offset accounting for headers
  // This is simplified - real implementation depends on data structure
  return {
    length: ITEM_HEIGHT,
    offset: HEADER_HEIGHT + (ITEM_HEIGHT * index),
    index,
  }
}

// For SectionList, calculation is more complex
// Consider using FlashList which handles this automatically
```

**Enables fast scrollToIndex:**

```tsx
function AlphabetList({ contacts, listRef }) {
  const scrollToLetter = useCallback((letter) => {
    const index = contacts.findIndex(c => c.name.startsWith(letter))
    if (index >= 0) {
      // Instant scroll without measurement
      listRef.current?.scrollToIndex({ index, animated: true })
    }
  }, [contacts])

  return (
    <>
      <FlatList
        ref={listRef}
        data={contacts}
        getItemLayout={getItemLayout}
        // ...
      />
      <AlphabetSidebar onSelect={scrollToLetter} />
    </>
  )
}
```

**Requirements:**
- All items must have identical heights
- Include separator heights in offset calculation
- Item component must enforce the fixed height

Reference: [React Native FlatList getItemLayout](https://reactnative.dev/docs/flatlist#getitemlayout)
