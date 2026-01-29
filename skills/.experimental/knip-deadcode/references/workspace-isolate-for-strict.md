---
title: Isolate Workspaces for Strict Dependency Checking
impact: HIGH
impactDescription: catches undeclared cross-workspace dependencies
tags: workspace, monorepo, strict, isolation
---

## Isolate Workspaces for Strict Dependency Checking

Use `--strict` or `--isolate-workspaces` to enforce that each workspace only uses its declared dependencies. This catches implicit dependencies that would break when published.

**Incorrect (workspaces share dependencies implicitly):**

```bash
knip
```

```typescript
// packages/api/src/handler.ts
import lodash from 'lodash'  // Not in packages/api/package.json
// Works in development due to hoisting
```

**Correct (isolated workspaces catch missing dependencies):**

```bash
knip --strict
```

Or in configuration:

```json
{
  "workspaces": {
    "packages/*": {
      "entry": ["index.ts"]
    }
  }
}
```

```bash
knip --isolate-workspaces
```

Knip reports `lodash` as unlisted in `packages/api` because it's not in that workspace's package.json.

Reference: [Production Mode](https://knip.dev/features/production-mode)
