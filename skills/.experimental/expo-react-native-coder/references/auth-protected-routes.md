---
title: Use Stack.Protected for Authentication Guards
impact: HIGH
impactDescription: automatically redirects unauthenticated users
tags: auth, protected-routes, navigation, security
---

## Use Stack.Protected for Authentication Guards

Use `Stack.Protected` to guard routes based on authentication state. Unauthenticated users are automatically redirected.

**Incorrect (manual redirect logic in each screen):**

```typescript
// Every protected screen needs this check
export default function ProfileScreen() {
  const { session } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!session) router.replace('/sign-in');
  }, [session]);

  if (!session) return null;
  return <View>...</View>;
}
```

**Correct (centralized protection with Stack.Protected):**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';
import { useAuth } from '@/context/auth';

export default function RootLayout() {
  const { session, isLoading } = useAuth();

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <Stack>
      {/* Protected routes - only accessible when logged in */}
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(app)" options={{ headerShown: false }} />
      </Stack.Protected>

      {/* Auth routes - only accessible when logged out */}
      <Stack.Protected guard={!session}>
        <Stack.Screen name="sign-in" options={{ headerShown: false }} />
        <Stack.Screen name="sign-up" options={{ headerShown: false }} />
      </Stack.Protected>
    </Stack>
  );
}
```

```plaintext
app/
├── _layout.tsx          # Root layout with Protected guards
├── sign-in.tsx          # Shown when !session
├── sign-up.tsx          # Shown when !session
└── (app)/               # Protected group
    ├── _layout.tsx      # App layout (tabs, etc.)
    ├── index.tsx        # Home screen
    └── profile.tsx      # Profile screen
```

**Note:** When `session` changes, the layout re-renders and navigation updates automatically.

Reference: [Authentication in Expo Router - Expo Documentation](https://docs.expo.dev/router/advanced/authentication/)
