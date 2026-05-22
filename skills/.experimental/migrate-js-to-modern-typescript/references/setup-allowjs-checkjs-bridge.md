---
title: Enable allowJs and checkJs for Incremental Migration
impact: CRITICAL
impactDescription: enables file-by-file migration without big-bang rewrites
tags: setup, tsconfig, allowjs, checkjs, incremental
---

## Enable allowJs and checkJs for Incremental Migration

A TypeScript-only `include` forces you to rename every file before the project compiles again — the first `git mv` breaks every importer of a still-`.js` module. `allowJs` lets `.js` and `.ts` compile side by side so you migrate one file at a time, and `checkJs` type-checks the remaining JavaScript through JSDoc, finding bugs before you ever rename.

**Incorrect (TS-only — project will not build until all files are renamed):**

```json
{
  "compilerOptions": {
    "strict": true,
    "rootDir": "src"
  },
  "include": ["src/**/*.ts"]
}
```

Only `.ts` files compile, so renaming the first of 400 files breaks every
import of the modules still written in JavaScript.

**Correct (allowJs + checkJs — JS and TS coexist during the migration):**

```json
{
  "compilerOptions": {
    "strict": true,
    "allowJs": true,
    "checkJs": true,
    "rootDir": "src"
  },
  "include": ["src/**/*.ts", "src/**/*.js"]
}
```

`allowJs` keeps the build green while `.js` and `.ts` coexist, so you rename
one file at a time. `checkJs` type-checks the remaining JavaScript via JSDoc,
surfacing bugs before the rename rather than after.

Reference: [Migrating from JavaScript](https://www.typescriptlang.org/docs/handbook/migrating-from-javascript.html)
