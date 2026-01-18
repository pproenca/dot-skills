---
title: Avoid TypeScript Namespaces
impact: CRITICAL
impactDescription: prevents runtime overhead and enables tree-shaking
tags: module, namespace, organization, tree-shaking
---

## Avoid TypeScript Namespaces

TypeScript namespaces create runtime objects that prevent tree-shaking and add unnecessary overhead. Use ES6 modules for code organization.

**Incorrect (TypeScript namespace):**

```typescript
namespace MyApp {
  export interface User {
    name: string
  }

  export function createUser(name: string): User {
    return { name }
  }
}

// Usage
const user = MyApp.createUser('Alice')
// Compiles to runtime object with all exports bundled
```

**Correct (ES6 modules):**

```typescript
// user.ts
export interface User {
  name: string
}

export function createUser(name: string): User {
  return { name }
}

// main.ts
import { createUser } from './user'
const user = createUser('Alice')
// Tree-shakeable, no runtime overhead
```

**Exception:** Namespaces may be required when interfacing with external third-party code that uses them.

Reference: [Google TypeScript Style Guide - Namespaces vs Modules](https://google.github.io/styleguide/tsguide.html#namespaces-vs-modules)
