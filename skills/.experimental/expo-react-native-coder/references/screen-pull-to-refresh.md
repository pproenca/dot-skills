---
title: Add Pull-to-Refresh with RefreshControl
impact: MEDIUM
impactDescription: standard mobile pattern for refreshing content
tags: screen, refresh, list, ux
---

## Add Pull-to-Refresh with RefreshControl

Pull-to-refresh is an expected interaction on mobile lists. Use RefreshControl with FlashList or FlatList.

**Incorrect (no refresh capability):**

```typescript
<FlashList
  data={posts}
  renderItem={({ item }) => <PostItem post={item} />}
  estimatedItemSize={100}
/>
// User has no way to refresh without leaving screen
```

**Correct (RefreshControl with loading state):**

```typescript
import { RefreshControl } from 'react-native';
import { FlashList } from '@shopify/flash-list';
import { useState, useCallback } from 'react';

interface Post {
  id: string;
  title: string;
}

export default function FeedScreen() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const fetchPosts = async () => {
    const response = await fetch('/api/posts');
    const data = await response.json();
    setPosts(data);
  };

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await fetchPosts();
    setRefreshing(false);
  }, []);

  return (
    <FlashList
      data={posts}
      renderItem={({ item }) => <PostItem post={item} />}
      estimatedItemSize={100}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={onRefresh}
          tintColor="#007AFF"  // iOS spinner color
          colors={['#007AFF']} // Android spinner color
        />
      }
    />
  );
}
```

**Note:** `refreshing` must be controlled state - setting it to `false` hides the spinner.

Reference: [RefreshControl - React Native](https://reactnative.dev/docs/refreshcontrol)
