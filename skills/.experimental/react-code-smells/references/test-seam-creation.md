---
title: Create Seams for Testable Components
impact: MEDIUM
impactDescription: enables isolated testing, reduces mock complexity by 60%
tags: test, seams, testability, dependency-injection, refactoring
---

## Create Seams for Testable Components

Tightly coupled components require complex mocking. Create seams (injection points) to enable isolated, focused testing.

**Code Smell Indicators:**
- Tests require mocking many modules
- Can't test component without its dependencies
- Test setup is longer than the test
- Changing implementation breaks many tests

**Incorrect (no seams, hard to test):**

```tsx
import { analyticsClient } from '@/lib/analytics'
import { apiClient } from '@/lib/api'
import { formatCurrency } from '@/lib/formatters'
import { validateEmail } from '@/lib/validators'

function CheckoutForm({ cartItems }) {
  const [email, setEmail] = useState('')
  const [status, setStatus] = useState('idle')

  async function handleSubmit(e) {
    e.preventDefault()
    if (!validateEmail(email)) return

    analyticsClient.track('checkout_started')
    setStatus('submitting')

    try {
      await apiClient.post('/checkout', { email, items: cartItems })
      analyticsClient.track('checkout_completed')
      setStatus('success')
    } catch (error) {
      analyticsClient.track('checkout_failed')
      setStatus('error')
    }
  }

  const total = cartItems.reduce((sum, item) => sum + item.price, 0)

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      <p>Total: {formatCurrency(total)}</p>
      <button type="submit" disabled={status === 'submitting'}>
        {status === 'submitting' ? 'Processing...' : 'Checkout'}
      </button>
    </form>
  )
}

// Test requires mocking 4 modules
jest.mock('@/lib/analytics')
jest.mock('@/lib/api')
jest.mock('@/lib/formatters')
jest.mock('@/lib/validators')
```

**Correct (seams enable isolated testing):**

```tsx
// Dependencies as props (seam)
interface CheckoutFormProps {
  cartItems: CartItem[]
  onSubmit?: (data: CheckoutData) => Promise<void>
  formatCurrency?: (amount: number) => string
  validateEmail?: (email: string) => boolean
}

// Default implementations for production
const defaultDeps = {
  onSubmit: async (data) => {
    await apiClient.post('/checkout', data)
  },
  formatCurrency: (amount) => `$${amount.toFixed(2)}`,
  validateEmail: (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email),
}

function CheckoutForm({
  cartItems,
  onSubmit = defaultDeps.onSubmit,
  formatCurrency = defaultDeps.formatCurrency,
  validateEmail = defaultDeps.validateEmail,
}: CheckoutFormProps) {
  const [email, setEmail] = useState('')
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle')

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!validateEmail(email)) return

    setStatus('submitting')
    try {
      await onSubmit({ email, items: cartItems })
      setStatus('success')
    } catch {
      setStatus('error')
    }
  }

  const total = cartItems.reduce((sum, item) => sum + item.price, 0)

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      <p>Total: {formatCurrency(total)}</p>
      <button type="submit" disabled={status === 'submitting'}>
        {status === 'submitting' ? 'Processing...' : 'Checkout'}
      </button>
    </form>
  )
}

// Tests are simple - no module mocking needed
test('submits form with valid email', async () => {
  const onSubmit = jest.fn().mockResolvedValue(undefined)
  const cartItems = [{ id: '1', name: 'Item', price: 10 }]

  render(<CheckoutForm cartItems={cartItems} onSubmit={onSubmit} />)

  await userEvent.type(screen.getByRole('textbox'), 'test@example.com')
  await userEvent.click(screen.getByRole('button'))

  expect(onSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    items: cartItems,
  })
})

test('validates email before submit', async () => {
  const onSubmit = jest.fn()
  const validateEmail = jest.fn().mockReturnValue(false)

  render(
    <CheckoutForm
      cartItems={[]}
      onSubmit={onSubmit}
      validateEmail={validateEmail}
    />
  )

  await userEvent.type(screen.getByRole('textbox'), 'invalid')
  await userEvent.click(screen.getByRole('button'))

  expect(onSubmit).not.toHaveBeenCalled()
})
```

**Seam patterns:**
- Props for behavior injection
- Context for cross-cutting concerns
- Custom hooks with injectable dependencies
- Render props for rendering variations

Reference: [Working Effectively with Legacy Code - Seams](https://www.oreilly.com/library/view/working-effectively-with/0131177052/)
