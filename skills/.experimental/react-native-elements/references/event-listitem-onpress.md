---
title: Pass Item Data Correctly in ListItem onPress
impact: MEDIUM
impactDescription: Prevents stale closure bugs and incorrect data access in 100% of list interactions
tags: event, ListItem, closure, data-binding
---

## Pass Item Data Correctly in ListItem onPress

JavaScript closures can capture stale references when iterating over lists, especially with asynchronous updates. Passing item data correctly ensures your press handlers always operate on the current, correct data rather than outdated values from a previous render cycle.

**Incorrect (closure captures stale item reference):**

```tsx
import { ListItem } from '@rneui/themed';

function TaskList({ tasks, onTaskComplete }) {
  // BAD: item reference may be stale if list updates during render
  return (
    <>
      {tasks.map((item) => (
        <ListItem
          key={item.id}
          onPress={() => {
            // This closure captures 'item' at render time
            // If tasks array updates, this still references old item
            onTaskComplete(item);
          }}
        >
          <ListItem.Content>
            <ListItem.Title>{item.title}</ListItem.Title>
          </ListItem.Content>
        </ListItem>
      ))}
    </>
  );
}
```

**Correct (use stable ID and lookup current data):**

```tsx
import { useCallback } from 'react';
import { ListItem } from '@rneui/themed';

function TaskList({ tasks, onTaskComplete }) {
  // Store tasks in ref for fresh access, or use ID-based lookup
  const handlePress = useCallback(
    (taskId: string) => {
      // Lookup current task data at press time, not render time
      const currentTask = tasks.find((t) => t.id === taskId);
      if (currentTask) {
        onTaskComplete(currentTask);
      }
    },
    [tasks, onTaskComplete]
  );

  return (
    <>
      {tasks.map((item) => (
        <MemoizedTaskItem
          key={item.id}
          item={item}
          onPress={handlePress}
        />
      ))}
    </>
  );
}

// Extract to memoized component for better performance
const MemoizedTaskItem = React.memo(({ item, onPress }) => {
  // Pass only the stable ID, not the whole object
  const handleItemPress = useCallback(() => {
    onPress(item.id);
  }, [item.id, onPress]);

  return (
    <ListItem onPress={handleItemPress}>
      <ListItem.Content>
        <ListItem.Title>{item.title}</ListItem.Title>
      </ListItem.Content>
    </ListItem>
  );
});
```

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
