---
title: Use RefreshControl for pull-to-refresh
impact: MEDIUM-HIGH
impactDescription: enables the native pull-to-refresh spinner
tags: touch, pull-to-refresh, refresh-control, lists
---

## Use RefreshControl for pull-to-refresh

Pulling down a list to refresh is the universal iOS gesture for "get the latest." Putting a Refresh button in the header instead breaks that expectation and wastes bar space, while a custom pull animation rarely matches the system spinner's timing and rubber-banding. `RefreshControl` on a `ScrollView`, `FlatList`, or `FlashList` gives the exact native behavior for one prop pair.

**Incorrect (refresh hidden behind a header button):**

```tsx
import { Stack } from 'expo-router';
import { FlatList, Button } from 'react-native';

// Users instinctively pull to refresh; a header button is non-standard and hidden
function TrailsScreen() {
  return (
    <>
      <Stack.Screen options={{ headerRight: () => <Button title="Refresh" onPress={reload} /> }} />
      <FlatList data={trails} renderItem={renderTrailRow} />
    </>
  );
}
```

**Correct (native pull-to-refresh):**

```tsx
import { FlatList, RefreshControl } from 'react-native';

// Standard pull-down gesture with the system spinner and rubber-banding
function TrailsScreen() {
  return (
    <FlatList
      data={trails}
      renderItem={renderTrailRow}
      refreshControl={<RefreshControl refreshing={isReloading} onRefresh={reload} />}
    />
  );
}
```

Reference: [React Native — RefreshControl](https://reactnative.dev/docs/refreshcontrol)
