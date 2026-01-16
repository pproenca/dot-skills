---
title: Create Feature-Specific Test Utilities
impact: MEDIUM
impactDescription: Reduces test boilerplate; ensures consistent test setup
tags: test, utilities, helpers, fixtures
---

## Create Feature-Specific Test Utilities

Each feature should have its own test utilities: factories, fixtures, and render wrappers. Shared test utilities become coupled to all features and are hard to maintain.

**Incorrect (global test utilities):**

```typescript
// src/testing/utils.ts - One file for all features
export function createMockUser() { ... }
export function createMockProduct() { ... }
export function createMockOrder() { ... }
export function renderWithProviders(ui: ReactNode) {
  return render(ui, {
    wrapper: ({ children }) => (
      <QueryClientProvider client={queryClient}>
        <UserProvider>
          <CartProvider>
            <NotificationProvider>
              {children}
            </NotificationProvider>
          </CartProvider>
        </UserProvider>
      </QueryClientProvider>
    ),
  });
}
```

**Correct (feature-specific utilities):**

```typescript
// src/features/user/testing/factories.ts
export function createUser(overrides?: Partial<User>): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    ...overrides,
  };
}

// src/features/user/testing/render.tsx
export function renderUserFeature(ui: ReactNode) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return render(ui, {
    wrapper: ({ children }) => (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    ),
  });
}

// src/features/user/testing/index.ts
export { createUser } from './factories';
export { renderUserFeature } from './render';

// Usage in tests
import { createUser, renderUserFeature } from '../testing';

describe('UserProfile', () => {
  it('displays user name', () => {
    const user = createUser({ name: 'Jane Doe' });
    renderUserFeature(<UserProfile user={user} />);
    expect(screen.getByText('Jane Doe')).toBeInTheDocument();
  });
});
```

**Shared testing utilities (truly generic):**

```typescript
// src/shared/testing/query-client.ts
export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
}
```

Reference: [Testing Library - Setup](https://testing-library.com/docs/react-testing-library/setup)
