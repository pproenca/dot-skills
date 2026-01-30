---
title: Mock at Boundaries, Not Internal Details
impact: MEDIUM
impactDescription: prevents brittle tests, enables implementation changes
tags: test, mocking, boundaries, integration, refactoring
---

## Mock at Boundaries, Not Internal Details

Mocking internal functions creates tests that break on refactoring. Mock at system boundaries (APIs, browser APIs) only.

**Code Smell Indicators:**
- Mocking internal utility functions
- Tests break when renaming functions
- Mock setup mirrors implementation structure
- Changing code organization breaks tests

**Incorrect (mocking internal functions):**

```tsx
// Implementation
import { formatDate, calculateTax, validateEmail } from './utils'
import { useAuth } from './hooks/useAuth'

function InvoiceForm({ items }) {
  const { user } = useAuth()
  const total = items.reduce((sum, i) => sum + i.price, 0)
  const tax = calculateTax(total)

  return (
    <form>
      <p>Date: {formatDate(new Date())}</p>
      <p>Tax: {tax}</p>
      <input placeholder="Email" />
    </form>
  )
}

// BAD: Mocking internal utilities
jest.mock('./utils', () => ({
  formatDate: jest.fn().mockReturnValue('2024-01-01'),
  calculateTax: jest.fn().mockReturnValue(10),
  validateEmail: jest.fn().mockReturnValue(true),
}))

jest.mock('./hooks/useAuth', () => ({
  useAuth: () => ({ user: { id: '1', name: 'Test' } }),
}))

test('displays tax', () => {
  render(<InvoiceForm items={[{ price: 100 }]} />)
  // Tightly coupled to internal structure
  expect(calculateTax).toHaveBeenCalledWith(100)
  expect(screen.getByText('Tax: 10')).toBeInTheDocument()
})
```

**Correct (mock at boundaries only):**

```tsx
// Mock ONLY external boundaries
import { server } from './mocks/server'
import { rest } from 'msw'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('displays invoice with calculated values', async () => {
  // Mock API boundary only
  server.use(
    rest.get('/api/user', (req, res, ctx) => {
      return res(ctx.json({ id: '1', name: 'Test User' }))
    }),
    rest.get('/api/tax-rates', (req, res, ctx) => {
      return res(ctx.json({ rate: 0.1 }))
    })
  )

  render(<InvoiceForm items={[{ price: 100 }]} />)

  // Test behavior, not implementation
  await waitFor(() => {
    expect(screen.getByText(/Tax:/)).toHaveTextContent('Tax: $10.00')
  })
})

// Test internal logic by testing the hook/utility directly
test('calculateTax returns correct amount', () => {
  expect(calculateTax(100, 0.1)).toBe(10)
  expect(calculateTax(50, 0.08)).toBe(4)
})
```

**Boundary examples:**

| Mock (Boundary) | Don't Mock (Internal) |
|-----------------|----------------------|
| `fetch` / API calls | Internal utility functions |
| `localStorage` | Custom hooks |
| `Date.now()` | Business logic functions |
| Browser APIs | State management |
| Third-party services | Internal components |

**Mock Service Worker pattern:**

```tsx
// mocks/handlers.ts
import { rest } from 'msw'

export const handlers = [
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(ctx.json({ id: req.params.id, name: 'Test User' }))
  }),

  rest.post('/api/checkout', async (req, res, ctx) => {
    const body = await req.json()
    return res(ctx.json({ orderId: '123', ...body }))
  }),
]

// mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)

// Tests use real code, only network is mocked
test('checkout flow', async () => {
  render(<CheckoutPage />)

  await userEvent.type(screen.getByLabelText('Email'), 'test@test.com')
  await userEvent.click(screen.getByRole('button', { name: 'Complete Order' }))

  // Real components, real hooks, real logic - only API is mocked
  await waitFor(() => {
    expect(screen.getByText('Order #123 confirmed')).toBeInTheDocument()
  })
})
```

**Benefits:**
- Refactor internals freely
- Tests document real behavior
- Closer to actual usage
- Find real integration issues

Reference: [Stop Mocking Fetch](https://kentcdodds.com/blog/stop-mocking-fetch)
