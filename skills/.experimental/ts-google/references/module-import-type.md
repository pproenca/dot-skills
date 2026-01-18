---
title: Use Import Type for Type-Only Imports
impact: HIGH
impactDescription: reduces bundle size by eliminating runtime imports
tags: module, imports, types, bundle-size
---

## Use Import Type for Type-Only Imports

When importing types that are only used for type annotations (not at runtime), use `import type` to ensure they're removed during compilation.

**Incorrect (regular import for types):**

```typescript
import { User, UserService } from './user'

// User is only used as type, UserService is used at runtime
function getUser(service: UserService, id: string): User {
  return service.get(id)
}
// 'User' import may remain in bundle depending on transpiler
```

**Correct (explicit type import):**

```typescript
import type { User } from './user'
import { UserService } from './user'

function getUser(service: UserService, id: string): User {
  return service.get(id)
}
// 'User' guaranteed to be removed from bundle
```

**Alternative (inline type modifier):**

```typescript
import { type User, UserService } from './user'
```

**Benefits:**
- Guaranteed removal of type-only imports
- Clearer intent in code review
- Prevents accidental runtime usage of types

Reference: [TypeScript 3.8 - Type-Only Imports](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html)
