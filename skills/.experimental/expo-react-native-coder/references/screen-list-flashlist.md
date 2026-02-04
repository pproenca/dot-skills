---
title: Use FlashList for Large Lists Instead of FlatList
impact: HIGH
impactDescription: 5-10x better scroll performance on large lists
tags: screen, list, flashlist, performance
---

## Use FlashList for Large Lists Instead of FlatList

FlashList recycles components under the hood for dramatically better performance, especially on Android. It's a drop-in replacement for FlatList.

**Incorrect (FlatList struggles with large lists):**

```typescript
import { FlatList, Text, View } from 'react-native';

export default function FeedScreen() {
  return (
    <FlatList
      data={posts}
      renderItem={({ item }) => (
        <View style={{ padding: 16 }}>
          <Text>{item.title}</Text>
        </View>
      )}
    />
  );
}
```

**Correct (FlashList with estimatedItemSize):**

```bash
npx expo install @shopify/flash-list
```

```typescript
import { FlashList } from '@shopify/flash-list';
import { Text, View } from 'react-native';

interface Post {
  id: string;
  title: string;
  body: string;
}

export default function FeedScreen() {
  const posts: Post[] = [...];

  return (
    <FlashList
      data={posts}
      renderItem={({ item }) => (
        <View style={{ padding: 16 }}>
          <Text style={{ fontWeight: 'bold' }}>{item.title}</Text>
          <Text>{item.body}</Text>
        </View>
      )}
      estimatedItemSize={100}  // Required: approximate item height
      keyExtractor={(item) => item.id}
    />
  );
}
```

**When to use FlatList instead:**
- Very small lists (< 100 items)
- Lists with complex item layout changes during scroll

Reference: [FlashList - Shopify](https://shopify.github.io/flash-list/)
