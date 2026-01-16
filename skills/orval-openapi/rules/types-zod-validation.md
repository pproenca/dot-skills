---
title: Generate Zod Schemas for Runtime Validation
impact: MEDIUM
impactDescription: catches API contract violations at runtime
tags: types, zod, validation, runtime
---

## Generate Zod Schemas for Runtime Validation

Generate Zod schemas alongside TypeScript types to validate API responses at runtime. TypeScript types are erased at runtime; Zod catches contract violations in production.

**Incorrect (TypeScript only):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      // No Zod - runtime type mismatches go undetected
    },
  },
});
```

**API returns unexpected data:**
```typescript
// API returns { user_name: 'John' } instead of { userName: 'John' }
const { data } = useGetUser(userId);
console.log(data.userName);  // undefined - no error thrown
```

**Correct (with Zod validation):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      client: 'react-query',
      target: 'src/api/endpoints',
      schemas: 'src/api/models',
    },
  },
  apiZod: {
    input: './openapi.yaml',
    output: {
      mode: 'tags-split',
      client: 'zod',
      target: 'src/api/endpoints',
      fileExtension: '.zod.ts',
    },
  },
});
```

**Validate in mutator:**
```typescript
// mutator.ts
import { userSchema } from '@/api/endpoints/users.zod';

export const customInstance = async <T>(
  config: AxiosRequestConfig,
  schema?: ZodSchema<T>
): Promise<T> => {
  const response = await axios(config);

  if (schema) {
    return schema.parse(response.data);  // Throws if invalid
  }

  return response.data;
};
```

**Benefits:**
- Catches API breaking changes immediately
- Clear error messages with Zod's error formatting
- Can coerce types (string dates to Date objects)

**When NOT to use this pattern:**
- Internal APIs with strict contracts where validation overhead isn't justified
- Performance-critical paths where parsing overhead matters
- Very small projects where TypeScript alone provides sufficient safety

Reference: [Orval Zod Client](https://orval.dev/guides/client-with-zod)
