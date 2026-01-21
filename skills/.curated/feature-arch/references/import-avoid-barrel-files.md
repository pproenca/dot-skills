---
title: Avoid Deep Barrel File Re-exports
impact: HIGH
impactDescription: Prevents tree-shaking failures; reduces bundle size by avoiding unused code
tags: import, barrel-files, tree-shaking, bundle-size
---

## Avoid Deep Barrel File Re-exports

While feature index.ts files are useful for public APIs, avoid creating nested barrel files that re-export everything. Deep barrel chains prevent bundlers from tree-shaking unused code and can cause performance issues in development.

**Incorrect (barrel chain):**

```typescript
// src/features/user/components/index.ts
export * from './UserProfile';
export * from './UserSettings';
export * from './UserAvatar';
export * from './UserBadge';
// ... 20 more exports

// src/features/user/index.ts
export * from './components';  // Re-exports everything
export * from './hooks';
export * from './utils';

// Consumer imports one component but bundles all
import { UserAvatar } from '@/features/user';
```

**Correct (explicit exports):**

```typescript
// src/features/user/index.ts
// Explicit, named exports - bundler knows exactly what's used
export { UserProfile } from './components/UserProfile';
export { UserSettings } from './components/UserSettings';
export { UserAvatar } from './components/UserAvatar';
export { useUser } from './hooks/useUser';
export type { User } from './types';

// Consumer
import { UserAvatar } from '@/features/user';  // Only UserAvatar bundled
```

**Alternative for large features:**

```typescript
// Direct imports for specific needs
import { UserAvatar } from '@/features/user/components/UserAvatar';

// This is acceptable when:
// 1. Feature has 15+ exports
// 2. Consumer only needs one specific item
// 3. Bundle size is critical
```

**When barrel files are OK:**
- Feature public API (index.ts) with explicit exports
- Small features with < 10 exports
- Type-only exports (no runtime impact)

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
