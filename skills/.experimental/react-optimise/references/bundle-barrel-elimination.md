---
title: Eliminate Barrel Files to Enable Tree Shaking
impact: CRITICAL
impactDescription: 200-800ms import cost eliminated
tags: bundle, barrel-files, tree-shaking, imports
---

## Eliminate Barrel Files to Enable Tree Shaking

Barrel files (`index.ts` that re-export everything from a directory) force bundlers to parse and include every exported module, even when the consuming file uses a single export. Tree shaking cannot remove these unused modules because the barrel creates a dependency chain that links all exports together. Direct imports let the bundler include only what is used.

**Incorrect (barrel re-exports pull in every module):**

```tsx
// components/index.ts — barrel file
export { UserAvatar } from "./UserAvatar"
export { UserBadge } from "./UserBadge"
export { UserCard } from "./UserCard"
export { UserProfileHeader } from "./UserProfileHeader"
export { UserActivityFeed } from "./UserActivityFeed"
export { UserSettingsForm } from "./UserSettingsForm" // 45KB, only used in settings page

// pages/Dashboard.tsx — only needs UserAvatar
import { UserAvatar } from "@/components" // loads all 6 components into the chunk
```

**Correct (direct imports enable precise tree shaking):**

```tsx
// pages/Dashboard.tsx — imports only what it uses
import { UserAvatar } from "@/components/UserAvatar"

// tsconfig.json — optional: enforce direct imports via path restrictions
{
  "compilerOptions": {
    "paths": {
      "@/components/*": ["./src/components/*"]
    }
  }
}
```

Reference: [Webpack — Tree Shaking](https://webpack.js.org/guides/tree-shaking/)
