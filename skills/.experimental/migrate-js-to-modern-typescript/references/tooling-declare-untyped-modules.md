---
title: Provide Ambient Declarations for Untyped Dependencies
impact: LOW-MEDIUM
impactDescription: enables builds on untyped dependencies
tags: tooling, ambient-declarations, modules, declare
---

## Provide Ambient Declarations for Untyped Dependencies

Importing a JavaScript-only package with no bundled or community types errors under `noImplicitAny` ("Could not find a declaration file"). Casting the whole import to `any` unblocks it but disables checking for everything that package exports, forever. A `declare module` stub scopes the gap to the exact functions you use and marks the dependency for proper typing later.

**Incorrect (cast the module to any — checking off for all of it):**

```typescript
// Disables type checking for everything legacy-charts exports.
const charts = require("legacy-charts") as any
charts.render(el, series)
```

**Correct (ambient declaration scopes and types the gap):**

```typescript
// types/legacy-charts.d.ts
declare module "legacy-charts" {
  export function render(el: HTMLElement, series: ChartSeries[]): void
}

// chart-view.ts — now typed and import-based
import { render } from "legacy-charts"
render(el, series)
```

Reference: [TypeScript Handbook: Declaration Files](https://www.typescriptlang.org/docs/handbook/declaration-files/introduction.html)
