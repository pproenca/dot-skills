---
title: Pass Minimal Data via Route Params
impact: HIGH
impactDescription: prevents stale data and reduces navigation overhead
tags: screen, detail, params, navigation
---

## Pass Minimal Data via Route Params

Pass only the ID via route params, then fetch full data on the detail screen. Passing entire objects leads to stale data and serialization issues.

**Incorrect (passing entire object via params):**

```typescript
// List screen - passes entire post object
router.push({
  pathname: '/post/[id]',
  params: {
    id: post.id,
    title: post.title,
    body: post.body,
    author: JSON.stringify(post.author),  // Serialization issues
    createdAt: post.createdAt.toISOString(),
  }
});

// Detail screen - uses potentially stale data
const { title, body, author } = useLocalSearchParams();
```

**Correct (pass ID, fetch on detail screen):**

```typescript
// List screen - passes only ID
import { Link } from 'expo-router';

<Link href={`/post/${post.id}`}>
  <Text>{post.title}</Text>
</Link>
```

```typescript
// app/post/[id].tsx - fetches fresh data
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';

interface Post {
  id: string;
  title: string;
  body: string;
}

export default function PostDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchPost() {
      const response = await fetch(`/api/posts/${id}`);
      const data = await response.json();
      setPost(data);
      setLoading(false);
    }
    fetchPost();
  }, [id]);

  if (loading) return <ActivityIndicator />;
  if (!post) return <Text>Post not found</Text>;

  return (
    <View style={{ padding: 16 }}>
      <Text style={{ fontSize: 24 }}>{post.title}</Text>
      <Text>{post.body}</Text>
    </View>
  );
}
```

Reference: [Using URL parameters - Expo Documentation](https://docs.expo.dev/router/reference/url-parameters/)
