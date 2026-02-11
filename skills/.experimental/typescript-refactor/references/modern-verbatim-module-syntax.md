---
title: Enable verbatimModuleSyntax for Explicit Import Types
impact: MEDIUM
impactDescription: prevents runtime import of type-only modules
tags: modern, verbatim-module-syntax, imports, tree-shaking
---

## Enable verbatimModuleSyntax for Explicit Import Types

`verbatimModuleSyntax` (TS 5.0+) requires `import type` for type-only imports and emits imports exactly as written. This eliminates accidental runtime imports of type-only modules, improves tree-shaking, and makes the intent of every import explicit.

**Incorrect (type import looks like value import):**

```typescript
// tsconfig.json: no verbatimModuleSyntax
import { User, createUser } from "./user"

// User is only used as a type, but emitted as runtime import
// Bundler must figure out it's unused — fragile
function greet(user: User) {
  return `Hello, ${user.name}`
}
```

**Correct (explicit import type):**

```typescript
// tsconfig.json: "verbatimModuleSyntax": true
import type { User } from "./user"
import { createUser } from "./user"

// Clear intent: User is compile-time only, createUser is runtime
function greet(user: User) {
  return `Hello, ${user.name}`
}
```

Reference: [TypeScript 5.0 - verbatimModuleSyntax](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html)
