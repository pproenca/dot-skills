---
title: Extract renderItem with useCallback
impact: HIGH
impactDescription: Prevents function recreation on every render, stabilizes FlatList and avoids unnecessary re-renders
tags: list, performance, flatlist, useCallback, optimization
---

## Extract renderItem with useCallback

Defining renderItem as an inline arrow function creates a new function reference on every parent render, causing FlatList to think the renderItem has changed and potentially re-render all visible items. Extracting the function and wrapping it with useCallback provides a stable reference.

**Incorrect (inline arrow function in renderItem prop):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList } from 'react-native';

// Bad: Inline functions create new references on every render
const UserList = ({ users, onUserSelect }) => {
  const [selectedId, setSelectedId] = useState(null);

  return (
    <FlatList
      data={users}
      // Bad: New function created every render, destabilizes FlatList
      renderItem={({ item }) => (
        <ListItem
          onPress={() => {
            setSelectedId(item.id);
            onUserSelect(item);
          }}
        >
          <Avatar source={{ uri: item.avatar }} rounded />
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
            <ListItem.Subtitle>{item.role}</ListItem.Subtitle>
          </ListItem.Content>
          {selectedId === item.id && <ListItem.CheckBox checked />}
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      extraData={selectedId}
    />
  );
};
```

**Correct (useCallback-wrapped renderItem outside JSX):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList } from 'react-native';
import { useCallback, useState } from 'react';

const UserList = ({ users, onUserSelect }) => {
  const [selectedId, setSelectedId] = useState(null);

  // Good: Stable function reference with proper dependencies
  const handleUserPress = useCallback((item) => {
    setSelectedId(item.id);
    onUserSelect(item);
  }, [onUserSelect]);

  // Good: Extract renderItem with useCallback for stable reference
  const renderItem = useCallback(({ item }) => (
    <ListItem onPress={() => handleUserPress(item)}>
      <Avatar source={{ uri: item.avatar }} rounded />
      <ListItem.Content>
        <ListItem.Title>{item.name}</ListItem.Title>
        <ListItem.Subtitle>{item.role}</ListItem.Subtitle>
      </ListItem.Content>
      {selectedId === item.id && <ListItem.CheckBox checked />}
    </ListItem>
  ), [handleUserPress, selectedId]);

  return (
    <FlatList
      data={users}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
      // extraData ensures re-render when selectedId changes
      extraData={selectedId}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
