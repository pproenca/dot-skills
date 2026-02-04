---
title: Configure windowSize for Memory/Performance Balance
impact: HIGH
impactDescription: Reduces memory usage by unmounting distant items, critical for long lists on low-end devices
tags: list, performance, flatlist, memory, virtualization
---

## Configure windowSize for Memory/Performance Balance

The windowSize prop determines how many items FlatList renders outside the visible area (measured in viewport heights). The default of 21 keeps many items in memory, which can cause memory pressure on low-end devices with long lists. Tuning this value balances memory usage against blank content during fast scrolling.

**Incorrect (default windowSize=21 for long lists on low-end devices):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList } from 'react-native';

// Bad: Default windowSize renders ~21 viewports worth of items
// For a 1000-item list, this could be 200+ mounted components
const MessageList = ({ messages }) => {
  return (
    <FlatList
      data={messages} // Could be 1000+ messages
      renderItem={({ item }) => (
        <ListItem>
          <Avatar source={{ uri: item.senderAvatar }} />
          <ListItem.Content>
            <ListItem.Title>{item.senderName}</ListItem.Title>
            <ListItem.Subtitle numberOfLines={2}>
              {item.content}
            </ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      // No windowSize configured - defaults to 21
      // On low-end devices, this causes memory issues
    />
  );
};
```

**Correct (windowSize tuned for device capability):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList, Platform } from 'react-native';
import { useMemo } from 'react';

// Good: Configure windowSize based on use case and device
const MessageList = ({ messages, isLowEndDevice }) => {
  // Smaller windowSize = less memory, more blank content when scrolling fast
  // Larger windowSize = more memory, smoother scrolling experience
  const windowSize = useMemo(() => {
    if (isLowEndDevice) return 5;  // Aggressive memory savings
    if (messages.length > 500) return 7;  // Balance for long lists
    return 11;  // Default-ish for short lists
  }, [isLowEndDevice, messages.length]);

  return (
    <FlatList
      data={messages}
      renderItem={({ item }) => (
        <ListItem>
          <Avatar source={{ uri: item.senderAvatar }} />
          <ListItem.Content>
            <ListItem.Title>{item.senderName}</ListItem.Title>
            <ListItem.Subtitle numberOfLines={2}>
              {item.content}
            </ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      // Good: Tuned for memory/performance balance
      windowSize={windowSize}
      // Complementary props for memory optimization
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      initialNumToRender={10}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
