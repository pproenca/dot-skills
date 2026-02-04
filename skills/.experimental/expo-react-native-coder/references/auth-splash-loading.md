---
title: Show Splash Screen During Auth Loading
impact: MEDIUM
impactDescription: prevents flash of wrong screen during auth check
tags: auth, splash, loading, ux
---

## Show Splash Screen During Auth Loading

Keep the splash screen visible while checking authentication state to prevent flashing the wrong screen.

**Incorrect (flash of login screen before redirect):**

```typescript
export default function RootLayout() {
  const { session, isLoading } = useAuth();

  // Shows login briefly before session loads
  return (
    <Stack>
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(app)" />
      </Stack.Protected>
    </Stack>
  );
}
```

**Correct (splash screen during auth check):**

```typescript
import { Stack, SplashScreen } from 'expo-router';
import { useEffect } from 'react';
import { useAuth } from '@/context/auth';

// Prevent auto-hide
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const { session, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading) {
      // Hide splash once auth state is determined
      SplashScreen.hideAsync();
    }
  }, [isLoading]);

  // Show nothing while loading (splash screen remains visible)
  if (isLoading) {
    return null;
  }

  return (
    <Stack>
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(app)" options={{ headerShown: false }} />
      </Stack.Protected>
      <Stack.Protected guard={!session}>
        <Stack.Screen name="sign-in" options={{ headerShown: false }} />
      </Stack.Protected>
    </Stack>
  );
}
```

**Alternative with custom loading screen:**

```typescript
if (isLoading) {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <ActivityIndicator size="large" />
    </View>
  );
}
```

Reference: [SplashScreen - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/splash-screen/)
