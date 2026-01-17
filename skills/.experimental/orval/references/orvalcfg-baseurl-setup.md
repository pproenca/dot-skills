---
title: Configure Base URL Properly
impact: CRITICAL
impactDescription: prevents 404 errors in production, enables environment switching
tags: orvalcfg, baseUrl, environment, deployment
---

## Configure Base URL Properly

Configure the base URL through the mutator or config, not hardcoded in generated code. Orval's default fetch functions don't include a base URL, causing 404s when frontend and backend are on different domains.

**Incorrect (no base URL configuration):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No baseUrl - requests go to relative paths
    },
  },
});
```

**Generated code makes relative requests:**
```typescript
// Calls /users instead of https://api.example.com/users
fetch('/users')  // 404 if frontend is on different domain
```

**Correct (base URL via mutator):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customFetch',
        },
      },
    },
  },
});
```

```typescript
// src/api/mutator.ts
const BASE_URL = import.meta.env.VITE_API_URL || 'https://api.example.com';

export const customFetch = async <T>(config: RequestInit & { url: string }): Promise<T> => {
  const response = await fetch(`${BASE_URL}${config.url}`, config);

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }

  return response.json();
};
```

**Alternative (from OpenAPI servers):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      baseUrl: {
        getFromServers: true,  // Use servers[0].url from spec
      },
    },
  },
});
```

Reference: [Orval baseUrl Configuration](https://orval.dev/reference/configuration/output)
