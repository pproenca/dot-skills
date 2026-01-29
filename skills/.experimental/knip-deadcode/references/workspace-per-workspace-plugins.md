---
title: Configure Plugins Per Workspace
impact: HIGH
impactDescription: catches workspace-specific tool dependencies
tags: workspace, plugins, monorepo, tools
---

## Configure Plugins Per Workspace

Configure plugins at the workspace level when packages use different tools. Root-level plugins apply globally; workspace-level plugins override or extend them.

**Incorrect (global plugin config, misses package-specific tools):**

```json
{
  "jest": true,
  "workspaces": {
    "packages/*": {}
  }
}
```

Package using Vitest instead of Jest: Vitest config entries missed.

**Correct (workspace-specific plugin config):**

```json
{
  "workspaces": {
    "packages/app": {
      "vitest": true,
      "jest": false
    },
    "packages/api": {
      "jest": {
        "config": "jest.config.ts"
      }
    },
    "packages/shared": {
      "vitest": true
    }
  }
}
```

**Disable inherited plugins:**

```json
{
  "eslint": true,
  "workspaces": {
    "packages/legacy": {
      "eslint": false
    }
  }
}
```

Legacy package doesn't use ESLint; disabling prevents false positives.

Reference: [Monorepos & Workspaces](https://knip.dev/features/monorepos-and-workspaces)
