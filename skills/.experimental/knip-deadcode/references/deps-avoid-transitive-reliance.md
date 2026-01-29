---
title: Avoid Relying on Transitive Dependencies
impact: HIGH
impactDescription: prevents breakage when dependencies update
tags: deps, transitive, unlisted, reliability
---

## Avoid Relying on Transitive Dependencies

Direct imports of transitive dependencies (packages installed as dependencies of your dependencies) may break when those dependencies update. Add explicit dependencies for all directly imported packages.

**Incorrect (importing transitive dependency):**

```typescript
// src/utils.ts
import debug from 'debug'  // Not in package.json
// Works because 'express' depends on 'debug'
```

```json
{
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

Knip reports: `debug` is unlisted.

**Correct (explicit dependency):**

```json
{
  "dependencies": {
    "debug": "^4.3.0",
    "express": "^4.18.0"
  }
}
```

**Why this matters:**
- Express may remove debug as a dependency in future versions
- Transitive dependencies may have different versions than expected
- Package managers may not install expected transitive dependencies

Reference: [Handling Issues](https://knip.dev/guides/handling-issues)
