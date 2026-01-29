---
title: List Cross-Workspace Dependencies Explicitly
impact: HIGH
impactDescription: prevents false positives from workspace imports
tags: workspace, monorepo, dependencies, cross-reference
---

## List Cross-Workspace Dependencies Explicitly

List other workspaces as dependencies in each package.json instead of using relative imports or path aliases. This helps Knip track cross-workspace usage correctly.

**Incorrect (path alias crosses workspaces, import untracked):**

```typescript
// packages/api/src/auth.ts
import { User } from '@packages/shared/types'  // Path alias
```

```json
{
  "paths": {
    "@packages/*": ["../*/src"]
  }
}
```

**Correct (workspace listed as dependency):**

```json
{
  "name": "@myorg/api",
  "dependencies": {
    "@myorg/shared": "workspace:*"
  }
}
```

```typescript
// packages/api/src/auth.ts
import { User } from '@myorg/shared/types'  // Package import
```

**Benefits:**
- Knip tracks the dependency relationship correctly
- Package manager validates workspace links
- Clearer dependency graph for developers

Reference: [Monorepos & Workspaces](https://knip.dev/features/monorepos-and-workspaces)
