---
title: Add Unlisted Dependencies to Package.json
impact: HIGH
impactDescription: prevents runtime errors in production
tags: deps, unlisted, package-json, reliability
---

## Add Unlisted Dependencies to Package.json

Knip reports unlisted dependencies - packages imported in code but not in package.json. Add these to prevent runtime errors.

**Incorrect (unlisted dependency works by accident):**

```typescript
// src/utils.ts
import dayjs from 'dayjs'  // Not in package.json
```

Knip reports: `dayjs` is unlisted.

**Correct (dependency explicitly listed):**

```bash
npm install dayjs
```

```json
{
  "dependencies": {
    "dayjs": "^1.11.0"
  }
}
```

**Why unlisted dependencies are dangerous:**
- May work locally due to hoisting or transitive deps
- Will fail in production or on other machines
- Package version is unpredictable

**Auto-fix cannot help:**

```bash
knip --fix
# Does NOT add unlisted dependencies
# Knip doesn't know if it should be in dependencies or devDependencies
```

You must manually add unlisted dependencies.

Reference: [Handling Issues](https://knip.dev/guides/handling-issues)
