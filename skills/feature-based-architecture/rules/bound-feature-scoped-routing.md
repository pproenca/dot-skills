---
title: Scope Routing to Feature Concerns
impact: HIGH
impactDescription: Enables feature-level code splitting; prevents routing configuration sprawl
tags: bound, routing, scope, navigation
---

## Scope Routing to Feature Concerns

Route definitions belong in the app layer, but route parameters and navigation logic relevant to a feature can be encapsulated within that feature. This keeps routing concerns organized while maintaining the app layer's ownership of the route tree.

**Incorrect (routing logic scattered):**

```typescript
// src/features/user/components/UserProfile.tsx
import { useNavigate, useParams } from 'react-router-dom';

export function UserProfile() {
  const navigate = useNavigate();
  const { userId } = useParams();  // Feature assumes route structure

  const goToSettings = () => {
    navigate(`/users/${userId}/settings`);  // Hardcoded route
  };
}
```

**Correct (feature owns its route utilities):**

```typescript
// src/features/user/routes.ts
export const userRoutes = {
  profile: (userId: string) => `/users/${userId}`,
  settings: (userId: string) => `/users/${userId}/settings`,
  orders: (userId: string) => `/users/${userId}/orders`,
} as const;

// src/features/user/hooks/useUserParams.ts
import { useParams } from 'react-router-dom';

export function useUserParams() {
  const { userId } = useParams<{ userId: string }>();
  if (!userId) throw new Error('userId is required');
  return { userId };
}

// src/features/user/components/UserProfile.tsx
import { useNavigate } from 'react-router-dom';
import { userRoutes } from '../routes';
import { useUserParams } from '../hooks/useUserParams';

export function UserProfile() {
  const navigate = useNavigate();
  const { userId } = useUserParams();

  const goToSettings = () => {
    navigate(userRoutes.settings(userId));  // Uses feature's route builder
  };
}

// src/app/routes/index.tsx
import { userRoutes } from '@/features/user';
import { UserProfile, UserSettings } from '@/features/user';

export const routes = [
  { path: userRoutes.profile(':userId'), element: <UserProfile /> },
  { path: userRoutes.settings(':userId'), element: <UserSettings /> },
];
```

**Benefits:**
- Route paths are centralized per feature
- Refactoring routes only requires changes in one place
- Type-safe route parameters

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
