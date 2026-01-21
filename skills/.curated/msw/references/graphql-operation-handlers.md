---
title: Use Operation Name for GraphQL Matching
impact: MEDIUM
impactDescription: Enables precise operation targeting; prevents query/mutation conflicts
tags: graphql, operation, query, mutation, matching
---

## Use Operation Name for GraphQL Matching

Match GraphQL operations by their operation name, not by URL. All GraphQL requests typically go to the same endpoint (`/graphql`), so operation name is the discriminator.

**Incorrect (URL-based matching for GraphQL):**

```typescript
// All GraphQL requests go to /graphql - this catches everything!
http.post('/graphql', () => {
  return HttpResponse.json({ data: { user: { name: 'John' } } })
})
```

**Correct (operation-based matching):**

```typescript
import { graphql, HttpResponse } from 'msw'

export const handlers = [
  // Match query by operation name
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: {
        user: {
          id: '1',
          name: 'John',
          email: 'john@example.com',
        },
      },
    })
  }),

  // Match mutation by operation name
  graphql.mutation('CreateUser', async ({ variables }) => {
    return HttpResponse.json({
      data: {
        createUser: {
          id: crypto.randomUUID(),
          name: variables.name,
          email: variables.email,
        },
      },
    })
  }),

  // Separate handlers for different queries
  graphql.query('GetUsers', () => {
    return HttpResponse.json({
      data: {
        users: [
          { id: '1', name: 'John' },
          { id: '2', name: 'Jane' },
        ],
      },
    })
  }),
]
```

**Access operation variables:**

```typescript
graphql.query('GetUser', ({ variables }) => {
  // variables matches your GraphQL query variables
  return HttpResponse.json({
    data: {
      user: {
        id: variables.id,
        name: 'John',
      },
    },
  })
})

// Query from client:
// query GetUser($id: ID!) { user(id: $id) { id name } }
// variables: { id: "123" }
```

**Custom GraphQL endpoint:**

```typescript
// If your GraphQL endpoint isn't /graphql
graphql.link('https://api.example.com/gql').query('GetUser', () => {
  return HttpResponse.json({
    data: { user: { name: 'John' } },
  })
})
```

**When NOT to use this pattern:**
- REST APIs should use `http.*` handlers, not GraphQL handlers

Reference: [MSW GraphQL API](https://mswjs.io/docs/api/graphql)
