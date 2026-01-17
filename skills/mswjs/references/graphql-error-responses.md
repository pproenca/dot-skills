---
title: Return GraphQL Errors in Correct Format
impact: MEDIUM
impactDescription: Ensures GraphQL clients parse errors correctly; tests error handling
tags: graphql, errors, format, validation, response
---

## Return GraphQL Errors in Correct Format

Return GraphQL errors in the standard `errors` array format. GraphQL errors are different from HTTP errors - they use status 200 with an `errors` field in the response body.

**Incorrect (HTTP-style error response):**

```typescript
// GraphQL clients won't recognize this as a GraphQL error
graphql.query('GetUser', () => {
  return HttpResponse.json(
    { error: 'User not found' },
    { status: 404 }
  )
})
```

**Correct (GraphQL error format):**

```typescript
import { graphql, HttpResponse } from 'msw'

export const handlers = [
  // Single error
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'User not found',
          extensions: {
            code: 'NOT_FOUND',
          },
        },
      ],
    })
  }),

  // Validation errors with paths
  graphql.mutation('CreateUser', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'Invalid email format',
          path: ['createUser', 'email'],
          extensions: {
            code: 'VALIDATION_ERROR',
            field: 'email',
          },
        },
        {
          message: 'Name is required',
          path: ['createUser', 'name'],
          extensions: {
            code: 'VALIDATION_ERROR',
            field: 'name',
          },
        },
      ],
    })
  }),

  // Partial success with errors
  graphql.query('GetUsers', () => {
    return HttpResponse.json({
      data: {
        users: [
          { id: '1', name: 'John' },
          null,  // This user failed to load
          { id: '3', name: 'Jane' },
        ],
      },
      errors: [
        {
          message: 'Failed to load user',
          path: ['users', 1],
          extensions: { code: 'INTERNAL_ERROR' },
        },
      ],
    })
  }),

  // Authentication error
  graphql.query('GetPrivateData', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'Not authenticated',
          extensions: {
            code: 'UNAUTHENTICATED',
          },
        },
      ],
    })
  }),
]
```

**Network-level errors (rare):**

```typescript
// For complete request failures, use HTTP error
graphql.query('GetUser', () => {
  return HttpResponse.error()  // Network failure
})
```

**When NOT to use this pattern:**
- True network failures (DNS, connection) use `HttpResponse.error()`

Reference: [GraphQL Spec - Errors](https://spec.graphql.org/October2021/#sec-Errors)
