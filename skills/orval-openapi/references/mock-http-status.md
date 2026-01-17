---
title: Generate Mocks for All HTTP Status Codes
impact: MEDIUM
impactDescription: enables error state testing
tags: mock, errors, status, testing
---

## Generate Mocks for All HTTP Status Codes

Enable mock generation for all HTTP status codes to test error handling. By default, Orval only generates success (2xx) mocks.

**Incorrect (success mocks only):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: true,  // Only generates 200 handlers
    },
  },
});
```

**Can't test error handling:**
```typescript
test('shows error message on failure', async () => {
  // No easy way to trigger 400/500 responses
  // Must manually override handlers
});
```

**Correct (all status codes):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        generateEachHttpStatus: true,  // Generate for 400, 404, 500, etc.
      },
    },
  },
});
```

**Generated error handlers:**
```typescript
// Generated: users.msw.ts
export const getGetUserMockHandler400 = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock400(), { status: 400 });
  });
};

export const getGetUserMockHandler404 = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock404(), { status: 404 });
  });
};
```

**Test error states easily:**
```typescript
import { getGetUserMockHandler404 } from '@/api/users/users.msw';

test('shows not found message', async () => {
  server.use(getGetUserMockHandler404());

  render(<UserProfile userId="nonexistent" />);

  await screen.findByText(/user not found/i);
});

test('shows validation errors', async () => {
  server.use(getCreateUserMockHandler400());

  render(<CreateUserForm />);
  fireEvent.click(screen.getByText('Submit'));

  await screen.findByText(/email is required/i);
});
```

Reference: [Orval generateEachHttpStatus](https://orval.dev/reference/configuration/output)
