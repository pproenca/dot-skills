---
title: Enable Async Routes for Lazy Screen Loading
impact: HIGH
impactDescription: 30% smaller initial bundle on web
tags: nav, async-routes, lazy-loading, expo-router, code-splitting
---

## Enable Async Routes for Lazy Screen Loading

Expo Router's async routes load screen code only when navigated to, reducing initial bundle size and startup time.

**Incorrect (all screens bundled upfront):**

```tsx
// All screen code loads at app startup
// app/_layout.tsx
import { Stack } from 'expo-router'

export default function Layout() {
  return <Stack />
}

// Even app/settings.tsx loads at startup
// Even app/admin/dashboard.tsx loads at startup
// Initial bundle includes all screens
```

**Correct (async routes enabled):**

```json
// app.json - enable async routes
{
  "expo": {
    "experiments": {
      "typedRoutes": true
    },
    "web": {
      "bundler": "metro",
      "output": "server"
    },
    "plugins": [
      [
        "expo-router",
        {
          "asyncRoutes": {
            "web": true,
            "default": "development"
          }
        }
      ]
    ]
  }
}
```

```tsx
// app/_layout.tsx - no changes needed
import { Stack } from 'expo-router'

export default function Layout() {
  return <Stack />
}

// app/settings.tsx - loads only when navigated to
export default function SettingsScreen() {
  // This code is in a separate chunk
  return <Settings />
}
```

**Loading states with Suspense:**

```tsx
// app/_layout.tsx - add loading fallback
import { Stack } from 'expo-router'
import { Suspense } from 'react'
import { ActivityIndicator } from 'react-native'

export default function Layout() {
  return (
    <Suspense fallback={<ActivityIndicator />}>
      <Stack
        screenOptions={{
          // Optional: show loading indicator in header
          headerShown: true,
        }}
      />
    </Suspense>
  )
}
```

**Current limitations:**
- Async routes work best on web currently
- Native production apps have limited support (experimental)
- Development mode supports lazy bundling

**When NOT to use:**
- Critical screens that must load instantly
- Screens accessed frequently from anywhere
- When the added complexity isn't worth the savings

Reference: [Expo Router Async Routes](https://docs.expo.dev/router/reference/async-routes/)
