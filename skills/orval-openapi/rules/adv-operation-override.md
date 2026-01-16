---
title: Override Settings per Operation
impact: LOW
impactDescription: customizes individual endpoints without affecting others
tags: adv, override, operations, customization
---

## Override Settings per Operation

Use operation-specific overrides when certain endpoints need different configuration. This is cleaner than using a transformer for simple customizations.

**Use case:** Most endpoints use default options, but one needs custom mock data

**Incorrect (global change affects all):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 2000,  // Slow delay for all endpoints
      },
    },
  },
});
```

**Correct (per-operation override):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      mock: true,
      override: {
        operations: {
          uploadFile: {
            mock: {
              delay: 3000,  // Slow upload simulation
            },
          },
          getHealthCheck: {
            query: {
              options: {
                staleTime: Infinity,  // Never refetch
                gcTime: Infinity,
              },
            },
          },
          createPayment: {
            mutator: {
              path: './src/api/payment-mutator.ts',
              name: 'paymentInstance',  // Special auth for payments
            },
          },
        },
      },
    },
  },
});
```

**Override by tags:**

```typescript
export default defineConfig({
  api: {
    output: {
      override: {
        tags: {
          admin: {
            mutator: {
              path: './src/api/admin-mutator.ts',
              name: 'adminInstance',
            },
          },
        },
      },
    },
  },
});
```

**Available per-operation overrides:**
- `mutator` - Custom HTTP client
- `query` - React Query options
- `mock` - Mock data and delays
- `transformer` - Output transformation
- `formData` / `formUrlEncoded` - Serialization

Reference: [Orval Operations Override](https://orval.dev/reference/configuration/output)
