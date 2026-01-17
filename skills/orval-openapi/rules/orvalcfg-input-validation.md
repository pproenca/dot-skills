---
title: Validate OpenAPI Spec Before Generation
impact: CRITICAL
impactDescription: prevents silent failures and incorrect type generation
tags: config, input, validation, openapi
---

## Validate OpenAPI Spec Before Generation

Enable input validation to catch OpenAPI spec issues before code generation. Silent failures from invalid specs create subtle bugs that surface at runtime.

**Incorrect (no validation):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      // No validation - invalid specs generate broken code
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**Correct (with validation):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      validation: true,  // Validate spec before generation
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**For remote specs, add filters:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: 'https://api.example.com/openapi.json',
      validation: true,
      filters: {
        tags: ['users', 'orders'],  // Only generate for specific tags
      },
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**Common validation catches:**
- Missing `$ref` targets
- Invalid schema types
- Duplicate operationIds
- Malformed response definitions

Reference: [Orval Input Configuration](https://orval.dev/reference/configuration/input)
