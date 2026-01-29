---
title: Use Workspace Globs for Consistent Configuration
impact: HIGH
impactDescription: applies consistent rules across all packages
tags: workspace, monorepo, globs, patterns
---

## Use Workspace Globs for Consistent Configuration

Use glob patterns for workspace configuration to apply consistent entry and project patterns across all packages. Override specific workspaces when needed.

**Incorrect (individual workspace configs, inconsistent):**

```json
{
  "workspaces": {
    "packages/auth": { "entry": ["index.ts"] },
    "packages/api": { "entry": ["index.ts"] },
    "packages/ui": { "entry": ["index.ts"] }
  }
}
```

**Correct (glob pattern for consistent config):**

```json
{
  "workspaces": {
    "packages/*": {
      "entry": ["{index,main}.ts"],
      "project": ["src/**/*.ts", "!src/**/*.test.ts"]
    },
    "packages/cli": {
      "entry": ["bin/cli.ts"]
    }
  }
}
```

Knip matches workspaces from `package.json` or `pnpm-workspace.yaml`. Specific workspace configs override glob patterns.

Reference: [Monorepos & Workspaces](https://knip.dev/features/monorepos-and-workspaces)
