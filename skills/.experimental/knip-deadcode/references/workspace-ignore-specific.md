---
title: Ignore Specific Workspaces When Needed
impact: HIGH
impactDescription: excludes irrelevant packages from analysis
tags: workspace, monorepo, ignore, exclusion
---

## Ignore Specific Workspaces When Needed

Use `ignoreWorkspaces` to exclude specific packages from analysis. This is useful for third-party forks, generated packages, or packages with incompatible structures.

**Incorrect (analyzing incompatible workspace causes noise):**

```json
{
  "workspaces": {
    "packages/*": {
      "entry": ["index.ts"]
    }
  }
}
```

**Correct (incompatible workspace excluded):**

```json
{
  "ignoreWorkspaces": [
    "packages/legacy-fork",
    "packages/generated-api"
  ],
  "workspaces": {
    "packages/*": {
      "entry": ["index.ts"]
    }
  }
}
```

**When to ignore workspaces:**
- Third-party code forks with different conventions
- Generated code packages
- Packages scheduled for removal
- Packages with their own Knip configuration

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
