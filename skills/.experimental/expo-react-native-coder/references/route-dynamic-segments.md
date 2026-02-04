---
title: Use Dynamic Route Segments with Brackets
impact: CRITICAL
impactDescription: enables parameterized routes like /user/[id]
tags: route, dynamic, parameters, navigation
---

## Use Dynamic Route Segments with Brackets

Use square brackets `[param]` in filenames to create dynamic route segments. Access parameters with `useLocalSearchParams()`.

**Incorrect (hardcoded routes for each item):**

```plaintext
app/
├── user-1.tsx
├── user-2.tsx
└── user-3.tsx
```

**Correct (dynamic route segment):**

```plaintext
app/
├── _layout.tsx
├── index.tsx
└── user/
    └── [id].tsx          # Matches /user/1, /user/abc, etc.
```

```typescript
// app/user/[id].tsx
import { useLocalSearchParams } from 'expo-router';
import { View, Text } from 'react-native';

export default function UserScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <View>
      <Text>User ID: {id}</Text>
    </View>
  );
}
```

```typescript
// Navigating to dynamic route
import { Link, router } from 'expo-router';

// Using Link component
<Link href="/user/123">View User 123</Link>

// Using router imperatively
router.push('/user/123');

// With typed routes (requires experiments.typedRoutes)
router.push({ pathname: '/user/[id]', params: { id: '123' } });
```

**Catch-all routes:** Use `[...slug].tsx` to match multiple segments like `/docs/a/b/c`.

Reference: [Core concepts - Expo Documentation](https://docs.expo.dev/router/basics/core-concepts/)
