---
title: Configure TypeScript Path Aliases to Match components.json
impact: CRITICAL
impactDescription: prevents module resolution errors in all component files
tags: setup, typescript, tsconfig, path-aliases, imports
---

## Configure TypeScript Path Aliases to Match components.json

TypeScript path aliases must match the aliases defined in components.json. Mismatched paths cause import resolution failures throughout the codebase.

**Incorrect (mismatched path configuration):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "~/*": ["./src/*"]
    }
  }
}

// components.json uses @/* but tsconfig uses ~/*
// Result: All component imports fail to resolve
```

**Correct (matching path configuration):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}

// components.json
{
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  }
}
```

**Note:** For Vite projects, also configure the resolve alias in vite.config.ts to match.

Reference: [shadcn/ui Installation](https://ui.shadcn.com/docs/installation)
