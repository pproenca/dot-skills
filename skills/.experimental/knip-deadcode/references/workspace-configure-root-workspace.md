---
title: Configure Root Workspace Explicitly
impact: HIGH
impactDescription: prevents root-level scripts from appearing unused
tags: workspace, monorepo, root, configuration
---

## Configure Root Workspace Explicitly

In monorepos, root-level entry and project options are ignored. Configure the root workspace using `workspaces["."]` to analyze root scripts and shared tooling.

**Incorrect (root entries ignored in monorepo):**

```json
{
  "entry": ["scripts/*.ts"],
  "project": ["scripts/**/*.ts"],
  "workspaces": {
    "packages/*": {}
  }
}
```

**Correct (root workspace configured explicitly):**

```json
{
  "workspaces": {
    ".": {
      "entry": ["scripts/*.ts"],
      "project": ["scripts/**/*.ts"]
    },
    "packages/*": {
      "entry": ["{index,cli}.ts"],
      "project": ["**/*.ts"]
    }
  }
}
```

**Note:** The `"."` key represents the root workspace. Without it, root-level files are not analyzed in monorepo mode.

Reference: [Monorepos & Workspaces](https://knip.dev/features/monorepos-and-workspaces)
