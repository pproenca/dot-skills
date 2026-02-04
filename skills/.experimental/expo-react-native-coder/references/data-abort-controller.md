---
title: Cancel Fetch Requests on Unmount with AbortController
impact: MEDIUM
impactDescription: prevents memory leaks and state updates on unmounted components
tags: data, fetch, cleanup, memory-leak
---

## Cancel Fetch Requests on Unmount with AbortController

Cancel ongoing fetch requests when a component unmounts to prevent memory leaks and "state update on unmounted component" warnings.

**Incorrect (no cleanup, causes memory leaks):**

```typescript
useEffect(() => {
  fetch('/api/posts')
    .then(r => r.json())
    .then(setPosts);  // May run after unmount!
}, []);
```

**Correct (AbortController for cleanup):**

```typescript
import { useEffect, useState } from 'react';

interface Post {
  id: string;
  title: string;
}

export default function PostsScreen() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const abortController = new AbortController();

    async function fetchPosts() {
      try {
        const response = await fetch('/api/posts', {
          signal: abortController.signal,
        });
        const data = await response.json();
        setPosts(data);
      } catch (err) {
        if (err instanceof Error && err.name === 'AbortError') {
          // Request was cancelled, ignore
          return;
        }
        setError(err instanceof Error ? err.message : 'Failed to fetch');
      } finally {
        setLoading(false);
      }
    }

    fetchPosts();

    return () => {
      abortController.abort();  // Cancel on unmount
    };
  }, []);

  return (
    <View>
      {loading && <ActivityIndicator />}
      {error && <Text>{error}</Text>}
      {posts.map(post => <Text key={post.id}>{post.title}</Text>)}
    </View>
  );
}
```

**Alternative with flag pattern:**

```typescript
useEffect(() => {
  let isMounted = true;

  fetch('/api/posts')
    .then(r => r.json())
    .then(data => {
      if (isMounted) setPosts(data);
    });

  return () => { isMounted = false; };
}, []);
```

Reference: [Memory Management - React Native](https://reactnative.dev/docs/performance)
