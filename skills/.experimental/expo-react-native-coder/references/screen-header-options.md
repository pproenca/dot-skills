---
title: Configure Screen Headers with Stack.Screen Options
impact: MEDIUM
impactDescription: customizes navigation header appearance and actions
tags: screen, header, navigation, options
---

## Configure Screen Headers with Stack.Screen Options

Use `options` on Stack.Screen for static config or `useNavigation().setOptions()` for dynamic updates based on data.

**Incorrect (hardcoded header, no customization):**

```typescript
// Default header with no customization
export default function ProfileScreen() {
  return <View>...</View>;
}
```

**Correct (static and dynamic header options):**

```typescript
// app/_layout.tsx - Static options in layout
import { Stack } from 'expo-router';

export default function Layout() {
  return (
    <Stack>
      <Stack.Screen
        name="profile"
        options={{
          title: 'Profile',
          headerStyle: { backgroundColor: '#f5f5f5' },
          headerTintColor: '#333',
          headerRight: () => (
            <Pressable onPress={() => router.push('/settings')}>
              <Ionicons name="settings" size={24} />
            </Pressable>
          ),
        }}
      />
    </Stack>
  );
}
```

```typescript
// app/post/[id].tsx - Dynamic options based on data
import { useNavigation } from 'expo-router';
import { useEffect, useState } from 'react';
import { View, Text, Share, Pressable } from 'react-native';

export default function PostScreen() {
  const navigation = useNavigation();
  const [post, setPost] = useState<{ title: string } | null>(null);

  useEffect(() => {
    if (post) {
      navigation.setOptions({
        title: post.title,
        headerRight: () => (
          <Pressable onPress={() => Share.share({ message: post.title })}>
            <Ionicons name="share" size={24} />
          </Pressable>
        ),
      });
    }
  }, [post, navigation]);

  return (
    <View>
      <Text>{post?.title}</Text>
    </View>
  );
}
```

**Common options:** `title`, `headerShown`, `headerStyle`, `headerTintColor`, `headerLeft`, `headerRight`, `headerBackTitle`

Reference: [Stack - Expo Documentation](https://docs.expo.dev/router/advanced/stack/)
