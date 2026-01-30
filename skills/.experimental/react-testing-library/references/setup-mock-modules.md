---
title: Mock Modules at Module Level
impact: MEDIUM
impactDescription: prevents intermittent mock timing failures
tags: setup, mock, jest, modules
---

## Mock Modules at Module Level

Call `jest.mock()` at the top level of your test file, not inside tests. Jest hoists mock calls, but placing them inside tests can cause timing issues.

**Incorrect (mock inside test):**

```tsx
test('fetches user data', async () => {
  jest.mock('./api', () => ({
    fetchUser: jest.fn().mockResolvedValue({ name: 'John' })
  }))

  render(<UserProfile />)
  // Mock may not be applied correctly
})
```

**Correct (mock at module level):**

```tsx
import { fetchUser } from './api'

jest.mock('./api')

const mockFetchUser = fetchUser as jest.MockedFunction<typeof fetchUser>

test('fetches user data', async () => {
  mockFetchUser.mockResolvedValue({ name: 'John' })

  render(<UserProfile />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})

test('handles error', async () => {
  mockFetchUser.mockRejectedValue(new Error('Network error'))

  render(<UserProfile />)
  expect(await screen.findByRole('alert')).toHaveTextContent('Network error')
})
```

**Reset mocks between tests:**

```tsx
beforeEach(() => {
  jest.clearAllMocks()
})
```

Reference: [Jest - Manual Mocks](https://jestjs.io/docs/manual-mocks)
