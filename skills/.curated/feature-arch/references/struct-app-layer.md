---
title: Separate App Layer from Features
impact: HIGH
impactDescription: Isolates global concerns; enables feature modules to remain pure
tags: struct, app-layer, providers, routing
---

## Separate App Layer from Features

The app layer handles global concerns: routing, providers, initialization, and global layouts. Features should not contain routing logic or provider setup. This separation allows features to be portable and testable in isolation.

**Incorrect (routing and providers mixed with features):**

```
src/features/user/
├── components/
│   └── UserProfile.tsx
├── UserRoutes.tsx        # Routing logic in feature
└── UserProvider.tsx      # Provider in feature
```

```typescript
// src/features/user/UserRoutes.tsx
import { Routes, Route } from 'react-router-dom';

export function UserRoutes() {
  return (
    <Routes>
      <Route path="/profile" element={<UserProfile />} />
      <Route path="/settings" element={<UserSettings />} />
    </Routes>
  );
}
```

**Correct (app layer owns routing and providers):**

```
src/
├── app/
│   ├── providers/
│   │   ├── AuthProvider.tsx
│   │   ├── QueryProvider.tsx
│   │   └── index.tsx
│   ├── routes/
│   │   ├── index.tsx
│   │   └── protected-routes.tsx
│   └── App.tsx
└── features/
    └── user/
        ├── components/
        │   ├── UserProfile.tsx
        │   └── UserSettings.tsx
        └── index.ts
```

```typescript
// src/app/routes/index.tsx
import { UserProfile, UserSettings } from '@/features/user';

export const routes = [
  { path: '/profile', element: <UserProfile /> },
  { path: '/settings', element: <UserSettings /> },
];
```

**App layer responsibilities:**
- Route definitions and navigation
- Provider composition (Auth, Query, Theme)
- Global error boundaries
- Application initialization

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
