---
title: Export Body Type Wrapper for Request Transformation
impact: HIGH
impactDescription: enables consistent request body preprocessing
tags: mutator, body, transformation, serialization
---

## Export Body Type Wrapper for Request Transformation

Export a `BodyType` wrapper when you need to preprocess all request bodies. This is essential when your API expects a different format than your TypeScript types.

**Incorrect (no body transformation):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return axios(config).then(({ data }) => data);
};
// API expects snake_case but TypeScript uses camelCase
```

**Request bodies sent in wrong format:**
```typescript
// TypeScript type uses camelCase
const user = { firstName: 'John', lastName: 'Doe' };
createUser(user);
// API receives { firstName, lastName } but expects { first_name, last_name }
```

**Correct (with body wrapper):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';
import { decamelizeKeys } from 'humps';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios(config).then(({ data }) => data);
};

// Wrapper that converts camelCase to snake_case
export type BodyType<D> = D;

export const bodySerializer = <D>(data: D): unknown => {
  return decamelizeKeys(data as Record<string, unknown>);
};
```

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customInstance',
        },
        requestBodyTransformer: {
          path: './src/api/mutator.ts',
          name: 'bodySerializer',
        },
      },
    },
  },
});
```

**Now works correctly:**
```typescript
const user = { firstName: 'John', lastName: 'Doe' };
createUser(user);
// API receives { first_name: 'John', last_name: 'Doe' }
```

Reference: [Orval Body Type](https://orval.dev/guides/custom-axios)
