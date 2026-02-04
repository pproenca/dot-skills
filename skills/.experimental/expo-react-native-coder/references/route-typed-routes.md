---
title: Enable Typed Routes for Static Type Safety
impact: HIGH
impactDescription: catches navigation errors at compile time
tags: route, typescript, type-safety, navigation
---

## Enable Typed Routes for Static Type Safety

Enable typed routes to get compile-time checking for navigation paths. Invalid routes cause TypeScript errors instead of runtime crashes.

**Incorrect (string paths without type checking):**

```typescript
// Typo won't be caught until runtime
router.push('/proflie');  // Should be '/profile'

// Wrong params not detected
router.push({ pathname: '/user/[id]', params: { userId: '123' } });
// Should be { id: '123' }
```

**Correct (enable typed routes):**

```json
// app.json
{
  "expo": {
    "experiments": {
      "typedRoutes": true
    }
  }
}
```

```typescript
// Now TypeScript catches errors
import { router, Link, Href } from 'expo-router';

// Error: '/proflie' is not a valid route
router.push('/proflie');

// Correct usage with autocomplete
router.push('/profile');

// Typed params
router.push({
  pathname: '/user/[id]',
  params: { id: '123' }  // TypeScript knows 'id' is required
});

// Link component also typed
<Link href="/user/123">User</Link>

// Custom typed href
const userHref: Href = {
  pathname: '/user/[id]',
  params: { id: '123' }
};
```

**Note:** Run `npx expo start` to generate route types in `.expo/types/router.d.ts`. Types update automatically during development.

Reference: [Typed routes - Expo Documentation](https://docs.expo.dev/router/reference/typed-routes/)
