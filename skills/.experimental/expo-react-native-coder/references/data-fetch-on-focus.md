---
title: Refetch Data When Screen Comes into Focus
impact: MEDIUM
impactDescription: keeps data fresh when returning to screen
tags: data, fetch, focus, navigation
---

## Refetch Data When Screen Comes into Focus

Use `useFocusEffect` to refetch data when a screen regains focus, ensuring users see fresh data after navigating away and back.

**Incorrect (data only fetched on mount):**

```typescript
useEffect(() => {
  fetchPosts();
}, []);
// Data becomes stale if user creates post on another screen
```

**Correct (refetch on screen focus):**

```typescript
import { useFocusEffect } from 'expo-router';
import { useCallback, useState } from 'react';

interface Post {
  id: string;
  title: string;
}

export default function FeedScreen() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchPosts = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/posts');
      const data = await response.json();
      setPosts(data);
    } finally {
      setLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      fetchPosts();
    }, [fetchPosts])
  );

  return (
    <FlashList
      data={posts}
      renderItem={({ item }) => <Text>{item.title}</Text>}
      estimatedItemSize={50}
      refreshing={loading}
    />
  );
}
```

**When to use:**
- List screens where items can be created/edited on other screens
- Profile screens that might be updated elsewhere
- Any screen with data that changes frequently

**When NOT to use:**
- Static content that rarely changes
- Screens where refetching would disrupt user interaction

Reference: [useFocusEffect - React Navigation](https://reactnavigation.org/docs/use-focus-effect/)
