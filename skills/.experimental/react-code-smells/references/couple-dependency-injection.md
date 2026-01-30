---
title: Use Dependency Injection for External Services
impact: HIGH
impactDescription: enables testing without mocks, allows swapping implementations
tags: couple, dependency-injection, testing, services, decoupling
---

## Use Dependency Injection for External Services

Components directly importing services create tight coupling and testing difficulties. Inject dependencies to enable testing and flexibility.

**Code Smell Indicators:**
- Components import API clients directly
- Tests require mocking module imports
- Can't swap analytics provider without code changes
- Hard to test components with external dependencies

**Incorrect (direct imports create coupling):**

```tsx
// Direct import - tight coupling
import { analyticsClient } from '@/lib/analytics'
import { apiClient } from '@/lib/api'
import { featureFlags } from '@/lib/feature-flags'

function CheckoutButton({ cart }) {
  async function handleCheckout() {
    // Direct dependencies - hard to test
    analyticsClient.track('checkout_started', { cartId: cart.id })

    if (featureFlags.isEnabled('new_checkout')) {
      await apiClient.post('/v2/checkout', cart)
    } else {
      await apiClient.post('/v1/checkout', cart)
    }
  }

  return <button onClick={handleCheckout}>Checkout</button>
}

// Test requires mocking modules
jest.mock('@/lib/analytics')
jest.mock('@/lib/api')
jest.mock('@/lib/feature-flags')
```

**Correct (dependency injection via context):**

```tsx
// Create service context
interface Services {
  analytics: AnalyticsClient
  api: ApiClient
  featureFlags: FeatureFlagClient
}

const ServicesContext = createContext<Services | null>(null)

function useServices() {
  const services = useContext(ServicesContext)
  if (!services) throw new Error('ServicesProvider required')
  return services
}

// Provide real services in app
function App() {
  const services = useMemo(() => ({
    analytics: new AnalyticsClient(process.env.ANALYTICS_KEY),
    api: new ApiClient(process.env.API_URL),
    featureFlags: new FeatureFlagClient(process.env.FF_KEY),
  }), [])

  return (
    <ServicesContext.Provider value={services}>
      <MainApp />
    </ServicesContext.Provider>
  )
}

// Component uses injected services
function CheckoutButton({ cart }) {
  const { analytics, api, featureFlags } = useServices()

  async function handleCheckout() {
    analytics.track('checkout_started', { cartId: cart.id })

    const endpoint = featureFlags.isEnabled('new_checkout')
      ? '/v2/checkout'
      : '/v1/checkout'
    await api.post(endpoint, cart)
  }

  return <button onClick={handleCheckout}>Checkout</button>
}

// Test with mock services - no module mocking needed
function renderWithServices(ui, services = {}) {
  const mockServices = {
    analytics: { track: jest.fn() },
    api: { post: jest.fn().mockResolvedValue({}) },
    featureFlags: { isEnabled: jest.fn() },
    ...services,
  }

  return render(
    <ServicesContext.Provider value={mockServices}>
      {ui}
    </ServicesContext.Provider>
  )
}

test('tracks checkout event', async () => {
  const analytics = { track: jest.fn() }
  renderWithServices(<CheckoutButton cart={mockCart} />, { analytics })

  await userEvent.click(screen.getByText('Checkout'))

  expect(analytics.track).toHaveBeenCalledWith('checkout_started', { cartId: '123' })
})
```

**Alternative: Props injection for leaf components:**

```tsx
// For simple cases, inject via props
interface CheckoutButtonProps {
  cart: Cart
  onCheckout?: (cart: Cart) => Promise<void>
}

function CheckoutButton({
  cart,
  onCheckout = defaultCheckout, // Default implementation
}: CheckoutButtonProps) {
  return <button onClick={() => onCheckout(cart)}>Checkout</button>
}

// Test with custom handler
test('calls onCheckout with cart', async () => {
  const onCheckout = jest.fn()
  render(<CheckoutButton cart={mockCart} onCheckout={onCheckout} />)

  await userEvent.click(screen.getByText('Checkout'))
  expect(onCheckout).toHaveBeenCalledWith(mockCart)
})
```

**When to use which:**
- **Context injection**: Services used by many components
- **Props injection**: Simple dependencies, leaf components
- **Hook injection**: When you need the full hook interface

Reference: [Dependency Injection in React](https://blog.testdouble.com/posts/2021-03-19-react-context-for-dependency-injection-not-state/)
