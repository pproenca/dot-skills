---
title: Use Named Exports Over Default Exports
impact: CRITICAL
impactDescription: catches import typos at compile time
tags: module, exports, named-exports, tree-shaking
---

## Use Named Exports Over Default Exports

Named exports error when import statements try to import something that hasn't been declared, catching typos and refactoring mistakes at compile time.

**Incorrect (default export allows any import name):**

```typescript
// user.ts
export default class User {
  constructor(public name: string) {}
}

// main.ts
import Usr from './user'  // Typo not caught - silently works
```

**Correct (named export catches typos):**

```typescript
// user.ts
export class User {
  constructor(public name: string) {}
}

// main.ts
import { Usr } from './user'  // Error: Module has no exported member 'Usr'
import { User } from './user'  // Correct
```

**Benefits:**
- Compile-time error detection for typos
- Better tree-shaking in bundlers
- Consistent import names across codebase
- Easier refactoring with IDE support

Reference: [Google TypeScript Style Guide - Export visibility](https://google.github.io/styleguide/tsguide.html#export-visibility)
