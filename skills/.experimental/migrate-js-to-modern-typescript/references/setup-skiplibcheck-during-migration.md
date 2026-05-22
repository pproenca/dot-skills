---
title: Set skipLibCheck to Silence Third-Party Type Noise
impact: HIGH
impactDescription: reduces error noise from untyped dependencies
tags: setup, skiplibcheck, tsconfig, dependencies
---

## Set skipLibCheck to Silence Third-Party Type Noise

Conflicting or outdated `@types` packages can emit hundreds of errors inside `node_modules/**/*.d.ts` that have nothing to do with your code, burying the errors you can actually fix. `skipLibCheck` checks how *your* code uses declaration files but skips checking the declaration files internally, so the error list reflects your migration, not your dependencies' bugs.

**Incorrect (libs checked — your real errors drown in dependency noise):**

```json
{
  "compilerOptions": {
    "strict": true,
    "allowJs": true,
    "skipLibCheck": false
  }
}
```

A single mismatch between `@types/express` and `@types/node` versions can
print 200+ errors from `node_modules`, hiding the dozen errors in your `src`.

**Correct (skipLibCheck on — only your usage is checked):**

```json
{
  "compilerOptions": {
    "strict": true,
    "allowJs": true,
    "skipLibCheck": true
  }
}
```

Your code is still fully type-checked against library types; only the
libraries' own internal declarations are skipped. Worth re-evaluating once
the migration is finished.

Reference: [tsconfig: skipLibCheck](https://www.typescriptlang.org/tsconfig/#skipLibCheck)
