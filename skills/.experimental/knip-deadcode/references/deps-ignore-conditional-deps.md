---
title: Ignore Conditionally Loaded Dependencies
impact: HIGH
impactDescription: prevents false positives for optional dependencies
tags: deps, conditional, optional, runtime
---

## Ignore Conditionally Loaded Dependencies

Dependencies loaded conditionally at runtime (based on environment, platform, or feature flags) may appear unused. Use `ignoreDependencies` for these cases.

**Incorrect (conditional dependency reported as unused):**

```typescript
// src/database.ts
let driver
if (process.env.DB_TYPE === 'postgres') {
  driver = require('pg')
} else {
  driver = require('mysql2')
}
```

Knip reports: `pg` or `mysql2` unused (depending on static analysis path).

**Correct (conditional dependencies ignored):**

```json
{
  "ignoreDependencies": ["pg", "mysql2"]
}
```

**Production-only ignore:**

```json
{
  "ignoreDependencies": ["pg!", "mysql2!"]
}
```

The `!` suffix applies the ignore only in production mode.

**Better alternative (when possible):**

Use dynamic imports with known paths that Knip can add as entries:

```json
{
  "entry": ["src/drivers/*.ts"]
}
```

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
