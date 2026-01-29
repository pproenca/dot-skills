---
title: Tag Public API Exports with JSDoc
impact: MEDIUM-HIGH
impactDescription: prevents false positives for intentional public APIs
tags: exports, jsdoc, api, documentation
---

## Tag Public API Exports with JSDoc

Use JSDoc tags to mark intentionally public exports. Configure Knip to exclude tagged exports from unused export reports.

**Incorrect (public API reported as unused):**

```typescript
// src/index.ts
/** This is part of the public API */
export const publicUtil = () => {}
```

Knip reports: `publicUtil` is unused.

**Correct (tagged export excluded):**

```typescript
// src/index.ts
/**
 * This is part of the public API
 * @public
 */
export const publicUtil = () => {}
```

```json
{
  "tags": ["-public"]
}
```

The `-` prefix excludes exports with the `@public` tag.

**Include only specific tags:**

```json
{
  "tags": ["+internal", "+deprecated"]
}
```

Reports only exports with `@internal` or `@deprecated` tags.

Reference: [Rules & Filters](https://knip.dev/features/rules-and-filters)
