---
title: Enable isolatedModules and noEmitOnError for Safe Output
impact: MEDIUM-HIGH
impactDescription: prevents emitting broken JavaScript
tags: setup, isolatedmodules, noemitonerror, transpiler
---

## Enable isolatedModules and noEmitOnError for Safe Output

Single-file transpilers (esbuild, swc, Babel) compile each file in isolation, so they cannot resolve const enums or tell whether a re-export is a type or a value — and silently emit wrong output. `isolatedModules` flags these patterns at design time, and `noEmitOnError` stops `tsc` from shipping JavaScript built from code that does not type-check.

**Incorrect (transpiler-unsafe re-export, emitted anyway):**

```typescript
// A single-file transpiler cannot tell `Money` is a type, so it emits a
// runtime re-export that fails at load time.
export { Money } from "./money.js"
```

**Correct (isolatedModules-safe, no emit on error):**

```typescript
// `export type` marks this as carrying no runtime value, so every
// transpiler erases it correctly.
export type { Money } from "./money.js"

// In tsconfig: "isolatedModules": true and "noEmitOnError": true
```

Reference: [tsconfig: isolatedModules](https://www.typescriptlang.org/tsconfig/#isolatedModules)
