---
title: Extract Shared Response Logic into Resolvers
impact: CRITICAL
impactDescription: Eliminates duplication; ensures consistent mock responses across tests
tags: handler, resolver, reuse, abstraction, dry
---

## Extract Shared Response Logic into Resolvers

Extract repetitive response logic into reusable resolver functions. This ensures consistency across handlers and reduces maintenance when response shapes change.

**Incorrect (duplicated response logic):**

```typescript
// mocks/handlers.ts
export const handlers = [
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John',
      email: 'john@example.com',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    })
  }),
  http.get('/api/users', () => {
    return HttpResponse.json([
      {
        id: '1',
        name: 'John',
        email: 'john@example.com',
        createdAt: new Date().toISOString(),  // Duplicated shape
        updatedAt: new Date().toISOString(),
      },
      // ... more users with same structure
    ])
  }),
]
```

**Correct (shared resolver factories):**

```typescript
// mocks/factories/user.ts
import { faker } from '@faker-js/faker'

export function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    createdAt: faker.date.past().toISOString(),
    updatedAt: faker.date.recent().toISOString(),
    ...overrides,
  }
}
```

```typescript
// mocks/handlers/user.ts
import { http, HttpResponse } from 'msw'
import { createMockUser } from '../factories/user'

export const userHandlers = [
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json(createMockUser({ id: params.id as string }))
  }),
  http.get('/api/users', () => {
    return HttpResponse.json([
      createMockUser(),
      createMockUser(),
      createMockUser(),
    ])
  }),
]
```

**Higher-order handler for cross-cutting concerns:**

```typescript
// mocks/utils/withAuth.ts
import { HttpResponse } from 'msw'
import type { HttpResponseResolver } from 'msw'

export function withAuth(resolver: HttpResponseResolver): HttpResponseResolver {
  return ({ request, ...rest }) => {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new HttpResponse(null, { status: 401 })
    }
    return resolver({ request, ...rest })
  }
}
```

**When NOT to use this pattern:**
- One-off handlers for specific test scenarios don't need abstraction

Reference: [Structuring Handlers](https://mswjs.io/docs/best-practices/structuring-handlers)
