---
title: Separate Schemas into Dedicated Directory
impact: CRITICAL
impactDescription: enables clean imports, prevents circular dependencies
tags: config, schemas, organization, imports
---

## Separate Schemas into Dedicated Directory

Configure a separate `schemas` directory for generated TypeScript interfaces. Mixing schemas with endpoint code creates import confusion and potential circular dependencies.

**Incorrect (schemas mixed with endpoints):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      // No schemas config - types mixed in with endpoints
    },
  },
});
```

**Resulting structure:**
```plaintext
src/api/endpoints/
├── users.ts        # Contains both User type AND useGetUser hook
├── orders.ts       # Contains both Order type AND useGetOrder hook
└── index.ts
```

**Problem:** Importing just the `User` type pulls in React Query as a dependency.

**Correct (dedicated schemas directory):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      schemas: 'src/api/models',  // Separate directory
      mode: 'tags-split',
    },
  },
});
```

**Resulting structure:**
```plaintext
src/api/
├── endpoints/
│   ├── users/
│   │   └── users.ts    # Only hooks
│   └── orders/
│       └── orders.ts
└── models/
    ├── user.ts         # Only types
    ├── order.ts
    └── index.ts
```

**Benefits:**
- Import types without pulling in runtime dependencies
- Share types with backend (monorepo)
- Cleaner dependency graph

Reference: [Orval schemas option](https://orval.dev/reference/configuration/output)
