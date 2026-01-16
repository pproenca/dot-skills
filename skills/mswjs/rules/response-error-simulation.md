---
title: Simulate Error Responses Correctly
impact: HIGH
impactDescription: Validates error handling; catches missing error states in UI
tags: response, error, status, network-error, HttpResponse
---

## Simulate Error Responses Correctly

Use proper HTTP status codes and `HttpResponse.error()` for network errors. Different error types require different handling in your application, and correct simulation ensures your error handling works.

**Incorrect (ambiguous error responses):**

```typescript
// Unclear what type of error this represents
http.get('/api/user', () => {
  return HttpResponse.json({ error: 'Something went wrong' })
})

// Missing status code - defaults to 200!
http.get('/api/user', () => {
  return new HttpResponse('Error occurred')
})
```

**Correct (explicit error types):**

```typescript
import { http, HttpResponse } from 'msw'

// HTTP 4xx - Client errors
http.get('/api/user/:id', () => {
  return HttpResponse.json(
    { error: 'User not found' },
    { status: 404 }
  )
})

http.post('/api/user', () => {
  return HttpResponse.json(
    { error: 'Validation failed', fields: ['email'] },
    { status: 400 }
  )
})

http.get('/api/protected', () => {
  return HttpResponse.json(
    { error: 'Unauthorized' },
    { status: 401 }
  )
})

http.get('/api/admin', () => {
  return HttpResponse.json(
    { error: 'Forbidden' },
    { status: 403 }
  )
})

// HTTP 5xx - Server errors
http.get('/api/user', () => {
  return HttpResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  )
})

http.get('/api/data', () => {
  return new HttpResponse(null, { status: 503 })  // Service unavailable
})

// Network error (connection failure, DNS failure, etc.)
http.get('/api/user', () => {
  return HttpResponse.error()  // Causes fetch to reject
})
```

**Testing error handling:**

```typescript
it('displays 404 message when user not found', async () => {
  server.use(
    http.get('/api/user/:id', () => {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    })
  )

  render(<UserProfile userId="999" />)
  expect(await screen.findByText('User not found')).toBeInTheDocument()
})

it('handles network failure gracefully', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.error()
    })
  )

  render(<UserProfile />)
  expect(await screen.findByText('Network error')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Happy path tests should use success responses

Reference: [MSW HttpResponse API](https://mswjs.io/docs/api/http-response)
