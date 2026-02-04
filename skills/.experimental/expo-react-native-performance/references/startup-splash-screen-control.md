---
title: Control Splash Screen Visibility
impact: CRITICAL
impactDescription: prevents white flash, enables asset preloading
tags: startup, splash-screen, expo-splash-screen, loading
---

## Control Splash Screen Visibility

Use `expo-splash-screen` to manually control when the splash screen hides. This allows you to preload critical assets and data before showing the app, preventing white flashes and incomplete UI states.

**Incorrect (splash hides before app is ready):**

```typescript
// App.tsx
export default function App() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchCurrentUser().then(setUser);
  }, []);

  // User sees loading spinner after splash disappears
  if (!user) return <LoadingSpinner />;

  return <MainApp user={user} />;
}
```

**Correct (splash stays until app is ready):**

```typescript
// App.tsx
import * as SplashScreen from 'expo-splash-screen';

SplashScreen.preventAutoHideAsync();

export default function App() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    async function prepare() {
      const userData = await fetchCurrentUser();
      setUser(userData);
      await SplashScreen.hideAsync();
    }
    prepare();
  }, []);

  if (!user) return null;  // Splash still visible

  return <MainApp user={user} />;
}
```

**Important:** Call `preventAutoHideAsync()` in module scope (outside components) to ensure it runs before the splash screen auto-hides.

Reference: [Expo SplashScreen](https://docs.expo.dev/versions/latest/sdk/splash-screen/)
