---
title: Generate Mock Index Files for Easy Setup
impact: MEDIUM
impactDescription: single import for all mock handlers
tags: mock, index, organization, setup
---

## Generate Mock Index Files for Easy Setup

Enable mock index files when using tags-split mode. This provides a single import point for all mock handlers.

**Incorrect (manual handler aggregation):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      mock: true,
      // No indexFiles for mocks
    },
  },
});
```

**Manual handler collection:**
```typescript
// test-setup.ts
import { getUsersMockHandlers } from '@/api/users/users.msw';
import { getOrdersMockHandlers } from '@/api/orders/orders.msw';
import { getProductsMockHandlers } from '@/api/products/products.msw';
// ... import every tag manually

const server = setupServer(
  ...getUsersMockHandlers(),
  ...getOrdersMockHandlers(),
  ...getProductsMockHandlers(),
  // ... spread every tag manually
);
```

**Correct (mock index files):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      mock: {
        type: 'msw',
        indexFiles: true,  // Generate index.msw.ts
      },
    },
  },
});
```

**Generated index file:**
```typescript
// Generated: src/api/index.msw.ts
import { getUsersMockHandlers } from './users/users.msw';
import { getOrdersMockHandlers } from './orders/orders.msw';
import { getProductsMockHandlers } from './products/products.msw';

export const handlers = [
  ...getUsersMockHandlers(),
  ...getOrdersMockHandlers(),
  ...getProductsMockHandlers(),
];
```

**Clean test setup:**
```typescript
// test-setup.ts
import { setupServer } from 'msw/node';
import { handlers } from '@/api/index.msw';

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

Reference: [Orval Mock indexFiles](https://orval.dev/reference/configuration/output)
