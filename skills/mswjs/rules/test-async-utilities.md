---
title: Use Async Testing Utilities for Mock Responses
impact: HIGH
impactDescription: Prevents race conditions; ensures responses arrive before assertions
tags: test, async, waitFor, findBy, testing-library, race-condition
---

## Use Async Testing Utilities for Mock Responses

Use async testing utilities (`findBy`, `waitFor`) instead of `getBy` or manual `setTimeout` when testing components that make API calls. Mock responses are asynchronous, and synchronous assertions will fail before data arrives.

**Incorrect (synchronous assertions):**

```typescript
it('displays user name', () => {
  render(<UserProfile />)

  // Fails! Response hasn't arrived yet
  expect(screen.getByText('John')).toBeInTheDocument()
})

// Also incorrect - arbitrary timeout
it('displays user name', async () => {
  render(<UserProfile />)

  await new Promise((resolve) => setTimeout(resolve, 100))

  // Flaky - 100ms might not be enough, or wastes time if faster
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**Correct (async testing utilities):**

```typescript
import { render, screen, waitFor } from '@testing-library/react'

it('displays user name', async () => {
  render(<UserProfile />)

  // findBy* returns a promise that resolves when element appears
  expect(await screen.findByText('John')).toBeInTheDocument()
})

// For non-element assertions, use waitFor
it('updates document title', async () => {
  render(<UserProfile />)

  await waitFor(() => {
    expect(document.title).toBe('John - Profile')
  })
})

// For multiple elements
it('displays user list', async () => {
  render(<UserList />)

  const users = await screen.findAllByRole('listitem')
  expect(users).toHaveLength(3)
})
```

**With loading states:**

```typescript
it('shows loading then content', async () => {
  render(<UserProfile />)

  // Loading state appears immediately
  expect(screen.getByText('Loading...')).toBeInTheDocument()

  // Content replaces loading after response
  expect(await screen.findByText('John')).toBeInTheDocument()
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Synchronous operations that don't involve API calls can use `getBy`

Reference: [Testing Library Async Methods](https://testing-library.com/docs/dom-testing-library/api-async/)
