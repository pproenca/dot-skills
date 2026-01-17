---
title: Use Output Transformer for Generated Code Modification
impact: LOW
impactDescription: 1 transformer vs N manual modifications across all generated functions
tags: adv, transformer, output, generation
---

## Use Output Transformer for Generated Code Modification

Use an output transformer to modify generated code before it's written. This enables adding custom logic, modifying function signatures, or injecting metadata.

**Incorrect (manual modification of each mutation):**

```typescript
// Manually adding analytics to every mutation - error-prone
const createUser = useCreateUser({
  onSuccess: () => {
    analytics.track('createUser');  // Must add to every mutation
  },
});

const updateUser = useUpdateUser({
  onSuccess: () => {
    analytics.track('updateUser');  // Repeated N times
  },
});
```

**Correct (output transformer):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      override: {
        transformer: './scripts/add-analytics.ts',
      },
    },
  },
});
```

```typescript
// scripts/add-analytics.ts
import { GeneratorVerbOptions } from '@orval/core';

export default (verbOptions: GeneratorVerbOptions): GeneratorVerbOptions => {
  // Only modify mutations
  if (verbOptions.verb !== 'post' && verbOptions.verb !== 'put' &&
      verbOptions.verb !== 'delete' && verbOptions.verb !== 'patch') {
    return verbOptions;
  }

  // Add analytics comment to generated code
  const originalImplementation = verbOptions.implementation;

  return {
    ...verbOptions,
    implementation: `
      // Analytics: ${verbOptions.operationId}
      ${originalImplementation}
    `,
  };
};
```

**Other transformer use cases:**
- Add deprecation warnings
- Inject logging
- Modify type names
- Add custom JSDoc comments

**When NOT to use this pattern:**
- Simple config changes (use override.operations instead)
- Need to change HTTP behavior (use mutator instead)
- Need to modify spec before generation (use input transformer)

Reference: [Orval Output Transformer](https://orval.dev/reference/configuration/output)
