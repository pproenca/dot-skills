---
title: Enable Entry Export Checking for Private Packages
impact: MEDIUM-HIGH
impactDescription: catches unused exports in internal libraries
tags: exports, entry, private, packages
---

## Enable Entry Export Checking for Private Packages

By default, Knip doesn't report unused exports from entry files (they may be consumed externally). Enable `includeEntryExports` for private packages and monorepo workspaces.

**Incorrect (unused entry exports hidden):**

```json
{
  "entry": ["src/index.ts"]
}
```

```typescript
// src/index.ts
export const usedFunction = () => {}
export const unusedFunction = () => {}  // Not reported
```

**Correct (entry exports included for private package):**

```json
{
  "includeEntryExports": true,
  "entry": ["src/index.ts"]
}
```

Now Knip reports `unusedFunction` as unused.

**Per-workspace configuration:**

```json
{
  "workspaces": {
    "packages/internal-lib": {
      "includeEntryExports": true
    },
    "packages/public-sdk": {
      "includeEntryExports": false
    }
  }
}
```

**When NOT to enable:**
- Public npm packages (exports are the API)
- Packages consumed by external projects

Reference: [Unused Exports](https://knip.dev/typescript/unused-exports)
