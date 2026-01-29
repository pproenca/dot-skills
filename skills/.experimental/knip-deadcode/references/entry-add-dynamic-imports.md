---
title: Add Dynamic Import Targets as Entry Points
impact: CRITICAL
impactDescription: prevents false positives for dynamically loaded modules
tags: entry, dynamic-import, lazy-loading, code-splitting
---

## Add Dynamic Import Targets as Entry Points

Knip cannot statically analyze dynamic imports with computed paths. Add dynamically imported modules as explicit entry points.

**Incorrect (dynamic imports unresolved, modules appear unused):**

```typescript
// src/plugins/index.ts
const loadPlugin = async (name: string) => {
  const module = await import(`./plugins/${name}`)  // Knip can't resolve
  return module.default
}
```

```json
{
  "entry": ["src/index.ts"]
}
```

**Correct (dynamic targets added as entries):**

```json
{
  "entry": [
    "src/index.ts",
    "src/plugins/*.ts"
  ]
}
```

**Alternative (use ignoreDependencies for external dynamic imports):**

```json
{
  "ignoreDependencies": ["@plugins/*"]
}
```

**Note:** Static dynamic imports like `import('./known-module')` are resolved correctly. Only computed paths require explicit configuration.

Reference: [Handling Issues - Dynamic Imports](https://knip.dev/guides/handling-issues)
