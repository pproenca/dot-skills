---
title: Use getItemLayout for Fixed-Height ListItems
impact: HIGH
impactDescription: Eliminates async layout calculation, enables instant scrollToIndex and jump-to-item functionality
tags: list, performance, flatlist, layout, scrolling
---

## Use getItemLayout for Fixed-Height ListItems

When ListItems have a fixed height, providing getItemLayout allows FlatList to calculate item positions synchronously without measuring. This enables instant scrollToIndex(), eliminates blank spaces during fast scrolling, and significantly improves initial render performance for long lists.

**Incorrect (missing getItemLayout with fixed-height items):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';
import { useRef } from 'react';

// Bad: Without getItemLayout, scrollToIndex requires async measurement
const AlphabetList = ({ contacts }) => {
  const listRef = useRef(null);

  const scrollToLetter = (letterIndex) => {
    // This will be slow or fail without getItemLayout
    // FlatList must measure items to find position
    listRef.current?.scrollToIndex({ index: letterIndex });
  };

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        // ListItem has consistent 72px height but FlatList doesn't know
        <ListItem containerStyle={{ height: 72 }}>
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
            <ListItem.Subtitle>{item.phone}</ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      // Missing getItemLayout - scrollToIndex will be unreliable
    />
  );
};
```

**Correct (getItemLayout for uniform ListItem heights):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';
import { useRef, useCallback } from 'react';

const ITEM_HEIGHT = 72;
const SEPARATOR_HEIGHT = 1;

const AlphabetList = ({ contacts }) => {
  const listRef = useRef(null);

  // Good: Pre-calculate item positions for instant access
  const getItemLayout = useCallback((data, index) => ({
    length: ITEM_HEIGHT,
    offset: (ITEM_HEIGHT + SEPARATOR_HEIGHT) * index,
    index,
  }), []);

  const scrollToLetter = (letterIndex) => {
    // Now instant - no measurement needed
    listRef.current?.scrollToIndex({
      index: letterIndex,
      animated: true,
    });
  };

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        <ListItem containerStyle={{ height: ITEM_HEIGHT }}>
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
            <ListItem.Subtitle>{item.phone}</ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      // Good: Enables synchronous position calculation
      getItemLayout={getItemLayout}
      ItemSeparatorComponent={() => (
        <View style={{ height: SEPARATOR_HEIGHT, backgroundColor: '#eee' }} />
      )}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
