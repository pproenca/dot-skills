---
title: Memoize ListItem Components in FlatList
impact: HIGH
impactDescription: Prevents re-render of unchanged items, achieving 2-5x scroll performance improvement
tags: list, performance, memo, flatlist, optimization
---

## Memoize ListItem Components in FlatList

When FlatList data changes or parent re-renders, every visible ListItem re-renders by default, even if their props haven't changed. Wrapping ListItem components with React.memo() ensures only items with changed props re-render, dramatically improving scroll smoothness and reducing CPU usage.

**Incorrect (plain ListItem re-renders on every list update):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';

// Bad: This component re-renders whenever the parent list updates,
// even if this specific item's data hasn't changed
const ContactItem = ({ item, onPress }) => {
  return (
    <ListItem onPress={() => onPress(item.id)}>
      <ListItem.Content>
        <ListItem.Title>{item.name}</ListItem.Title>
        <ListItem.Subtitle>{item.email}</ListItem.Subtitle>
      </ListItem.Content>
      <ListItem.Chevron />
    </ListItem>
  );
};

const ContactList = ({ contacts, onContactPress }) => {
  return (
    <FlatList
      data={contacts}
      renderItem={({ item }) => (
        <ContactItem item={item} onPress={onContactPress} />
      )}
      keyExtractor={(item) => item.id}
    />
  );
};
```

**Correct (React.memo wrapped ListItem with proper comparison):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';
import React, { memo, useCallback } from 'react';

// Good: Memoized component only re-renders when item or onPress changes
const ContactItem = memo(({ item, onPress }) => {
  return (
    <ListItem onPress={() => onPress(item.id)}>
      <ListItem.Content>
        <ListItem.Title>{item.name}</ListItem.Title>
        <ListItem.Subtitle>{item.email}</ListItem.Subtitle>
      </ListItem.Content>
      <ListItem.Chevron />
    </ListItem>
  );
}, (prevProps, nextProps) => {
  // Custom comparison for optimal performance
  return prevProps.item.id === nextProps.item.id &&
         prevProps.item.name === nextProps.item.name &&
         prevProps.item.email === nextProps.item.email &&
         prevProps.onPress === nextProps.onPress;
});

const ContactList = ({ contacts, onContactPress }) => {
  // Stable callback reference prevents unnecessary re-renders
  const handlePress = useCallback((id) => {
    onContactPress(id);
  }, [onContactPress]);

  return (
    <FlatList
      data={contacts}
      renderItem={({ item }) => (
        <ContactItem item={item} onPress={handlePress} />
      )}
      keyExtractor={(item) => item.id}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
