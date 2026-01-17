---
title: Handle Cookies and Authentication
impact: MEDIUM
impactDescription: Enables session-based auth testing; validates auth flows
tags: advanced, cookies, authentication, session, auth
---

## Handle Cookies and Authentication

Access cookies from the `cookies` object in resolvers and set cookies via response headers. This enables testing of session-based authentication flows.

**Incorrect (ignoring authentication state):**

```typescript
// Always returns user regardless of auth state
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})
```

**Correct (cookie-based auth handling):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Login sets session cookie
  http.post('/api/login', async ({ request }) => {
    const { email, password } = await request.json()

    if (email === 'john@example.com' && password === 'password') {
      return HttpResponse.json(
        { user: { id: '1', email } },
        {
          headers: {
            'Set-Cookie': 'session=abc123; Path=/; HttpOnly; SameSite=Strict',
          },
        }
      )
    }

    return HttpResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    )
  }),

  // Protected endpoint checks cookie
  http.get('/api/user', ({ cookies }) => {
    if (!cookies.session) {
      return HttpResponse.json(
        { error: 'Not authenticated' },
        { status: 401 }
      )
    }

    // In real app, validate session token
    return HttpResponse.json({
      id: '1',
      name: 'John',
      email: 'john@example.com',
    })
  }),

  // Logout clears cookie
  http.post('/api/logout', () => {
    return new HttpResponse(null, {
      status: 200,
      headers: {
        'Set-Cookie': 'session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
      },
    })
  }),
]
```

**Bearer token authentication:**

```typescript
http.get('/api/protected', ({ request }) => {
  const authHeader = request.headers.get('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    return HttpResponse.json(
      { error: 'Missing token' },
      { status: 401 }
    )
  }

  const token = authHeader.slice(7)

  // Validate token (simplified)
  if (token === 'valid-token') {
    return HttpResponse.json({ data: 'protected content' })
  }

  return HttpResponse.json(
    { error: 'Invalid token' },
    { status: 403 }
  )
})
```

**Multiple cookies:**

```typescript
http.get('/api/preferences', ({ cookies }) => {
  return HttpResponse.json({
    theme: cookies.theme || 'light',
    language: cookies.lang || 'en',
    userId: cookies.session ? '1' : null,
  })
})
```

**When NOT to use this pattern:**
- Public endpoints that don't require authentication

Reference: [MSW Cookies](https://mswjs.io/docs/concepts/request-handler#cookies)
