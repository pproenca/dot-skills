---
title: Handle Batched GraphQL Queries
impact: MEDIUM
impactDescription: Supports Apollo batching; prevents unhandled batch requests
tags: graphql, batching, apollo, performance, advanced
---

## Handle Batched GraphQL Queries

Create a custom handler for batched GraphQL queries when using Apollo Client's batch link or similar. Batched requests send multiple operations in a single HTTP request.

**Incorrect (individual handlers don't match batches):**

```typescript
// These won't match a batched request containing both queries
graphql.query('GetUser', () => {
  return HttpResponse.json({ data: { user: { name: 'John' } } })
})

graphql.query('GetPosts', () => {
  return HttpResponse.json({ data: { posts: [] } })
})

// Batched request is unhandled!
```

**Correct (batch handler with individual resolution):**

```typescript
import { http, HttpResponse, getResponse, bypass } from 'msw'

export function batchedGraphQLQuery(url: string, handlers: RequestHandler[]) {
  return http.post(url, async ({ request }) => {
    const requestClone = request.clone()
    const payload = await request.json()

    // Ignore non-batched requests
    if (!Array.isArray(payload)) {
      return
    }

    // Resolve each query in the batch
    const responses = await Promise.all(
      payload.map(async (operation) => {
        const queryRequest = new Request(requestClone.url, {
          method: 'POST',
          headers: requestClone.headers,
          body: JSON.stringify(operation),
        })

        const response = await getResponse(handlers, queryRequest)
        return response || fetch(bypass(queryRequest))
      })
    )

    // Combine responses into batch format
    const results = await Promise.all(
      responses.map((response) => response?.json())
    )

    return HttpResponse.json(results)
  })
}
```

```typescript
// Usage
import { graphql, HttpResponse } from 'msw'
import { batchedGraphQLQuery } from './batchedGraphQLQuery'

const graphqlHandlers = [
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: { user: { id: '1', name: 'John' } },
    })
  }),
  graphql.query('GetPosts', () => {
    return HttpResponse.json({
      data: { posts: [{ id: '1', title: 'Post 1' }] },
    })
  }),
]

export const handlers = [
  batchedGraphQLQuery('/graphql', graphqlHandlers),
  ...graphqlHandlers,  // Also handle non-batched requests
]
```

**When NOT to use this pattern:**
- Apps not using query batching don't need batch handlers

Reference: [MSW GraphQL Query Batching](https://mswjs.io/docs/graphql/mocking-responses/query-batching)
