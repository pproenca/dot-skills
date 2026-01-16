---
title: Export Through Public API Only
impact: CRITICAL
impactDescription: Prevents deep imports; enables internal refactoring without breaking consumers
tags: import, public-api, encapsulation, index
---

## Export Through Public API Only

Each feature should have a single entry point (index.ts) that exports its public API. External code should never import internal files directly. This allows internal restructuring without affecting consumers.

**Incorrect (deep imports into feature internals):**

```typescript
// src/app/pages/UserPage.tsx
import { UserProfile } from '@/features/user/components/UserProfile';
import { useUser } from '@/features/user/hooks/useUser';
import { formatUserName } from '@/features/user/utils/formatters';
import { User } from '@/features/user/types/user';
```

**Correct (import from public API):**

```typescript
// src/features/user/index.ts (public API)
export { UserProfile } from './components/UserProfile';
export { UserSettings } from './components/UserSettings';
export { useUser } from './hooks/useUser';
export type { User, UserRole } from './types';
// Note: formatUserName is NOT exported - it's internal

// src/app/pages/UserPage.tsx
import { UserProfile, useUser } from '@/features/user';
import type { User } from '@/features/user';
```

**Internal file can import freely:**

```typescript
// src/features/user/components/UserProfile.tsx
import { useUser } from '../hooks/useUser';
import { formatUserName } from '../utils/formatters';  // Internal util
import type { User } from '../types';
```

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'no-restricted-imports': ['error', {
    patterns: [
      {
        group: ['@/features/*/components/*', '@/features/*/hooks/*', '@/features/*/utils/*'],
        message: 'Import from feature index.ts instead',
      },
    ],
  }],
}
```

**Benefits:**
- Refactor internal structure without breaking external imports
- Clear contract of what a feature provides
- Smaller, focused public surface area

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
