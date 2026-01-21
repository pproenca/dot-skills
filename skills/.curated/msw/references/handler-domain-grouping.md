---
title: Group Handlers by Domain
impact: CRITICAL
impactDescription: Reduces maintenance overhead; scales to large APIs without N×M complexity
tags: handler, organization, domain, modules, scalability
---

## Group Handlers by Domain

Split handlers into separate files organized by domain or feature area. This prevents a single handlers file from becoming unmanageable and enables selective handler composition for different test scenarios.

**Incorrect (monolithic handler file):**

```typescript
// mocks/handlers.ts - 500+ lines, unmaintainable
export const handlers = [
  // User endpoints
  http.get('/api/user', () => { /* ... */ }),
  http.post('/api/user', () => { /* ... */ }),
  http.delete('/api/user/:id', () => { /* ... */ }),
  // Auth endpoints
  http.post('/api/login', () => { /* ... */ }),
  http.post('/api/logout', () => { /* ... */ }),
  // Product endpoints
  http.get('/api/products', () => { /* ... */ }),
  // ... 50 more endpoints mixed together
]
```

**Correct (domain-organized handlers):**

```typescript
// mocks/handlers/user.ts
import { http, HttpResponse } from 'msw'

export const userHandlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John' })
  }),
  http.post('/api/user', async ({ request }) => {
    const user = await request.json()
    return HttpResponse.json(user, { status: 201 })
  }),
  http.delete('/api/user/:id', ({ params }) => {
    return new HttpResponse(null, { status: 204 })
  }),
]
```

```typescript
// mocks/handlers/auth.ts
import { http, HttpResponse } from 'msw'

export const authHandlers = [
  http.post('/api/login', async ({ request }) => {
    const { email, password } = await request.json()
    return HttpResponse.json({ token: 'jwt-token' })
  }),
  http.post('/api/logout', () => {
    return new HttpResponse(null, { status: 200 })
  }),
]
```

```typescript
// mocks/handlers/index.ts - compose all handlers
import { userHandlers } from './user'
import { authHandlers } from './auth'
import { productHandlers } from './products'

export const handlers = [
  ...userHandlers,
  ...authHandlers,
  ...productHandlers,
]
```

**When NOT to use this pattern:**
- Small projects with fewer than 10 endpoints may use a single file

Reference: [Structuring Handlers - Group by Domain](https://mswjs.io/docs/best-practices/structuring-handlers)
