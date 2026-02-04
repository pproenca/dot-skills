---
title: Always Provide keyExtractor for FlatList
impact: HIGH
impactDescription: Enables proper diffing algorithm, prevents duplicate key warnings and incorrect item updates
tags: list, performance, flatlist, keys, diffing
---

## Always Provide keyExtractor for FlatList

FlatList uses keys to track which items have changed, been added, or removed. Without a proper keyExtractor using unique identifiers, React cannot efficiently diff the list, leading to incorrect renders, duplicate key warnings, and wasted re-renders when items are reordered.

**Incorrect (missing keyExtractor or using index as key):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';

// Bad: No keyExtractor - React uses index by default
const TaskList = ({ tasks }) => {
  return (
    <FlatList
      data={tasks}
      renderItem={({ item }) => (
        <ListItem>
          <ListItem.Content>
            <ListItem.Title>{item.title}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      )}
      // Missing keyExtractor!
    />
  );
};

// Also bad: Using index as key breaks diffing on reorder/delete
const TaskListWithIndex = ({ tasks }) => {
  return (
    <FlatList
      data={tasks}
      renderItem={({ item }) => (
        <ListItem>
          <ListItem.Content>
            <ListItem.Title>{item.title}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      )}
      // Bad: Index changes when items are reordered or deleted
      keyExtractor={(item, index) => index.toString()}
    />
  );
};
```

**Correct (keyExtractor using unique stable identifier):**

```tsx
import { ListItem } from '@rneui/themed';
import { FlatList } from 'react-native';

// Good: Use a unique, stable identifier from your data
const TaskList = ({ tasks }) => {
  return (
    <FlatList
      data={tasks}
      renderItem={({ item }) => (
        <ListItem>
          <ListItem.Content>
            <ListItem.Title>{item.title}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      )}
      // Good: Unique ID that doesn't change when list is reordered
      keyExtractor={(item) => item.id}
    />
  );
};

// For items without ID, use a combination of unique fields
const ProductList = ({ products }) => {
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => (
        <ListItem>
          <ListItem.Content>
            <ListItem.Title>{item.name}</ListItem.Title>
            <ListItem.Subtitle>${item.price}</ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      // Good: Composite key from unique combination
      keyExtractor={(item) => `${item.sku}-${item.warehouseId}`}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
