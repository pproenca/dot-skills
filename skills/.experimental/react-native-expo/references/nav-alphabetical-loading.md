---
title: Control Route Loading Order with Naming
impact: HIGH
impactDescription: ensures critical routes load first
tags: nav, expo-router, route-order, loading, tabs
---

## Control Route Loading Order with Naming

Expo Router processes folders alphabetically. Name groups to control which routes load first.

**Incorrect (shared screens load before tabs):**

```text
app/
├── (shared)/          # Loads first (alphabetically)
│   ├── help.tsx
│   └── settings.tsx
├── (tabs)/            # Loads second
│   ├── index.tsx
│   └── profile.tsx
└── _layout.tsx
```

```tsx
// User sees help screen first instead of main tabs
// or gets incorrect initial screen
```

**Correct (tabs load before shared):**

```text
app/
├── (tabs)/            # Loads first (alphabetically before 'z')
│   ├── _layout.tsx
│   ├── index.tsx      # Home tab
│   └── profile.tsx    # Profile tab
├── (zShared)/         # Loads after tabs ('z' prefix)
│   ├── _layout.tsx
│   ├── help.tsx
│   └── settings.tsx
└── _layout.tsx
```

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router'

export default function TabsLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Home' }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile' }} />
    </Tabs>
  )
}
```

**Explicit initial route in layout:**

```tsx
// app/_layout.tsx - explicitly set initial route
import { Stack } from 'expo-router'

export default function RootLayout() {
  return (
    <Stack
      initialRouteName="(tabs)"  // Explicit initial route
    >
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="(zShared)" options={{ headerShown: false }} />
    </Stack>
  )
}
```

**Alternative (use route groups strategically):**

```text
app/
├── (app)/             # Main app group
│   ├── (tabs)/        # Tab navigator
│   └── (modals)/      # Modal screens
├── (auth)/            # Auth flow (separate)
│   ├── login.tsx
│   └── register.tsx
└── _layout.tsx
```

```tsx
// app/_layout.tsx - conditional initial route
import { Stack } from 'expo-router'
import { useAuth } from '../hooks/useAuth'

export default function RootLayout() {
  const { isAuthenticated } = useAuth()

  return (
    <Stack initialRouteName={isAuthenticated ? '(app)' : '(auth)'}>
      <Stack.Screen name="(app)" options={{ headerShown: false }} />
      <Stack.Screen name="(auth)" options={{ headerShown: false }} />
    </Stack>
  )
}
```

**Naming conventions:**
- `(tabs)` - Main navigation loads first
- `(auth)` - Auth flow loads when needed
- `(zModals)` - Modals load last (z prefix)
- `(zShared)` - Shared screens load last

Reference: [Expo Router Groups](https://docs.expo.dev/router/layouts/)
