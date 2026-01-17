---
title: Use Input Transformer for Spec Preprocessing
impact: LOW
impactDescription: fixes spec issues at source, prevents N downstream errors
tags: adv, transformer, input, preprocessing
---

## Use Input Transformer for Spec Preprocessing

Use an input transformer to modify the OpenAPI specification before code generation. This enables fixing spec issues, adding custom extensions, or filtering operations.

**Incorrect (inconsistent operationIds in spec):**

```yaml
# openapi.yaml - inconsistent naming causes inconsistent function names
paths:
  /users:
    get:
      operationId: GetAllUsers  # PascalCase - generates GetAllUsers()
  /orders:
    get:
      operationId: list_orders  # snake_case - generates list_orders()
```

**Correct (input transformer to normalize):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      transformer: './scripts/normalize-spec.ts',
    },
    output: {
      target: 'src/api',
    },
  },
});
```

```typescript
// scripts/normalize-spec.ts
import { OpenAPIObject, OperationObject } from 'openapi3-ts/oas31';

const toCamelCase = (str: string): string => {
  return str
    .replace(/[-_](.)/g, (_, char) => char.toUpperCase())
    .replace(/^(.)/, (char) => char.toLowerCase());
};

export default (spec: OpenAPIObject): OpenAPIObject => {
  const paths = spec.paths ?? {};

  for (const pathItem of Object.values(paths)) {
    for (const method of ['get', 'post', 'put', 'delete', 'patch'] as const) {
      const operation = pathItem?.[method] as OperationObject | undefined;
      if (operation?.operationId) {
        operation.operationId = toCamelCase(operation.operationId);
      }
    }
  }

  return spec;
};
```

**Other transformer use cases:**
- Remove deprecated endpoints
- Add x-custom extensions
- Merge multiple specs
- Fix nullable field definitions

Reference: [Orval Input Transformer](https://orval.dev/reference/configuration/input)
