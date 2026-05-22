---
title: Convert require and module.exports to ESM Syntax
impact: MEDIUM
impactDescription: enables typed, tree-shakeable imports
tags: idiom, esm, commonjs, imports
---

## Convert require and module.exports to ESM Syntax

CommonJS `require` returns a loosely typed value (often `any`), cannot carry `import type`, and blocks tree-shaking because the whole module object is pulled in at runtime. ESM `import`/`export` carries static types across the boundary, works with `verbatimModuleSyntax`, and matches how modern bundlers and Node's own ESM loader resolve modules.

**Incorrect (CommonJS — require erases types):**

```typescript
const { formatPrice } = require("./money") // formatPrice is any
module.exports.renderReceipt = (cents) => formatPrice(cents)
```

**Correct (ESM — types cross the import boundary):**

```typescript
import { formatPrice } from "./money.js"

export function renderReceipt(cents: number): string {
  return formatPrice(cents)
}
```

Reference: [TypeScript Handbook: Modules](https://www.typescriptlang.org/docs/handbook/2/modules.html)
