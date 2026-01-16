---
title: Configure Consistent Naming Conventions
impact: HIGH
impactDescription: prevents casing mismatches, improves code consistency
tags: output, naming, camelCase, snake_case
---

## Configure Consistent Naming Conventions

Configure naming conventions to match your codebase style. APIs often use snake_case while TypeScript prefers camelCase, causing inconsistent property access.

**Incorrect (no naming convention):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No namingConvention - uses whatever API returns
    },
  },
});
```

**Generated types mirror API casing:**
```typescript
interface User {
  first_name: string;  // snake_case from API
  last_name: string;
  created_at: string;
}

// Inconsistent with TypeScript conventions
const fullName = `${user.first_name} ${user.last_name}`;
```

**Correct (with camelCase conversion):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        namingConvention: {
          property: 'camelCase',
        },
      },
    },
  },
});
```

**Generated types use camelCase:**
```typescript
interface User {
  firstName: string;
  lastName: string;
  createdAt: string;
}

// Consistent TypeScript style
const fullName = `${user.firstName} ${user.lastName}`;
```

**Important:** You need a mutator to transform runtime data:

```typescript
// mutator.ts
import { camelizeKeys } from 'humps';

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, config);
  const data = await response.json();
  return camelizeKeys(data) as T;
};
```

Reference: [Orval namingConvention](https://orval.dev/reference/configuration/output)
