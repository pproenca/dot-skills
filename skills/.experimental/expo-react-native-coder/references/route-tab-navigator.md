---
title: Configure Tab Navigator with Route Groups
impact: CRITICAL
impactDescription: creates bottom navigation with automatic route handling
tags: route, tabs, navigation, layout
---

## Configure Tab Navigator with Route Groups

Use a route group with parentheses `(tabs)` to create a tab navigator. Each file in the group becomes a tab.

**Incorrect (tabs defined outside proper group structure):**

```typescript
// No route group, manual tab setup
<Tabs>
  <Tabs.Screen name="home" />
  <Tabs.Screen name="search" />
</Tabs>
```

**Correct (route group with proper layout):**

```plaintext
app/
├── _layout.tsx           # Root layout
└── (tabs)/
    ├── _layout.tsx       # Tab navigator layout
    ├── index.tsx         # First tab (Home)
    ├── search.tsx        # Second tab (Search)
    └── profile.tsx       # Third tab (Profile)
```

```typescript
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        headerShown: true,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="search" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

```typescript
// app/_layout.tsx - Root layout wrapping tabs
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
    </Stack>
  );
}
```

Reference: [Navigation layouts - Expo Documentation](https://docs.expo.dev/router/basics/layout/)
