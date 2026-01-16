---
title: Enable Clean Mode for Consistent Regeneration
impact: HIGH
impactDescription: prevents stale files, ensures deterministic output
tags: output, clean, regeneration, consistency
---

## Enable Clean Mode for Consistent Regeneration

Enable `clean` mode to remove old generated files before regeneration. Without it, deleted endpoints leave orphan files that cause import errors or ship dead code.

**Incorrect (no clean mode):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No clean - old files persist
    },
  },
});
```

**Problem scenario:**
1. API has `/users` and `/orders` endpoints
2. Orval generates `users.ts` and `orders.ts`
3. Backend removes `/orders` endpoint
4. Regenerate: `users.ts` updated, `orders.ts` still exists
5. Code still imports from `orders.ts` - builds but crashes at runtime

**Correct (with clean mode):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      clean: true,  // Delete target directory before generation
    },
  },
});
```

**For selective cleaning:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      clean: ['src/api/endpoints'],  // Only clean specific directories
    },
  },
});
```

**When NOT to use this pattern:**
- When target directory contains hand-written code
- Use selective array syntax to protect specific paths

Reference: [Orval clean Option](https://orval.dev/reference/configuration/output)
