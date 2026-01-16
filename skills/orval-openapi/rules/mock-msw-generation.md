---
title: Generate MSW Handlers for Testing
impact: MEDIUM
impactDescription: enables frontend development without backend dependencies
tags: mock, msw, testing, development
---

## Generate MSW Handlers for Testing

Enable MSW mock generation to create type-safe API mocks. This enables frontend development and testing without a running backend.

**Incorrect (no mocks):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      // No mock generation - tests require real API
    },
  },
});
```

**Tests depend on live API:**
```typescript
// test must call real API or manually mock every endpoint
test('displays user profile', async () => {
  // No easy way to mock API responses
});
```

**Correct (MSW mocks enabled):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      mock: true,  // Generate MSW handlers
    },
  },
});
```

**Generated mock handlers:**
```typescript
// Generated: src/api/users/users.msw.ts
import { http, HttpResponse } from 'msw';
import { getGetUserMock } from './users.mock';

export const getGetUserMockHandler = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock());
  });
};

export const getUsersMockHandlers = () => [
  getGetUserMockHandler(),
  // ... other handlers
];
```

**Use in tests:**
```typescript
import { setupServer } from 'msw/node';
import { getUsersMockHandlers } from '@/api/users/users.msw';

const server = setupServer(...getUsersMockHandlers());

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('displays user profile', async () => {
  render(<UserProfile userId="123" />);
  await screen.findByText(/john doe/i);  // Uses mock data
});
```

Reference: [MSW Documentation](https://mswjs.io/docs/)
