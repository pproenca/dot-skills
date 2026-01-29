---
title: Configure Path Aliases in Knip
impact: CRITICAL
impactDescription: resolves aliased imports correctly, prevents false positives
tags: config, paths, aliases, typescript
---

## Configure Path Aliases in Knip

Configure path aliases in knip.json to match your tsconfig.json or bundler config. Unresolved aliases cause false positive unused file reports.

**Incorrect (aliases not configured, imports unresolved):**

```json
{
  "entry": ["src/index.ts"],
  "project": ["src/**/*.ts"]
}
```

**Correct (aliases match tsconfig.json):**

```json
{
  "paths": {
    "@lib": ["./src/lib/index.ts"],
    "@lib/*": ["./src/lib/*"],
    "@components/*": ["./src/components/*"],
    "@utils/*": ["./src/utils/*"]
  },
  "entry": ["src/index.ts"],
  "project": ["src/**/*.ts"]
}
```

**Alternative (use tsconfig directly):**

```bash
knip --tsConfig tsconfig.json
```

**Note:** Knip reads paths from tsconfig.json by default. Only add `paths` to knip.json if they differ or tsconfig is not in the root.

Reference: [Knip Configuration - Paths](https://knip.dev/reference/configuration)
