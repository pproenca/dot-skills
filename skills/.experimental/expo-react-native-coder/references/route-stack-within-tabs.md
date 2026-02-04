---
title: Nest Stack Navigator Inside Tab for Multi-Screen Sections
impact: HIGH
impactDescription: enables drill-down navigation within each tab
tags: route, stack, tabs, nesting, navigation
---

## Nest Stack Navigator Inside Tab for Multi-Screen Sections

Each tab can contain its own stack navigator, allowing users to drill into details while maintaining tab context.

**Incorrect (flat structure loses navigation hierarchy):**

```plaintext
app/
└── (tabs)/
    ├── _layout.tsx
    ├── feed.tsx
    └── feed-detail.tsx    # Not part of feed stack
```

**Correct (nested stack within tab):**

```plaintext
app/
└── (tabs)/
    ├── _layout.tsx
    └── feed/
        ├── _layout.tsx    # Stack navigator for feed tab
        ├── index.tsx      # Feed list
        └── [postId].tsx   # Post detail (stays in feed tab)
```

```typescript
// app/(tabs)/feed/_layout.tsx
import { Stack } from 'expo-router';

export default function FeedLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{ title: 'Feed' }}
      />
      <Stack.Screen
        name="[postId]"
        options={{ title: 'Post' }}
      />
    </Stack>
  );
}
```

```typescript
// app/(tabs)/feed/index.tsx
import { Link } from 'expo-router';
import { FlatList, Pressable, Text } from 'react-native';

export default function FeedScreen() {
  const posts = [{ id: '1', title: 'First Post' }];

  return (
    <FlatList
      data={posts}
      renderItem={({ item }) => (
        <Link href={`/feed/${item.id}`} asChild>
          <Pressable>
            <Text>{item.title}</Text>
          </Pressable>
        </Link>
      )}
    />
  );
}
```

**Note:** When navigating to `/feed/123`, the user stays in the Feed tab with back navigation to the feed list.

Reference: [Common navigation patterns - Expo Documentation](https://docs.expo.dev/router/basics/common-navigation-patterns/)
