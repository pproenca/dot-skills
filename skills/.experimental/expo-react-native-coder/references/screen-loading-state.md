---
title: Show Loading and Error States for Async Screens
impact: HIGH
impactDescription: improves perceived performance and user trust
tags: screen, loading, error, state, ux
---

## Show Loading and Error States for Async Screens

Always handle loading, error, and empty states. Users should never see a blank screen or wonder if the app is working.

**Incorrect (no loading or error handling):**

```typescript
export default function FeedScreen() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch('/api/posts')
      .then(r => r.json())
      .then(setPosts);
  }, []);

  return (
    <FlatList data={posts} renderItem={...} />  // Blank until loaded
  );
}
```

**Correct (explicit loading, error, and empty states):**

```typescript
import { View, Text, ActivityIndicator, Button } from 'react-native';
import { FlashList } from '@shopify/flash-list';
import { useState, useEffect } from 'react';

interface Post {
  id: string;
  title: string;
}

export default function FeedScreen() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPosts = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/posts');
      if (!response.ok) throw new Error('Failed to fetch');
      const data = await response.json();
      setPosts(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text style={{ color: 'red' }}>{error}</Text>
        <Button title="Retry" onPress={fetchPosts} />
      </View>
    );
  }

  if (posts.length === 0) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>No posts yet</Text>
      </View>
    );
  }

  return (
    <FlashList
      data={posts}
      renderItem={({ item }) => <Text>{item.title}</Text>}
      estimatedItemSize={50}
    />
  );
}
```

Reference: [Error handling - Expo Documentation](https://docs.expo.dev/router/error-handling/)
