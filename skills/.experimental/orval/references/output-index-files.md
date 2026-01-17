---
title: Generate Index Files for Clean Imports
impact: HIGH
impactDescription: simplifies imports, enables barrel exports
tags: output, indexFiles, imports, barrel
---

## Generate Index Files for Clean Imports

Enable index file generation for cleaner imports. Without index files, consumers must import from deeply nested paths.

**Incorrect (no index files):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      mode: 'tags-split',
      // No indexFiles - deep imports required
    },
  },
});
```

**Consumer must use deep imports:**
```typescript
import { useGetUser } from '@/api/users/users';
import { useGetOrder } from '@/api/orders/orders';
import { User } from '@/api/users/users.schemas';
```

**Correct (with index files):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      mode: 'tags-split',
      indexFiles: true,
    },
  },
});
```

**Generated structure:**
```plaintext
src/api/
├── index.ts          # Re-exports all
├── users/
│   ├── index.ts      # Re-exports users hooks
│   └── users.ts
└── orders/
    ├── index.ts
    └── orders.ts
```

**Clean consumer imports:**
```typescript
import { useGetUser, useGetOrder } from '@/api';
// Or scoped:
import { useGetUser } from '@/api/users';
```

**When NOT to use this pattern:**
- When using `single` mode (already one file)
- When tree-shaking is critical and barrel files hurt bundler analysis

Reference: [Orval indexFiles Option](https://orval.dev/reference/configuration/output)
