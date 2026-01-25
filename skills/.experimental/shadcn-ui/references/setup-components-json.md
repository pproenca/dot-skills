---
title: Configure components.json Before Adding Components
impact: CRITICAL
impactDescription: prevents path resolution failures across all component imports
tags: setup, components-json, configuration, cli, paths
---

## Configure components.json Before Adding Components

The components.json file tells the CLI where to place components and how to resolve imports. Missing or incorrect configuration causes every component addition to fail or generate incorrect import paths.

**Incorrect (missing aliases configuration):**

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/styles/globals.css"
  }
}
// CLI generates: import { Button } from "components/ui/button"
// Error: Cannot resolve module
```

**Correct (complete aliases configuration):**

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/styles/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "iconLibrary": "lucide"
}
```

**Note:** Run `pnpm dlx shadcn@latest init` to generate this file interactively rather than creating it manually.

Reference: [shadcn/ui components.json](https://ui.shadcn.com/docs/components-json)
