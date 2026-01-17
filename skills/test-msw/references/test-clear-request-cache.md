---
title: Clear Request Library Caches Between Tests
impact: HIGH
impactDescription: Prevents stale cached responses; ensures fresh mock data per test
tags: test, cache, swr, react-query, tanstack-query, isolation
---

## Clear Request Library Caches Between Tests

Clear data fetching library caches between tests. Libraries like SWR, TanStack Query, and Apollo cache responses, causing tests to receive stale data from previous tests instead of fresh mocked responses.

**Incorrect (cached data leaks between tests):**

```typescript
// test-a.spec.ts
it('displays original user', async () => {
  // Response cached by SWR/React Query
  render(<UserProfile />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})

// test-b.spec.ts
it('displays updated user', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.json({ name: 'Jane' })  // Different user
    })
  )
  render(<UserProfile />)
  // FAILS! Cache returns 'John' from previous test
  expect(await screen.findByText('Jane')).toBeInTheDocument()
})
```

**Correct (clear caches in test setup):**

```typescript
// SWR cache clearing
import { cache } from 'swr'

afterEach(() => {
  // Clear SWR cache
  cache.clear()
})
```

```typescript
// TanStack Query cache clearing
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
    },
  })

const renderWithClient = (ui: React.ReactElement) => {
  const testQueryClient = createTestQueryClient()
  return render(
    <QueryClientProvider client={testQueryClient}>{ui}</QueryClientProvider>
  )
}

// Each test gets fresh QueryClient with no cached data
it('displays user', async () => {
  renderWithClient(<UserProfile />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

```typescript
// Apollo Client cache clearing
import { ApolloClient, InMemoryCache } from '@apollo/client'

afterEach(async () => {
  await client.clearStore()
  // or client.resetStore() to refetch active queries
})
```

**When NOT to use this pattern:**
- Tests intentionally verifying cache behavior should not clear caches

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
