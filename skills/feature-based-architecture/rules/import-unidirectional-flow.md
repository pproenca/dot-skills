---
title: Enforce Unidirectional Import Flow
impact: CRITICAL
impactDescription: Prevents circular dependencies; enables deterministic build order
tags: import, unidirectional, dependencies, architecture
---

## Enforce Unidirectional Import Flow

Imports must flow in one direction: `shared → features → app`. Features can import from shared, and app can import from both, but never the reverse. This prevents circular dependencies that cause build failures and makes the dependency graph predictable.

**Incorrect (bidirectional imports):**

```typescript
// src/shared/utils/analytics.ts
import { useAuth } from '@/features/auth/hooks/useAuth';  // WRONG: shared → features

export function trackEvent(event: string) {
  const { user } = useAuth();
  // ...
}
```

```typescript
// src/features/user/components/UserProfile.tsx
import { AppLayout } from '@/app/layouts/AppLayout';  // WRONG: features → app

export function UserProfile() {
  return <AppLayout>...</AppLayout>;
}
```

**Correct (unidirectional flow):**

```typescript
// Dependency flow: shared → features → app

// src/shared/utils/analytics.ts
export function trackEvent(event: string, userId?: string) {
  // No feature imports - userId passed as parameter
}

// src/features/user/components/UserProfile.tsx
import { formatDate } from '@/shared/utils/formatDate';  // OK: shared used by feature
import { trackEvent } from '@/shared/utils/analytics';

export function UserProfile({ user }) {
  useEffect(() => {
    trackEvent('profile_view', user.id);
  }, []);
  return <div>...</div>;
}

// src/app/pages/UserPage.tsx
import { UserProfile } from '@/features/user';  // OK: app uses features
import { AppLayout } from '@/app/layouts/AppLayout';

export function UserPage() {
  return (
    <AppLayout>
      <UserProfile />
    </AppLayout>
  );
}
```

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'import/no-restricted-paths': ['error', {
    zones: [
      { target: './src/shared', from: './src/features' },
      { target: './src/shared', from: './src/app' },
      { target: './src/features', from: './src/app' },
    ],
  }],
}
```

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
