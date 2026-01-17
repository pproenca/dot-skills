---
title: Set Response Headers Correctly
impact: HIGH
impactDescription: Ensures CORS, caching, and authentication headers work as expected
tags: response, headers, cors, cache-control, authentication
---

## Set Response Headers Correctly

Set appropriate response headers to simulate real API behavior. Headers like `Set-Cookie`, `Cache-Control`, and CORS headers affect how your application handles responses.

**Incorrect (missing important headers):**

```typescript
http.post('/api/login', () => {
  // Missing Set-Cookie header - authentication won't work
  return HttpResponse.json({ user: { id: '1' } })
})

http.get('/api/data', () => {
  // Missing caching headers - can't test cache behavior
  return HttpResponse.json({ data: 'value' })
})
```

**Correct (explicit headers):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Authentication with cookies
  http.post('/api/login', () => {
    return HttpResponse.json(
      { user: { id: '1', name: 'John' } },
      {
        headers: {
          'Set-Cookie': 'session=abc123; Path=/; HttpOnly',
        },
      }
    )
  }),

  // Caching headers
  http.get('/api/static-data', () => {
    return HttpResponse.json(
      { version: '1.0' },
      {
        headers: {
          'Cache-Control': 'public, max-age=3600',
          'ETag': '"abc123"',
        },
      }
    )
  }),

  // No-cache for dynamic data
  http.get('/api/user', () => {
    return HttpResponse.json(
      { name: 'John' },
      {
        headers: {
          'Cache-Control': 'no-store',
        },
      }
    )
  }),

  // Pagination headers
  http.get('/api/users', () => {
    return HttpResponse.json(
      [{ id: '1' }, { id: '2' }],
      {
        headers: {
          'X-Total-Count': '100',
          'X-Page': '1',
          'X-Per-Page': '10',
          'Link': '</api/users?page=2>; rel="next"',
        },
      }
    )
  }),

  // Rate limiting headers
  http.get('/api/limited', () => {
    return HttpResponse.json(
      { data: 'value' },
      {
        headers: {
          'X-RateLimit-Limit': '100',
          'X-RateLimit-Remaining': '99',
          'X-RateLimit-Reset': String(Date.now() + 3600000),
        },
      }
    )
  }),
]
```

**Testing rate limit handling:**

```typescript
it('shows rate limit warning when approaching limit', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.json(
        { data: 'value' },
        {
          headers: {
            'X-RateLimit-Remaining': '5',
          },
        }
      )
    })
  )

  render(<DataFetcher />)
  expect(await screen.findByText('Rate limit warning')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Tests not concerned with header-specific behavior can omit custom headers

Reference: [MSW HttpResponse Options](https://mswjs.io/docs/api/http-response)
