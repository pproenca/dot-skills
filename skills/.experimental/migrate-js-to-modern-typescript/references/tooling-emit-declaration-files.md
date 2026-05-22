---
title: Emit Declaration Files for Migrated Libraries
impact: LOW-MEDIUM
impactDescription: preserves types for downstream consumers
tags: tooling, declaration, dts, publishing
---

## Emit Declaration Files for Migrated Libraries

A migrated library that publishes only compiled JavaScript forces every consumer back to `any`, discarding the types you spent the migration adding. Setting `declaration: true` emits `.d.ts` files, and pointing the package's `types` field at them publishes the contract so downstream projects keep type-checking against your library.

**Incorrect (ship JS only — consumers lose all types):**

```json
{
  "compilerOptions": {
    "declaration": false,
    "outDir": "dist"
  }
}
```

With `package.json` `"main": "dist/index.js"` and no `"types"` field, every
importer of this library gets `any`.

**Correct (emit and publish declarations):**

```json
{
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true,
    "outDir": "dist"
  }
}
```

Add `"types": "dist/index.d.ts"` to `package.json` so consumers resolve the
emitted declarations; `declarationMap` lets their editors jump to your source.

Reference: [tsconfig: declaration](https://www.typescriptlang.org/tsconfig/#declaration)
