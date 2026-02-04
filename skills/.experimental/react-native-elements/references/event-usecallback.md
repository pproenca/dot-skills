---
title: Wrap Event Handlers in useCallback
impact: MEDIUM
impactDescription: Stable function references prevent 30-50% unnecessary child re-renders
tags: event, useCallback, performance, memoization
---

## Wrap Event Handlers in useCallback

Creating inline functions in render creates new function references on every render cycle. This breaks `React.memo` optimizations on child components and causes unnecessary re-renders throughout your component tree.

**Incorrect (inline arrow function creates new reference each render):**

```tsx
import { ListItem } from '@rneui/themed';

function ItemList({ items, onItemSelect }) {
  return (
    <>
      {items.map((item) => (
        <ListItem
          key={item.id}
          // New function created on every render - breaks memo
          onPress={() => onItemSelect(item.id)}
        >
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      ))}
    </>
  );
}
```

**Correct (useCallback provides stable reference):**

```tsx
import { useCallback } from 'react';
import { ListItem } from '@rneui/themed';

function ItemList({ items, onItemSelect }) {
  // Stable function reference - only changes when onItemSelect changes
  const handlePress = useCallback(
    (itemId: string) => {
      onItemSelect(itemId);
    },
    [onItemSelect]
  );

  return (
    <>
      {items.map((item) => (
        <ListItem
          key={item.id}
          // Pass stable reference with item data
          onPress={() => handlePress(item.id)}
        >
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      ))}
    </>
  );
}

// For maximum optimization, extract to memoized component
const MemoizedListItem = React.memo(({ item, onPress }) => (
  <ListItem onPress={onPress}>
    <ListItem.Content>
      <ListItem.Title>{item.name}</ListItem.Title>
    </ListItem.Content>
  </ListItem>
));
```

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
