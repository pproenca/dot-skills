---
title: Use import type for Type-Only Imports
impact: MEDIUM
impactDescription: prevents accidental runtime imports
tags: idiom, import-type, esm, isolatedmodules
---

## Use import type for Type-Only Imports

Importing a symbol with a plain `import` when you only reference it as a type forces the emitter to keep a runtime import of that module — pulling in its side effects and breaking single-file transpilers under `isolatedModules`. `import type` is erased at compile time, so the intent is explicit and no runtime dependency is created.

**Incorrect (value import used only for a type):**

```typescript
// Keeps a runtime import of ./gateway just to name its type, dragging in
// any module-level side effects and confusing isolatedModules transpilers.
import { PaymentGateway } from "./gateway.js"

function wire(gateway: PaymentGateway): void {
  register(gateway)
}
```

**Correct (import type is erased):**

```typescript
import type { PaymentGateway } from "./gateway.js"

function wire(gateway: PaymentGateway): void {
  register(gateway)
}
```

With `verbatimModuleSyntax` enabled, the compiler enforces this distinction
for you and errors on type-only symbols imported as values.

Reference: [TypeScript 3.8: Type-Only Imports](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html)
