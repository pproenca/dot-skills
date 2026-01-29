---
title: Ignore Exports Used in Same File
impact: MEDIUM-HIGH
impactDescription: allows internal helper exports without noise
tags: exports, internal, helpers, organization
---

## Ignore Exports Used in Same File

Exports used only within the same file (for testing or organization) can be excluded from reports using `ignoreExportsUsedInFile`.

**Incorrect (internal helpers reported as unused exports):**

```typescript
// src/math.ts
export const add = (a: number, b: number) => a + b
export const multiply = (a: number, b: number) => a * b

// Only used in this file for complex calculations
export const complexCalc = (x: number) => multiply(add(x, 1), 2)
```

Knip reports: `add`, `multiply` unused (only used internally).

**Correct (same-file usage ignored):**

```json
{
  "ignoreExportsUsedInFile": true
}
```

Now `add` and `multiply` are not reported because they're used within `math.ts`.

**Fine-grained control:**

```json
{
  "ignoreExportsUsedInFile": {
    "interface": true,
    "type": true
  }
}
```

Ignores only type-level exports used in the same file.

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
