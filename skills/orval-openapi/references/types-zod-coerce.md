---
title: Use Zod Coercion for Type Transformations
impact: MEDIUM
impactDescription: automatic string-to-Date, string-to-number conversions
tags: types, zod, coercion, transformation
---

## Use Zod Coercion for Type Transformations

Enable Zod coercion to automatically convert string values to proper types. APIs often return dates as strings; coercion converts them to Date objects.

**Incorrect (no coercion):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      // No coercion - dates remain strings
    },
  },
});
```

**Dates are strings, not Date objects:**
```typescript
const { data: user } = useGetUser(userId);

// TypeScript thinks createdAt is Date, but it's actually string
user.createdAt.toLocaleDateString();  // Runtime error: toLocaleDateString is not a function

// Must manually convert
const date = new Date(user.createdAt);
```

**Correct (coercion enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      override: {
        zod: {
          coerce: {
            response: ['date'],  // Coerce date strings to Date
            query: ['string', 'number', 'boolean'],  // Coerce query params
          },
        },
      },
    },
  },
});
```

**Dates are properly converted:**
```typescript
const { data: user } = useGetUser(userId);

// createdAt is now a real Date object
user.createdAt.toLocaleDateString();  // Works!
```

**Available coercion types:**
- `date` - ISO date strings → Date objects
- `number` - Numeric strings → numbers
- `boolean` - "true"/"false" strings → booleans
- `bigint` - Large integer strings → BigInt
- `string` - Any value → string

Reference: [Orval Zod Coercion](https://orval.dev/reference/configuration/output)
