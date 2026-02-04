---
title: Use Async Routes for Code Splitting
impact: CRITICAL
impactDescription: 30-50% smaller initial bundle
tags: startup, bundle, code-splitting, expo-router
---

## Use Async Routes for Code Splitting

Expo Router supports async routes that split your bundle by route. Only the code needed for the current screen loads initially, deferring the rest until navigation. This dramatically reduces initial bundle size and startup time.

**Incorrect (all routes in initial bundle):**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';

// All screen code loads at startup, even if never visited
export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="index" />
      <Stack.Screen name="settings" />
      <Stack.Screen name="profile" />
      <Stack.Screen name="admin" />  {/* Heavy admin code loaded for all users */}
    </Stack>
  );
}
```

**Correct (enable async routes in Metro config):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.transformer = {
  ...config.transformer,
  asyncRequireModulePath: require.resolve('expo-router/async-require'),
};

module.exports = config;
```

```json
// app.json
{
  "expo": {
    "experiments": {
      "asyncRoutes": true
    }
  }
}
```

**How it works:**
- Each route file becomes a separate bundle chunk
- Chunks load on-demand when user navigates to that route
- Initial bundle contains only the entry route

Reference: [Expo Router Async Routes](https://docs.expo.dev/router/reference/async-routes/)
