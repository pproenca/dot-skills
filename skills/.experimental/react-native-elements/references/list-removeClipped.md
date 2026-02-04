---
title: Configure removeClippedSubviews Carefully
impact: HIGH
impactDescription: Reduces main thread work by unmounting off-screen views, but can cause blank areas on iOS
tags: list, performance, flatlist, removeClippedSubviews, platform
---

## Configure removeClippedSubviews Carefully

The removeClippedSubviews prop unmounts components that are outside the viewport, reducing main thread work. However, it has known issues on iOS where it can cause blank areas during fast scrolling or when items have varying heights. Test thoroughly on both platforms before enabling.

**Incorrect (removeClippedSubviews={true} on iOS without testing):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList } from 'react-native';

// Bad: Blindly enabling removeClippedSubviews on iOS
// Can cause blank white rectangles during fast scrolling
const ChatList = ({ messages }) => {
  return (
    <FlatList
      data={messages}
      renderItem={({ item }) => (
        // Variable height content makes issues more likely
        <ListItem>
          <Avatar source={{ uri: item.avatar }} />
          <ListItem.Content>
            <ListItem.Title>{item.sender}</ListItem.Title>
            {/* Variable height text */}
            <ListItem.Subtitle>{item.message}</ListItem.Subtitle>
            {item.image && (
              <Image source={{ uri: item.image }} style={styles.image} />
            )}
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      // Bad: iOS has rendering bugs with this prop
      removeClippedSubviews={true}
    />
  );
};
```

**Correct (test on both platforms, typically Android-only):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList, Platform } from 'react-native';
import { useCallback } from 'react';

// Good: Platform-specific configuration with careful consideration
const ChatList = ({ messages }) => {
  const renderMessage = useCallback(({ item }) => (
    <ListItem>
      <Avatar source={{ uri: item.avatar }} />
      <ListItem.Content>
        <ListItem.Title>{item.sender}</ListItem.Title>
        <ListItem.Subtitle>{item.message}</ListItem.Subtitle>
        {item.image && (
          <Image source={{ uri: item.image }} style={styles.image} />
        )}
      </ListItem.Content>
    </ListItem>
  ), []);

  return (
    <FlatList
      data={messages}
      renderItem={renderMessage}
      keyExtractor={(item) => item.id}
      // Good: Only enable on Android where it's stable
      // Or enable on iOS only after thorough testing
      removeClippedSubviews={Platform.OS === 'android'}
    />
  );
};

// Good: For fixed-height items on iOS, it's safer to enable
const NotificationList = ({ notifications }) => {
  const ITEM_HEIGHT = 72;

  return (
    <FlatList
      data={notifications}
      renderItem={({ item }) => (
        // Fixed height items are safer with removeClippedSubviews
        <ListItem containerStyle={{ height: ITEM_HEIGHT }}>
          <ListItem.Content>
            <ListItem.Title>{item.title}</ListItem.Title>
            <ListItem.Subtitle numberOfLines={1}>
              {item.body}
            </ListItem.Subtitle>
          </ListItem.Content>
        </ListItem>
      )}
      keyExtractor={(item) => item.id}
      getItemLayout={(data, index) => ({
        length: ITEM_HEIGHT,
        offset: ITEM_HEIGHT * index,
        index,
      })}
      // Safer on iOS with fixed heights and getItemLayout
      removeClippedSubviews={true}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
